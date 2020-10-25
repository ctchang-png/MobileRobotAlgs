function lidarEventListener(handle,event)
    % lidarEventListener Invoked when new lidar data arrives.
    % handle is the laser object under rIF
    persistent lidarDataStarted;
    persistent lidarDataTimeStart;
    global lidarData;
    global updatedSincePullLidar;
    if isempty(lidarDataStarted)
        disp('Lidar Event Listener is Up');
        lidarDataStarted = 1;
        lidarDataTimeStart = raspbot.timeFromStamp(event.Header.Stamp);
    end
    lidarData = handle.LatestMessage.Ranges;
    updatedSincePullLidar = true;
    
end