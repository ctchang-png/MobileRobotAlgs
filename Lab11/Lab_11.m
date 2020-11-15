% Initialization
clearvars
clc
clf
num = sum(uint8(char("Fido")));
model = Model();
initialPoseVec = [0.6096;0.6096;pi()/2.0];
rIF = robotIF(num, true, initialPoseVec);

p1 = [-2 ; -2];
p2 = [ 2 ; -2];
p3 = [ 2 ; 2];
p4 = [-2 ; 2];
lines_p1 = [p1 p2 p3 p4];
lines_p2 = [p2 p3 p4 p1];
if rIF.rob.do_sim
    wallsShape = polyLineShape([p1, p2, p3, p4, p1; ones(1, 5)]);
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
