% Initialization
clearvars
clc
clf
num = sum(uint8(char("Fido")));
model = Model();
initialPoseVec = [0.2286;0.2286;-pi()/2.0];
rIF = robotIF(num, true, initialPoseVec);
%lab12_World_Setup;


% Setup pick and drop poses (absolute coordinates)
picks = worldModel.pickDropPoseArray(3,12,12,42,0,-pi()/2.0);
drops = worldModel.pickDropPoseArray(3,21,6,6,0,-pi()/2.0);

%1.219 m = 4 ft
p1 = [0 ; 0];
p2 = [ 1.2192 ; 0];
p3 = [ 1.2192 ; 1.2192];
p4 = [0 ; 1.2192];
%lines_p1 = [p1 p2 p3 p4];
%lines_p2 = [p2 p3 p4 p1];
lines_p1 = [p1 p2 p4];
lines_p2 = [p2 p3 p1];
if rIF.rob.do_sim
    wallsShape = polyLineShape([p4, p1, p2, p3; ones(1, 4)]);
    rIF.addObjects(wallsShape);
end
map = lineMapLocalizer(lines_p1, lines_p2, 0.3, 0.01, 0.0005);


system = mrplSystem(rIF, model, map);
pause(2.0)

% create sails and drops
for pick = picks
    corrPick = corruptPoseWithNoise(pick);
    pickShape = palletSailShape(true,corrPick);
    rIF.addObjects(pickShape);
end
for drop = drops
    dropShape = palletSailShape(false,drop);
    dropDsShape = displayedShape(dropShape,rIF.scr_fig.axHandle,'LineStyle','--','Color','Green'); % makes the drops green
    rIF.addObjects(dropDsShape);
end
function corrPoseVec = corruptPoseWithNoise(poseVec)
%CORRUPTPOSEWITHNOISE Corrupts all 3 elements of pose with random noise.
%   poseVec - the input pose to corrupt
%   corrPoseVec - the output corrupted pose
%
%   The noise is of standard deviation 2 cm in x and y and 5 degrees in yaw.
rng('shuffle');
corrPoseVec(1,1) = poseVec(1)+0.02*randn;
corrPoseVec(2,1) = poseVec(2)+0.02*randn;
corrPoseVec(3,1) = poseVec(3)+5*pi/180*randn;
end

