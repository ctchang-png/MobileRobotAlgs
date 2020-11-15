classdef Controller < handle
    properties
        traj
        trajOrigin
        model
        kx
        ky
        kth
    end
    
    properties (Constant)
       lambda = 0.30;
    end
    
    methods(Static)
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
    end
    
    methods
        function obj = Controller(traj, trajOrigin,  model)
            obj = obj@handle;
            obj.traj = traj;
            obj.model = model;
            obj.trajOrigin = trajOrigin;
            lambda = obj.lambda;
            obj.kx = 1/lambda;
            obj.ky = 2/(lambda^2);
            obj.kth = 2/lambda;
        end
        
        function u = getControl(obj, pose, t)
            Vref = obj.traj.getVAtTime(t);
            wref = obj.traj.getwAtTime(t);
            uref = [Vref; wref];
            H_w_r = [cos(pose(3)), -sin(pose(3)), pose(1);...
                     sin(pose(3)), cos(pose(3)), pose(2);...
                     0, 0, 1];
            H_w_t = [cos(obj.trajOrigin(3)), -sin(obj.trajOrigin(3)), obj.trajOrigin(1);...
                     sin(obj.trajOrigin(3)), cos(obj.trajOrigin(3)), obj.trajOrigin(2);...
                     0, 0, 1];
            p_ref_t = obj.traj.getPoseAtTime(t); %in T frame
            p_ref_w = H_w_t * [p_ref_t(1:2) ; 1]; %in world frame
            e_w = p_ref_w - [pose(1:2) ; 1];
            e_r = H_w_r \ e_w;
            ex = e_r(1);
            ey = e_r(2);
            eth = p_ref_t(3) + obj.trajOrigin(3) - pose(3);
            up = [obj.kx*ex ; obj.ky*ey*sign(Vref) + obj.kth*eth];
            if sum(isnan(up)) ~= 0
                up = [0;0];
            end
            u = uref + up;
        end
    end
    
end