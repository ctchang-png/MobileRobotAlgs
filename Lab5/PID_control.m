function [u_pid] = PID_control(e, de, dt, constants)
    persistent PID_controller_started;
    persistent integral;
    if isempty(PID_controller_started)
        disp("PID controller started")
        PID_controller_started = 1;
        integral = [0, 0];
    end
    Kp = constants(1);
    Kd = constants(2);
    Ki = constants(3);
    
    integral = integral + e*dt;
    u_pid = Kp*e + Kd*(de/dt) + Ki*integral;
end