function [ x, y, th] = irToXy(i, r)
    th = (i.' - 1) * (pi/180) - 5 * (pi/180);
    x = r .* cos(th);
    y = r .* sin(th);
end