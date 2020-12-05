% Initialization
clearvars
clc
clf
num = sum(uint8(char("Fido")));
model = Model();
initialPoseVec = [0.2286;0.2286;-pi()/2.0];
rIF = robotIF(num, true, initialPoseVec);


worldLineArray = worldModel.createFourWalls();

% 7 picks and drops arranged horizontally
picks = worldModel.pickDropPoseArray(7,12,12,72,0,-pi()/2.0);
drops = worldModel.pickDropPoseArray(7,18,9,12,0,-pi()/2.0);

% 3 extra picks arranged vertically
picks2 = worldModel.pickDropPoseArray(3,84,0,48,-12,pi());
picks = [picks picks2];
    

p1 = [0 ; 3.6576];
p2 = [ 0 ; 0];
p3 = [ 2.4384 ; 0];
p4 = [2.4384 ; 3.6576];
lines_p1 = [p1 p2 p3 p4];
lines_p2 = [p2 p3 p4 p1];

map = lineMapLocalizer(lines_p1, lines_p2, 0.010, 0.02, 0.008);

system = mrplSystem(rIF, model, map);
pause(2.0)


% create walls
wallsShape = polyLineShape(worldLineArray); 
rIF.addObjects(wallsShape);

% create sails and drops
ii = 1;
for pick = picks
    corrPick = corruptPoseWithNoise(pick);
    corrPicks(:,ii) = corrPick;
    pickShape = palletSailShape(true,corrPick);
    rIF.addObjects(pickShape);
    ii = ii+1;
end
for drop = drops
    dropShape = palletSailShape(false,drop);
    dropDsShape = displayedShape(dropShape,rIF.scr_fig.axHandle,'LineStyle','--','Color','Green'); % makes the drops green
    rIF.addObjects(dropDsShape);
end
pause(2.0)

system.rotate((7/8)*pi, pi/2)
for idx = [1 2 3 4 5 6 7]
   %face pallet
   %find and drive to pallet
   palletPose = picks(:,idx);
   system.driveToPallet(palletPose)
   %pickup pallet
   rIF.forksUp()
   pause(1.0)
   %turn around
   system.rotate((6/8)*pi, pi)
   %drive to drop
   dropPose = drops(:,idx);
   system.dropPallet(dropPose)
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