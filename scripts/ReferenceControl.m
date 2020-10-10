classdef ReferenceControl < handle
    %Generic ref control class. Update this to fit cubicSpiralTrajectory
    properties
    end
    
    methods
        function obj = ReferenceControl(parameters, tPause)
            obj = obj@handle();
        end
        
        function u = computeControl(obj, timeNow)
            V = 0;
            om = 0;
            u = [V; om];
        end
    end
   
    
end