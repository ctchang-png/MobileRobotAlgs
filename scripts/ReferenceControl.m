classdef ReferenceControl < handle
    %Generic ref control class. Update this to fit cubicSpiralTrajectory
    properties
    end
    
    methods
        function obj = ReferenceControl(parameters, numSamples)
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