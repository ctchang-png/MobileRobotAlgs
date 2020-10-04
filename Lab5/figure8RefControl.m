classdef figure8ReferenceControl < handle
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
            obj = obj@handle();
            obj.ks = ks;
            obj.kv = kv;
            obj.tPause = tPause;
            obj.tf = obj.sf/obj.vel;
            obj.kth = 2*pi/obj.sf;
            obj.Tf = (ks/kv)*obj.tf;
        end
        
        function [V, om] = computeControl(obj, timeNow)
            t = timeNow - obj.tPause;
            if t < 0
                V = 0;
                om = 0;
            elseif t > obj.Tf
                V = 0;
                om = 0;
            else
                s = obj.vel*t;
                k = (obj.kk/obj.ks)*sin(obj.kth*s);
                V = obj.kv*obj.vel;
                om = k*V;
            end
        end
        
        function duration = getTrajectoryDuration(obj)
            %1s delay at end of trajectory
            duration = obj.tPause + obj.Tf + 1;
        end
    end
    
end