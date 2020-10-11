classdef RobotTrajectory < handle
   
    properties
        numSamples
        vel
        pose
        dist
        duration
        ref
    end
    
    methods
        function obj = RobotTrajectory(refControl, numSamples)
            obj = obj@handle;
            obj.numSamples = numSamples;
            obj.ref = refControl;
            vel = zeros(1, numSamples);
            pose = zeros(3, numSamples);
            dist = zeros(1, numSamples);
            dt = refControl.getTrajectoryDuration / numSamples;
            X = [0;0;0];
            s = 0;
            for ii = 1: numSamples
                time = (ii-1)*dt;
                u = refControl.computeControl(time);
                vel(ii) = u(1);
                pose(:,ii) = X;
                dist(ii) = s;
                s = s + u(1)*dt;
                X = estimator(X, u, dt); 
            end
            obj.vel = vel;
            obj.pose = pose;
            obj.dist = dist;
            obj.duration = refControl.getTrajectoryDuration();
        end
        
        function pose = getPoseAtTime(obj, t)
            T = linspace(0, obj.duration, obj.numSamples);
            pose = (interp1(T, (obj.pose)', t))';
            u = obj.ref.computeControl(t);
            V = u(1);
        end
        
        function w = getwAtTime(obj, t)
            u = obj.ref.computeControl(t);
            w = u(2);
        end
        
        function t = getTrajectoryDuration(obj)
            t = obj.ref.getTrajectoryDuration();
        end
        
    end
    
end