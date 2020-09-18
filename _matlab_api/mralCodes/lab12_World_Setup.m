% Lab 12 World set up script. To use call the script from inside your own
% top level script.
%
% create world composed of two 4 ft walls serving as x and y axes
%
%   $Author: AlonzoKelly $  $Date: 2020/07/15 14:00:00 $ $Revision: 2.0 $
%   Copyright: Alonzo Kelly 2020
%


% Set up map and state estimator
worldLineArray = worldModel.createThreeWalls();

stateEst.setMap(worldLineArray);

% Setup pick and drop poses (absolute coordinates)
picks = worldModel.pickDropPoseArray(3,12,12,42,0,-pi()/2.0);
drops = worldModel.pickDropPoseArray(3,21,6,6,0,-pi()/2.0);

if (theSystem.rob.do_sim)
    % create walls
    wallsShape = polyLineShape(worldLineArray);
    theSystem.addObjects(wallsShape);
    
    % create sails and drops
    for pick = picks
        pickShape = palletSailShape(true,pick);
        theSystem.addObjects(pickShape);
    end

    for drop = drops
        dropShape = palletSailShape(false,drop);
        dropDsShape = displayedShape(dropShape,theSystem.scr_fig.axHandle,'LineStyle','--','Color','Green'); % makes the drops green
        theSystem.addObjects(dropDsShape);
    end
end
