% Initialization
clearvars
clc
clf
num = sum(uint8(char("Fido")));
model = Model();
initialPoseVec = [0.6096;0.6096;pi()/2.0];
rIF = robotIF(num, true, initialPoseVec);

p1 = [0 ; 0];
p2 = [ 1.5 ; 0];
p3 = [ 2 ; 2];
p4 = [0 ; 1.5];
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


system = mrplSystem(rIF, model, map);
pause(2.0)

endPoints = [0.3048, 0.9144, pi()/2.0;...
             0.9144, 0.3048, 0.0;...
             0.6096, 0.6096, pi()/2.0]';
for idx = 1:size(endPoints, 2)
    terminalPose = endPoints(:,idx);
    system.executeTrajectoryToWorldPose(terminalPose, 1)
    err = rIF.rob.sim_motion.pose - terminalPose;
    terminalErr = 1000*norm(err(1:2));
    fprintf("Terminal Error for trajectory %1.0f = %2.1fmm \n", idx, terminalErr)
end
