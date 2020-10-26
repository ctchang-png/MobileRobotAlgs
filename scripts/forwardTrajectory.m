classdef forwardTrajectory < ReferenceControl
    %Needs to be filled in
    %probably doesn't need to be as complicated as cubicSpiral
    properties
    end
    
    methods (Access = private)
       %Put any helper methods here if necessary
    end
    
    methods (Access = public)
        function obj = forwardTrajectory(parameters, numSamples)
            obj = obj@handle();
        end
        
      
        function pose = getPoseAtTime(obj, t)
            pose  = [0; 0; 0];  
        end
        
        function V = getVAtTime(obj, t)
            V = 0;
        end
        
        function w = getwAtTime(obj, t)
            w = 0;
        end
        
        function t = getTrajectoryDuration(obj)
            t = 0;
        end

           
    end 
end