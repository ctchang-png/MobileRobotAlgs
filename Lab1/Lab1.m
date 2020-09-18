%% Challenge Task
clearvars
rIF = robotIF(1, true);

timeArray = zeros(1,1);
leftArray = zeros(1,1);
rghtArray = zeros(1,1);
    

tic;
v = 0.05;
k = -0.01;
leftStart = rIF.encoders.LatestMessage.Vector.X;
rghtStart = rIF.encoders.LatestMessage.Vector.Y;
signaledDistance = 0;
idx = 1;
while signaledDistance < 12
    leftEncoder = rIF.encoders.LatestMessage.Vector.X;
    rghtEncoder = rIF.encoders.LatestMessage.Vector.Y;
    dleft = leftEncoder - leftStart - leftArray(idx);
    drght = rghtEncoder - rghtStart - rghtArray(idx);
    dvel = (drght - dleft) * k;
    sendVelocity(rIF, v + dvel, v - dvel)
    pause(0.05)

    signaledDistance = (39.3701)*(leftEncoder-leftStart + rghtEncoder-rghtStart)/2;
    idx = idx + 1;
    timeArray(idx) = toc;
    leftArray(idx) = 100*(leftEncoder - leftStart);
    rghtArray(idx) = 100*(rghtEncoder - rghtStart);
    plot(timeArray, leftArray, timeArray, rghtArray)
end
rIF.stop()
stop_toc = toc;
while toc - stop_toc < 1.0
    timeArray(idx) = toc;
    leftArray(idx) = 100*(leftEncoder - leftStart);
    rghtArray(idx) = 100*(rghtEncoder - rghtStart);
    plot(timeArray, leftArray, timeArray, rghtArray)
end

while signaledDistance > 0
    leftEncoder = rIF.encoders.LatestMessage.Vector.X;
    rghtEncoder = rIF.encoders.LatestMessage.Vector.Y;
    dleft = leftEncoder - leftStart - leftArray(idx);
    drght = rghtEncoder - rghtStart - rghtArray(idx);
    dvel = (drght - dleft) * k;
    sendVelocity(rIF, -v + dvel, -v - dvel)
    pause(0.05)

    signaledDistance = (39.3701)*(leftEncoder-leftStart + rghtEncoder-rghtStart)/2;
    idx = idx + 1;
    timeArray(idx) = toc;
    leftArray(idx) = 100*(leftEncoder - leftStart);
    rghtArray(idx) = 100*(rghtEncoder - rghtStart);
    plot(timeArray, leftArray, timeArray, rghtArray)
end
rIF.stop()
plot(timeArray, leftArray, timeArray, rghtArray)
