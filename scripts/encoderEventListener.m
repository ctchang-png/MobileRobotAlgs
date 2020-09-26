function encoderEventListener(handle,event)
    % encoderEventListener Invoked when new encoder data arrives.
    % handle is the encoder object under rIF
    persistent encoderDataStarted;
    persistent encoderDataTimeStart;
    persistent encoderLStart;
    persistent encoderRStart;
    global encoderData;
    global updatedSincePull;
    if isempty(encoderDataStarted)
        disp('Encoder Event Listener is Up');
        encoderDataStarted = 1;
        encoderDataTimeStart = raspbot.timeFromStamp(event.Header.Stamp);
        encoderLStart = handle.LatestMessage.Vector.X;
        encoderRStart = handle.LatestMessage.Vector.Y;
    % Note: We subtract the timeStart to make it easier to read.
    % Otherwise it can be in the billions.
    end
    encoderDataTimeStamp = raspbot.timeFromStamp(event.Header.Stamp)-encoderDataTimeStart;
    encoderDataL = handle.LatestMessage.Vector.X - encoderLStart;
    encoderDataR = handle.LatestMessage.Vector.Y - encoderRStart;
    encoderData = [encoderDataL, encoderDataR, encoderDataTimeStamp];
    updatedSincePull = true;
    
end