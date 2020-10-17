classdef simRobot
    %SIMROBOT Integrate encoders
    %   Instance called estRobot keeps track of position and velocity
        %refRobot is where it's supposed to be
    
    properties
        Property1
    end
    
    methods
        function obj = simRobot(inputArg1,inputArg2)
            %SIMROBOT takes encoders and time tags
           
            
        end
        
        function outputArg = method1(obj,inputArg)
           
            outputArg = obj.Property1 + inputArg;
        end
    end
end

