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
controller = Controller(traj, model);
poseEstimator = PoseEstimator(model);
logger = Logger(true);
executor = Executor(model);

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
    est_pose = poseEstimator.getPose();
    u = controller.getControl(est_pose, t);
    executor.sendControl(rIF, u);

    pred_pose = traj.getPoseAtTime(t);
    logger.update_logs(pred_pose, est_pose)
    
    pause(0.05)
end
rIF.stop()
term_err = traj.getPoseAtTime(Tf) - rIF.rob.sim_motion.pose;
e = norm(term_err(1:2) * 1000);
fprintf("Terminal Error: %2.2fmm \n", e)