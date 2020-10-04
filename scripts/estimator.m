function [X_new] = estimator(X, u, dt)
    %X: [x, y, th]
    %u: [V, om]
    x = X(1);
    y = X(2);
    th = X(3);
    V = u(1);
    om = u(2);
    %midpoint algorithm
    th_new = th + (om/2) * dt;
    x_new = x + V * cos(th_new) * dt;
    y_new = y + V * sin(th_new) * dt;
    th_new = th_new + (om/2) * dt;
    X_new = [x_new, y_new, th_new]';
end