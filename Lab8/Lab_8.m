% Initialization
clearvars
clear encoderEventListener
clear lidarEventListener
clear PID_control
clc
clf
num = sum(uint8(char("My pet Brandon Rishi")));
num = 0;
rIF = robotIF(num, true);
rIF.encoders.NewMessageFcn=@encoderEventListener;
rIF.laser.NewMessageFcn=@lidarEventListener;
model = Model();
system = mrplSystem(rIF, model);
pause(1.0) 

%Targets
palletPoses = [0.45, 0.00, 0.0;
               0.45, 0.05, atan2(0.05,0.45);
               0.45, 0.05, 0.0]';
           
if(rIF.rob.do_sim) % &&~doReadLoggedImages not sure what this is
    for poseNo = 1:1
        palletPose = palletPoses(:,poseNo);
        
        palletPose(1) = palletPose(1)*(1+0.01*randn);
        palletPose(2) = palletPose(2)*(1+0.01*randn);
        palletPose(3) = palletPose(3)*(1+0.05*randn);

        palletShape = palletSailShape(true,palletPose);
        rIF.addObjects(palletShape);
    end
end


%Main loop
%
for poseNo = 1:1
    palletPose = palletPoses(:,poseNo); %Theoretical position
    system.driveToPallet(palletPose);
    rIF.forksUp()
    pause(2.0)
    rIF.forksDown()
    err = err_fn(args);
    disp(err)
    pause(15.0)
end
%}
rIF.stop()
%system.logger.dispTermError()