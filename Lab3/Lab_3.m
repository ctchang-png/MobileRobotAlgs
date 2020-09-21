% Initialization
clearvars
clear encoderEventListener
clc
clf
rIF = robotIF(sum(uint8(char("Fido"))), true);
rIF.encoders.NewMessageFcn=@encoderEventListener;
pause(1.0) 
%Trajectory Constants
W = rIF.rob.sim_motion.W2;
V_targ = 0.2;
s_f = 1;
t_f = s_f/V_targ;
k_th = 2*pi/s_f;
k_k = 15.1804;
k_s = 3;
T_f = k_s * t_f;
eps = 1e-7;

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
xlim([-0.5 0.5]);
ylim([-0.5 0.5]);
hold on
predPlt = plot(pred_logsX, pred_logsY, 'g-');
estPlt = plot(est_logsX, est_logsY, 'k-');
hold off
legend({'pred', 'est'}, 'Location', 'northeastoutside')





% Main Loop
doRealTimePlotting = true;
initialized = false;
t_elapsed = -1;

while t_elapsed < T_f
    %Init
    if ~initialized
        t0 = tic;
        prevEncoderData = [0, 0, 0]; %[L, R, T]
        prevVelData = [0, 0]; %[V_l_targ, V_r_targ]
        X_est = [0, 0, 0];
        X_pred = [0, 0, 0];
        initialized = true;
        s = 0;
        rIF.sendVelocity(0, 0)
        t_start = tic;
        t_0 = t_start;
    else
        %Housekeeping
        %clc
        
        %Time Sensitive
        t_elapsed = toc(t_start);
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
        V_l_est = dl/(dt_encoder + eps);
        V_r_est = dr/(dt_encoder + eps);
        
        prevEncoderData = encoderData;
            
        %Trajectory Gen
        t = t_elapsed / k_s;
        s = V_targ * t_elapsed / k_s;
        kappa = (k_k/k_s)*sin(k_th*s);
        om_targ = kappa*V_targ;
        
        %Predictor
        X_pred = estimator(X_pred, [V_targ, om_targ], dt_computer);
        
        %Kinematic Controller
        %fudge = 0.0465/0.045;
        fudge = 1;
        V_l = V_targ - om_targ * W * fudge;
        V_r = V_targ + om_targ * W * fudge;
        %Compensate for HW/randomness
        k_vl = (prevVelData(1)+eps)/(V_l_est + eps);
        k_vr = (prevVelData(2)+eps)/(V_r_est + eps);
        if abs(k_vl) < 2 && abs(k_vr) < 2
            V_l = V_l * k_vl;
            V_r = V_r * k_vr;
        end
        rIF.sendVelocity(V_l, V_r)
        prevVelData = [V_l+eps, V_r+eps];

        %Logging
        plot_idx = plot_idx + 1;
        if plot_idx > length(pred_logsX)
            pred_logsX = [pred_logsX ; zeros(plot_n, 1)];
            pred_logsY = [pred_logsY ; zeros(plot_n, 1)];
            est_logsX = [est_logsX ; zeros(plot_n, 1)];
            est_logsY = [est_logsY ; zeros(plot_n, 1)];
            real_logsX = [real_logsX ; zeros(plot_n, 1)];
            real_logsY = [real_logsY ; zeros(plot_n, 1)];
        end
        pred_logsX(plot_idx) = X_pred(1);
        pred_logsY(plot_idx) = X_pred(2);
        est_logsX(plot_idx) = X_est(1);
        est_logsY(plot_idx) = X_est(2);
        real_logsX(plot_idx) = rIF.rob.sim_motion.pose(1);
        real_logsY(plot_idx) = rIF.rob.sim_motion.pose(2);
        if doRealTimePlotting
            set(predPlt, 'xdata', pred_logsX(1:plot_idx), ...
                'ydata', pred_logsY(1:plot_idx))
            set(estPlt, 'xdata', est_logsX(1:plot_idx), ...
                'ydata', est_logsY(1:plot_idx))
        end
        pause(0.05)
    end
end
rIF.stop()
if ~doRealTimePlotting
    hold on
    plot(pred_logsX(1:plot_idx), pred_logsY(1:plot_idx), 'g-')
    plot(est_logsX(1:plot_idx), est_logsY(1:plot_idx), 'k-')
    hold off
end
norms = sqrt((pred_logsX - real_logsX).^2 + (pred_logsY - real_logsY).^2);
avg_err = sum(norms) / nnz(norms) * 100;
fprintf("Average error: %2.2f cm\n", avg_err)