classdef CubicSpiralReferenceControl < ReferenceControl
    properties
        tPause;
    end
    
    methods
        function obj = CubicSpiralReferenceControl(parameters, tPause)
            obj = obj@ReferenceControl();
            obj.tPause = tPause;
        end
        
        function u = computeControl(obj, timeNow)
            V = 0;
            om = 0;
            u = [V; om];
        end
    end
end