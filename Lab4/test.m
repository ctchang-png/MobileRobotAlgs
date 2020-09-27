rIF = robotIF(0, true);
rIF.sendVelocity(0.5, 0.5);
pos = zeros(2,1);
idx = 1;
while idx < 40
    pos(:,idx) = [rIF.rob.sim_motion.pose(1);  rIF.toc()];
    idx = idx + 1;
    pause(0.05)
end
vel = zeros(2, 1);
for ii = 1:(length(pos)-1)
    vel(:, ii) = [(pos(1,ii+1)-pos(1,ii))/pos(2,ii); pos(2,ii)];
end
acc = zeros(2, 1);
for jj = 1:(length(vel)-1)
    acc(:, jj) = (vel(1,jj+1)-vel(1,jj))/vel(2,jj);
end