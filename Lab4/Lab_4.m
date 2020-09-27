% Initialization
clearvars
clear encoderEventListener
clear PID_control
clc
clf
num = sum(uint8(char("Fido")));

rIF = robotIF(num, true);
W = rIF.rob.sim_motion.W2;
rIF.encoders.NewMessageFcn=@encoderEventListener;
pause(1.0) 

% Plotting
figure(1)
clf
title('Pred and Est path')
xlabel('robotX (m)')
ylabel('robotY (m)')
plot_idx = 0;
plot_n = 50;
pred_logsX = zeros(plot_n, 1);
pred_logsY = zeros(plot_n, 1);
est_logsX = zeros(plot_n, 1);
est_logsY = zeros(plot_n, 1);
real_logsX = zeros(plot_n, 1);
real_logsY = zeros(plot_n, 1);
time_logs = zeros(plot_n, 1);
sref_logs = zeros(plot_n, 1);
sest_logs = zeros(plot_n, 1);
err_logs = zeros(plot_n, 1);
sref = 0;
xlim([-0.6 1.6]);
ylim([-0.6 0.6]);
hold on
predPlt = plot(pred_logsX, pred_logsY, 'g-');
estPlt = plot(est_logsX, est_logsY, 'k-');
hold off
legend({'pred', 'est'}, 'Location', 'northeastoutside')

figure(2)
clf
errPlt = plot(time_logs, err_logs, 'r-');
title('Error vs. Time')
xlabel('time (s)')
ylabel('Error (mm)')
ylim([-6, 6])

figure(3)
clf
hold on
refPlt = plot(time_logs, sref_logs, 'k--');
sestPlt = plot(time_logs, sest_logs, 'b-');
hold off
title("Reference and Estimated distance")
xlabel('time (s)')
ylabel("dist (m)")
ylim([0, 1.1])
xlim([0, 8.0])

pause(1.0)


% Goal State
X_goal = [1.0, 0]; %[s, th]
dist = 1.0;
sgn = 1;

%System
t_delay = 0.1632;
amax = 5.0; %9.9 might be theoretical max
vmax = 0.30;
Tf = (dist + (vmax^2)/amax)/vmax + 1.0;

% Main Loop
doRealTimePlotting = true;
initialized = false;
t_elapsed = -1;
state_err = 1;
V = 1;
min_err = 0.001;
endVmax = 0.005;

