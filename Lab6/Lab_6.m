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

system = mrplSystem(rIF, model, Logger(false));

for ii = 1:length(pose_targets)
    logger = Logger(false);
    system.update_logger(logger);
    pose_target = pose_targets(:, ii);
    system.executeTrajectoryToRelativePose(pose_target, 1);
    rIF.stop()
    
    
    figure
    titlenum = num2str(ii);
    title(['Reference Trajectory vs. Sensed Trajectory - Pose ' , titlenum]);
    xlabel('robotX (m)');
    ylabel('robotY (m)');
    %xlim([-1.6 2.6]);
    %ylim([-1.6 2.6]);
    logger.pred_logs_X;
    hold on;
    plot(logger.pred_logs_X, logger.pred_logs_Y, ...
         logger.est_logs_X, logger.est_logs_Y);
    hold off;
    legend({'ref','sensed'}, 'Location', 'northeastoutside'); %ref = predicted; sensed = estimated
end