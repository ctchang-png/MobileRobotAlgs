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
end
rIF.stop()
system.logger.dispTermError()