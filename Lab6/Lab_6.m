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
pose_targets = [0.3048,0.3048,0.0;...
                -0.6096,-0.6096,-pi/2.0;...
                0.3048, 0.3048, pi/2.0].';
%traj1 = cubicSpiralTrajectory.planTrajectory
%traj1.planVelocities(model.vMax);
%trajectories = [];

system = mrplSystem(rIF, model);

for ii = 1:length(pose_targets)
    pose_target = pose_targets(:, ii);
    system.executeTrajectoryToRelativePose(pose_target, 1);
    rIF.stop()
    system.poseEstimatorAbs.getPose()
    system.poseEstimatorTraj.getPose()
    %error stuff is incorrect for now (should find pose relative to start
    %pose)
    term_err = sum(pose_targets(:,1:ii), 2) - rIF.rob.sim_motion.pose;
    e = norm(term_err(1:2) * 1000);
    fprintf("Terminal error for trajectory %1.0f: %2.2fmm \n", ii, e)
end