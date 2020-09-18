clearvars
rIF = robotIF(1, true);
if rIF.do_sim
    cir = circleShape(0.03,[1.0;0;0]);
    rIF.addObjects(cir)
end
rIF.startLaser()
pause(2.0)
rIF.scr_fig.setEditingMouseHandlers()
figure(1);
title('Lidar Point Cloud')
xlabel('m')
ylabel('m')
legend({'robot', 'points', 'nearest'})
axis([-1 1 -1 1])
pbaspect([1 1 1])
daspect([1 1 1])
clf;

idealObjectRange = 0.2;
gain = 0.80;

while true
    clc
    clf
    ranges = rIF.laser.LatestMessage.Ranges;
    ranges(ranges > 1.0) = NaN;
    ranges(ranges < 0.06) = NaN;
    [x, y, th] = irToXy(1:360, ranges);
    [i] = findNearest(ranges);
    if i ~= -1
        objectRange = ranges(i);
        if th(i) > pi
            bearing = th(i) - 2*pi;
        else
            bearing = th(i);
        end
    else
        objectRange = NaN;
        bearing = NaN;
    end
    
    hold on
    plot(0, 0, 'ro')
    plot(-y, x, 'kx')
    if i ~= -1
        plot(-y(i), x(i), 'gx')
    end
    hold off
    
    if i ~= -1
        curvature = 2.1 * (bearing / objectRange);
        W = 0.12;
        epsilon = 1e-7;
        v_norm = min([gain * abs(objectRange - idealObjectRange), ...
            rIF.max_vel / (1+W*abs(curvature)/2) - epsilon]);
        omega = curvature * v_norm;
        if objectRange - idealObjectRange >= 0
            rIF.sendVelocity(v_norm - W*omega/2, v_norm + W*omega/2)
        else
            rIF.sendVelocity(-v_norm - W*omega/2, -v_norm + W*omega/2)
        end
    else
        rIF.sendVelocity(0,0)
    end
    
    axis([-1 1 -1 1])
    pbaspect([1 1 1])
    daspect([1 1 1])

    
    pause(0.20)
end