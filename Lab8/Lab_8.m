% Initialization
clearvars

clc
clf
num = sum(uint8(char("My pet Brandon Rishi")));
model = Model();
system = mrplSystem(rIF, model);


%Targets
palletPoses = [0.45, 0.00, 0.0;
               0.45, 0.05, atan2(0.05,0.45);
               0.45, 0.05, 0.0]';
           
if(rIF.rob.do_sim) % &&~doReadLoggedImages not sure what this is
    for poseNo = 3:3
        palletPose = palletPoses(:,poseNo);
        
        palletPose(1) = palletPose(1)*(1+0.01*randn);
        palletPose(2) = palletPose(2)*(1+0.01*randn);
        palletPose(3) = palletPose(3)*(1+0.05*randn);
        palletShape = palletSailShape(true,palletPose);
        rIF.addObjects(palletShape);
    end
end
pause(1.0)

%Main loop
for poseNo = 3:3
    palletPose = palletPoses(:,poseNo); %Theoretical position
    system.driveToPallet(palletPose);
    rIF.forksUp()
    pause(2.0)
    rIF.forksDown()
    system.logger.dispTermError()
    pause(2.0)
end

rIF.stopLaser()
rIF.stop()
%system.logger.dispTermError()