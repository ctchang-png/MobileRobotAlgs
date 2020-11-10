% Initialization
clearvars
clc
clf
num = sum(uint8(char("Fido")));
num = 0;
model = Model();
initialPoseVec = [0.0; 0.0; 0.0];
rIF = robotIF(num, true, initialPoseVec);

p1 = [-2 ; -2];
p2 = [ 2 ; -2];
p3 = [ 2 ; 2];
p4 = [-2 ; 2];
lines_p1 = [p1 p2 p3 p4];
lines_p2 = [p2 p3 p4 p1];
map = lineMapLocalizer(lines_p1, lines_p2, 0.3, 0.01, 0.0005);


system = mrplSystem(rIF, model, map);

%{
worldLineArray = worldModel.createThreeWalls();
if rIF.rob.do_sim
    wallsShape = polyLineShape(worldLineArray);
    rIF.addObjects(wallsShape);
end

poseNo = 3;
if(rIF.rob.do_sim )
    switch poseNo
        case 1
            palletPose = [0.45 ; 0.00 ; 0.0];
        case 2
            palletPose = [0.45 ; 0.15 ; atan2(0.15,0.45)]; % facing robot
        case 3
            palletPose = [0.45 ; 0.15 ; 0.0];
    end
    palletPose(1) = palletPose(1)*(1+0.01*randn);
    palletPose(2) = palletPose(2)*(1+0.01*randn);
    palletPose(3) = palletPose(3)*(1+0.05*randn);
end

if rIF.rob.do_sim
    absPalletPoseVec = system.robot2world(palletPose);
    palletShape = palletSailShape(true,absPalletPoseVec);
    rIF.addObjects(palletShape);
end
pause(1.0)
system.driveToPallet(absPalletPoseVec)
rIF.forksUp()
pause(2.0)
rIF.forksDown()
system.forward(-0.05)
system.rotate(pi, 1.0);
%}