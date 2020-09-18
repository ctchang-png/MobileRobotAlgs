clearvars
clc
clf
rIF = robotIF(500, true);
if rIF.do_sim
    cir = circleShape(0.03,[1.0;0;0]);
    rIF.addObjects(cir)
end
rIF.startLaser()
pause(2.0)
rIF.scr_fig.setEditingMouseHandlers()

figure(1);
title('Lidar Point Cloud')
xlabel('robotY (m)')
ylabel('robotX (m)')
axis([-1 1 -1 1])
pbaspect([1 1 1])
daspect([1 1 1])
grid on
hold on
plot(0, 0, 'ro')
pltX = (NaN); pltY = (NaN); pltX_n = (NaN); pltY_n = (NaN);
pts_plt = plot(pltX, pltY, 'kx');
near_plt = plot(pltX_n, pltY_n, 'gx');
hold off
legend({'robot', 'points', 'nearest'}, 'Location', 'northeastoutside')
pts_plt.XDataSource = 'pltX';
pts_plt.YDataSource = 'pltY';
near_plt.XDataSource = 'pltX_n';
near_plt.YDataSource = 'pltY_n';

idealObjectRange = 0.50;
gain = 0.60;

while true
    clc
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

    if i ~= -1
        x_n = x(i);
        y_n = y(i);
    end
    pltX = -y;
    pltY = x;
    pltX_n = -y_n;
    pltY_n = x_n;
    refreshdata
    drawnow
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
    disp(v_norm)

    
    pause(0.20)
end