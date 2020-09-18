% Lab 13 world setup script. To use call the script from inside your own
% top level script.
%
%   $Author: AlonzoKelly $  $Date: 2020/07/15 14:00:00 $ $Revision: 2.0 $
%   Copyright: Alonzo Kelly 2020
%

% Set up map and state estimator
worldLineArray = worldModel.createFourWalls();
stateEst.setMap(worldLineArray);

% Setup pick and drop poses (absolute coordinates)

% 7 picks and drops arranged horizontally
picks = worldModel.pickDropPoseArray(7,12,12,72,0,-pi()/2.0);
drops = worldModel.pickDropPoseArray(7,18,9,12,0,-pi()/2.0);

% 3 extra picks arranged vertically
picks2 = worldModel.pickDropPoseArray(3,84,0,48,-12,pi());
picks = [picks picks2];
    
% Create world
if (robot.do_sim)     
    % create walls
    wallsShape = polyLineShape(worldLineArray); 
    robot.addObjects(wallsShape);
    
    % create sails and drops
    for pick = picks
        pickShape = palletSailShape(true,pick);
        robot.addObjects(pickShape);
    end

    for drop = drops
        dropShape = palletSailShape(false,drop);
        dropDsShape = displayedShape(dropShape,robot.rV.scr_fig.axHandle,'LineStyle','--','Color','Green'); % makes the drops green
        robot.addObjects(dropDsShape);
    end
end
