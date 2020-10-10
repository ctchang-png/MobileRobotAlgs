classdef Controller < handle
    properties
        traj
        model
        kx
        ky
        kth
    end
    
    properties (Constant)
       lambda = 0.20;
    end
    
    methods
        function obj = Controller(traj, model)
            obj = obj@handle;
            obj.traj = traj;
            obj.model = model;
            lambda = obj.lambda;
            obj.kx = 1/lambda;
            obj.ky = 2/(lambda^2);
            obj.kth = 2/lambda;
        end
        
        function u = getControl(obj, pose, t)
            Vref = obj.traj.getVAtTime(t);
            wref = obj.traj.getwAtTime(t);
            uref = [Vref; wref];
            H = [cos(pose(3)), -sin(pose(3)), pose(1);...
                 sin(pose(3)), cos(pose(3)), pose(2);...
                 0, 0, 1];
            p_traj = obj.traj.getPoseAtTime(t);
            err = H\[p_traj(1:2) ; 1];
            ex = err(1);
            ey = err(2);
            eth = p_traj(3) - pose(3);
            up = [obj.kx*ex ; obj.ky*ey + obj.kth*eth];
            if sum(isnan(up)) ~= 0
                up = [0;0];
            end
            u = uref + up;
        end
    end
    
end