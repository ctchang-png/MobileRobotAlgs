if(exist('robot','var'))
    try
        robot.stopLaser();
        pause(0.1);
        robot.shutdown();
        pause(0.1);
        robot.close();
    catch
        clear robot
    end
end
close all
%delete(timerfindall); % not needed now, clear classes deletes timer
clear classes
