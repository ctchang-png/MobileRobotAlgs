classdef figure8ReferenceControl < ReferenceControl
    properties (Constant)
        vel = 0.2;
        sf = 1;
        kk = 15.1084;
    end
    
    properties
        ks
        kv
        tPause
        tf
        kth
        Tf
    end
    
    methods
        function obj = figure8ReferenceControl(ks, kv, tPause)
            obj = obj@ReferenceControl();
            obj.ks = ks;
            obj.kv = kv;
            obj.tPause = tPause;
            obj.tf = obj.sf/obj.vel;
            obj.kth = 2*pi/obj.sf;
            obj.Tf = (ks/kv)*obj.tf;
        end
        
        function u = computeControl(obj, timeNow)
            t = (obj.kv/obj.ks)*(timeNow - obj.tPause);
            if timeNow - obj.tPause < 0
                V = 0;
                om = 0;
            elseif timeNow - obj.tPause > obj.Tf
                V = 0;
                om = 0;
            else
                s = obj.vel*t;
                k = (obj.kk/obj.ks)*sin(obj.kth*s);
                V = obj.kv*obj.vel;
                om = k*V;
            end
            u = [V; om];
        end
        
        function duration = getTrajectoryDuration(obj)
            %1s delay at end of trajectory
            duration = obj.tPause + obj.Tf + 1;
        end
    end
    
end