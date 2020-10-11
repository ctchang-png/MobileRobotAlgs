% Initialization
clearvars
clear encoderEventListener
clear PID_control
clc
clf
num = sum(uint8(char("Fido")));
rIF = robotIF(num, true);
rIF.encoders.NewMessageFcn=@encoderEventListener;
model = Model();
poseEstimator = PoseEstimator(model);
logger = Logger(true);
executor = Executor(model);
%cubicSpiralTrajectory.makeLookupTable(100);
pause(1.0) 

%ref = figure8ReferenceControl(3, 1, 1.0);
%traj1 = RobotTrajectory(ref, 1000); %This will be replaced with cubicSpiralTrajectory
traj1 = cubicSpiralTrajectory([3,-3,2], 1000);
traj1.planVelocities(model.vMax);
trajectories = [traj1];

system = mrplSystem(rIF, model);

for ii = 1:length(trajectories)
    traj = trajectories(ii);
    system.executeTrajectory(traj);
    rIF.stop()
    Tf = traj.getTrajectoryDuration();
    %error stuff is incorrect for now (should find pose relative to start
    %pose)
    term_err = traj.getPoseAtTime(Tf) - rIF.rob.sim_motion.pose;
    e = norm(term_err(1:2) * 1000);
    fprintf("Terminal error for trajectory %1.0f: %2.2fmm \n", ii, e)
end