function laserEventListenerExample(handle,event)
%laserEventListener Invoked when new laser data arrives.
%   A MATLAB event listener for the Neato Robot. Invoked when laser data
%   arrives.

global laserFrame;
global laserDataReady;
global laserDataStarted;

%disp('Got laser');

if(~isscalar(laserDataStarted))
    laserDataStarted = true;
    disp('Laser Event Listener is Up\n');
end
laserFrame = laserFrame + 1;
laserDataReady = 1;
end
