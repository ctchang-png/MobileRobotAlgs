% Initialization
clearvars
clear encoderEventListener
clear PID_control
clc
clf
num = sum(uint8(char("Fido")));
rIF = robotIF(num, true);
rIF.encoders.NewMessageFcn=@encoderEventListener;
pause(1.0) 

ref = figure8ReferenceControl(3, 1, 1.0);
traj = RobotTrajectory(ref, 1000);
model = Model();
controller = Controller(ref, traj, model);
poseEstimator = PoseEstimator(model);

%Plotting
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

xlim([-0.6 0.6]);
ylim([-0.6 0.6]);
hold on
plot(traj.pose(1,:), traj.pose(2,:), 'k-')
predPlt = plot(pred_logsX, pred_logsY, 'g-');
estPlt = plot(est_logsX, est_logsY, 'b-');
hold off
legend({'target','pred', 'est'}, 'Location', 'northeastoutside')
doRealTimePlotting = true;
startTime = rIF.toc();
t = 0;
Tf = ref.getTrajectoryDuration();
initialized = false;

while t < Tf
    if ~initialized
        %init
        initialized = true;
    end
    clc
    t = rIF.toc() - startTime;
    pose = poseEstimator.getPose();
    u = controller.getControl(pose, t);
    V = u(1);
    om = u(2);
    vl = V - om*robotModel.W2;
    vr = V + om*robotModel.W2;
    rIF.sendVelocity(vl, vr)
    plot_idx = plot_idx + 1;
    if plot_idx > length(pred_logsX)
        pred_logsX = [pred_logsX ; zeros(plot_n, 1)];
        pred_logsY = [pred_logsY ; zeros(plot_n, 1)];
        est_logsX = [est_logsX ; zeros(plot_n, 1)];
        est_logsY = [est_logsY ; zeros(plot_n, 1)];
    end
    pred_pose = traj.getPoseAtTime(t);
    pred_logsX(plot_idx) = pred_pose(1);
    pred_logsY(plot_idx) = pred_pose(2);
    est_logsX(plot_idx) = pose(1);
    est_logsY(plot_idx) = pose(2);
    if doRealTimePlotting
        set(predPlt, 'xdata', pred_logsX(1:plot_idx), ...
            'ydata', pred_logsY(1:plot_idx))
        set(estPlt, 'xdata', est_logsX(1:plot_idx), ...
            'ydata', est_logsY(1:plot_idx))
    end
    
    pause(0.05)
    %do something
end
rIF.stop()
term_err = traj.getPoseAtTime(Tf) - rIF.rob.sim_motion.pose;
e = norm(term_err(1:2) * 1000);
fprintf("Terminal Error: %2.2fmm \n", e)