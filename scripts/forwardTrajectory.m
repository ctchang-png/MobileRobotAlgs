classdef forwardTrajectory < ReferenceControl
    %Needs to be filled in
    %probably doesn't need to be as complicated as cubicSpiral
    properties
        numSamples = 0;
        dist = 0;
        V = 0;
    end
    
    methods (Access = private)
       %Put any helper methods here if necessary
    end
    
    methods (Access = public)
        function obj = forwardTrajectory(parameters)
            obj = obj@ReferenceControl();
            obj.dist = parameters(1);
            obj.V = parameters(2);
        end
        
      
        function pose = getPoseAtTime(obj, t)
            Tf = obj.getTrajectoryDuration;
            if t > Tf
                x = obj.dist;
            else
                x = obj.dist * (t / Tf);
            end
            y = 0;
            th = 0;
            pose  = [x ; y ; th];
        end
        
        function V = getVAtTime(obj, t)
            V = obj.V * sign(obj.dist); %No trapezoidal implemented currently
        end
        
        function w = getwAtTime(obj, t)
            w = 0;
        end
        
        function t = getTrajectoryDuration(obj)
            t  = abs(obj.dist) / obj.V;
        end

    end 
end