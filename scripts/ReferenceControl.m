classdef ReferenceControl < handle
    %THIS IS JUST AN INTERFACE
    properties
    end
    
    methods (Access = private)
       %Put any helper methods here if necessary 
    end
    
    methods (Access = public)
        function obj = ReferenceControl(parameters, numSamples)
        %constructor
            obj = obj@handle;
        end
        
      
        function pose = getPoseAtTime(obj, t)
        %pose = [x;y;th] at time t
            pose = [0;0;0];
        end
        
        function V = getVAtTime(obj, t)
        %V = V(t)
            V = 0;
        end
        
        function w = getwAtTime(obj, t)
        %w = omega(t)
            w = 0;
        end
        
        function t = getTrajectoryDuration(obj)
        %t = tf
            t = 0;
        end

           
    end 
end