while t_elapsed < 10.0 && (t_elapsed < Tf || (min_err < abs(state_err) || V > endVmax))
    %Init
    if ~initialized
        prevEncoderData = [0, 0, 0]; %[L, R, T]
        prevError = 0;
        X_est = [0, 0, 0];
        X_pred = [0, 0, 0];
        initialized = true;
        e = [0, 0];
        de = [0, 0];
        s = 0;
        sest = [0, 0];
        spred = [0, 0];
        sref = [0, 0];
        rIF.sendVelocity(0, 0)
        t_start = rIF.toc();
        t_0 = 0;
    end
    %Housekeeping
    clc

    %Time Sensitive
    t_elapsed = rIF.toc() - t_start;
    dt_computer = double(t_elapsed - t_0);
    t_0 = t_elapsed;
    encoderData = encoderDataGetter;

    %Pose Estimator
    d_encoder = encoderData - prevEncoderData;
    dl = d_encoder(1);
    dr = d_encoder(2);
    dt_encoder = d_encoder(3);
    ds = (dr + dl) / 2;
    dth = (dr - dl) / (2 * W);
    th = X_est(3) + dth/2;
    x = X_est(1) + ds*cos(th);
    y = X_est(2) + ds*sin(th);
    th = th + dth/2;

    X_est = [x, y, th];
    s = s + ds;
    sest = [s, th];

    prevEncoderData = encoderData;

    %Trajectory Gen
    
    %Feedforward Control
    u_ref = trapezoidalVelocityProfile(t_elapsed, amax, vmax, dist, sgn);
    sref = sref + u_ref * dt_computer;
    

    %Predictor
    u_ref_delay = trapezoidalVelocityProfile(t_elapsed-t_delay, amax, vmax, dist, sgn);
    V = u_ref_delay;
    om = 0;
    X_pred = estimator(X_pred, [V, om], dt_computer);
    spred = spred + u_ref_delay * dt_computer;

    %Error Estimation (doesn't consider theta atm)
    e = spred - sest;
    state_err = dist - s;
    de = e - prevError;

    prevError = e;
    
    %Feedback Control 
    constants = [6.0, 0.7, 0.1]; %Kp, Kd, Ki
    V_max = 0.15;
    u_pid = min(V_max, PID_control(e, de, dt_computer, constants));
    
    %Kinematic Controller
    u = u_pid + u_ref;
    V = u(1);
    om = u(2);
    V_l = V - om*W;
    V_r = V + om*W;
    rIF.sendVelocity(V_l, V_r)

    %Logging
    plot_idx = plot_idx + 1;
    if plot_idx > length(pred_logsX)
        pred_logsX = [pred_logsX ; zeros(plot_n, 1)];
        pred_logsY = [pred_logsY ; zeros(plot_n, 1)];
        est_logsX = [est_logsX ; zeros(plot_n, 1)];
        est_logsY = [est_logsY ; zeros(plot_n, 1)];
        real_logsX = [real_logsX ; zeros(plot_n, 1)];
        real_logsY = [real_logsY ; zeros(plot_n, 1)];
        time_logs = [time_logs ; zeros(plot_n, 1)];
        sref_logs = [sref_logs ; zeros(plot_n, 1)];
        sest_logs = [sest_logs ; zeros(plot_n, 1)];
    end
    pred_logsX(plot_idx) = X_pred(1);
    pred_logsY(plot_idx) = X_pred(2);
    est_logsX(plot_idx) = X_est(1);
    est_logsY(plot_idx) = X_est(2);
    real_logsX(plot_idx) = rIF.rob.sim_motion.pose(1);
    real_logsY(plot_idx) = rIF.rob.sim_motion.pose(2);
    time_logs(plot_idx) = t_elapsed;
    sref_logs(plot_idx) = sref(1);
    sest_logs(plot_idx) = sest(1);
    err_logs(plot_idx) = 1000*e(1);
    if doRealTimePlotting
        set(predPlt, 'xdata', pred_logsX(1:plot_idx), ...
            'ydata', pred_logsY(1:plot_idx))
        set(estPlt, 'xdata', est_logsX(1:plot_idx), ...
            'ydata', est_logsY(1:plot_idx))
        set(errPlt, 'xdata', time_logs(1:plot_idx),...
            'ydata', err_logs(1:plot_idx))
        set(refPlt, 'xdata', time_logs(1:plot_idx),...
            'ydata', sref_logs(1:plot_idx))
        set(sestPlt, 'xdata', time_logs(1:plot_idx),...
            'ydata', sest_logs(1:plot_idx))
    end
    pause(0.05)
end
rIF.stop()
if ~doRealTimePlotting
    figure(1)
    hold on
    plot(pred_logsX(1:plot_idx), pred_logsY(1:plot_idx), 'g-')
    plot(est_logsX(1:plot_idx), est_logsY(1:plot_idx), 'k-')
    hold off
    figure(2)
    plot(time_logs(1:plot_idx), error_logs(1:plot_idx), 'r-')
end
norms = sqrt((pred_logsX - real_logsX).^2 + (pred_logsY - real_logsY).^2);
avg_err = sum(norms) / nnz(norms) * 100;
%fprintf("Average error: %2.2f cm\n", avg_err)
fprintf("End State error: %2.2f mm\n", 1000*(dist - s))
fprintf("Time to end; %2.2f s\n", t_elapsed)