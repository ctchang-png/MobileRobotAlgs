% Initialization
clearvars
clc
clf
num = sum(uint8(char("Fido")));
model = Model();
initialPoseVec = [0.0; 0.0; 0.0];
rIF = robotIF(num, true, initialPoseVec);

p1 = [-2 ; -2];
p2 = [ 2 ; -2];
p3 = [ 2 ; 2];
p4 = [-2 ; 2];
%lines_p1 = [p1 p2 p3 p4];
%lines_p2 = [p2 p3 p4 p1];
lines_p1 = [p4 p1];
lines_p2 = [p1 p2];
%worldLineArray = worldModel.createXYAxes();
if rIF.rob.do_sim
    wallsShape = polyLineShape([p4, p1, p2; ones(1, 3)]);
    %wallsShape = polyLineShape(worldLineArray);
    rIF.addObjects(wallsShape);
end
map = lineMapLocalizer(lines_p1, lines_p2, 0.3, 0.01, 0.0005);
%map = lineMapLocalizer(worldLineArray(2), worldLineArray(1), 0.3, 0.01, 0.0005);



system = mrplSystem(rIF, model, map);
pause(2.0)
system.teleOp()
