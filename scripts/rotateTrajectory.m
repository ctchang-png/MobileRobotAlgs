classdef rotateTrajectory < ReferenceControl
    %Needs to be filled in
    %probably doesn't need to be as complicated as cubicSpiral
    properties
        numSamples = 0;
        theta = 0;
        w = 0;
    end
    
    methods (Access = private)
       %Put any helper methods here if necessary
        
    end
    
    methods (Access = public)
        function obj = rotateTrajectory(parameters)
            obj = obj@ReferenceControl();
            obj.theta = parameters(1);
            obj.w = parameters(2);
        end
        
      
        function pose = getPoseAtTime(obj, t)
            Tf = obj.getTrajectoryDuration;
            if t > Tf
                th = obj.theta;
            else
                th = obj.theta * (t / Tf);
            end
            x = 0;
            y = 0;
            pose  = [x ; y ; th];
        end
        
        function V = getVAtTime(obj, t)
            V = 0;
        end
        
        function w = getwAtTime(obj, t)
            w = obj.w;
        end
        
        function t = getTrajectoryDuration(obj)
            t  = abs(obj.theta) / obj.w;
        end

    end 
end