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


pose_targets = [0.3048,0.3048,0.0;...
                -0.6096,-0.6096,-pi/2.0;...
                -0.3048, 0.3048, pi/2.0].';

system = mrplSystem(rIF, model);

for ii = 1:length(pose_targets)
    pose_target = pose_targets(:, ii);
    system.executeTrajectoryToRelativePose(pose_target, 1);
    rIF.stop()
    %error stuff is incorrect for now (should find pose relative to start
    %pose)
end
err = 1000 * (rIF.rob.sim_motion.pose - [0,0,0]);
e = norm(err(1:2));
fprintf("Terminal error for trajectory %1.0f: %2.2fmm \n", ii, e)