%% Lab 1 Exercise 1 Move the Robot
rIF = robotIF(0, true);
v = 0.05;
tic;
while toc < 4
    sendVelocity(rIF, v, v)
    pause(0.05)
end
tic;
while toc < 4
    sendVelocity(rIF, -v, -v)
    pause(0.05)
end
stop(rIF)
%% Lab 1 Exercise 2 Encoders

timeArray = zeros(1,1);
leftArray = zeros(1,1);
rghtArray = zeros(1,1);

tic;
v = 0.05;
leftStart = rIF.encoders.LatestMessage.Vector.X;
rghtStart = rIF.encoders.LatestMessage.Vector.Y;
signaledDistance = 0;
idx = 0;
while signaledDistance < 12
    sendVelocity(rIF, v, v)
    pause(0.05)
    leftEncoder = rIF.encoders.LatestMessage.Vector.X;
    rghtEncoder = rIF.encoders.LatestMessage.Vector.Y;
    signaledDistance = (39.3701)*(leftEncoder-leftStart + rightEncoder-rghtStart)/2;
    idx = idx + 1;
    timeArray(idx) = toc;
    leftArray(idx) = leftEncoder - leftStart;
    rghtArray(idx) = rghtEncoder - rghtStart;
end
stop(rIF)
plot(timeArray, leftArray, timeArray, rghtArray)

