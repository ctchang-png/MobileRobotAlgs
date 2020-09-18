classdef ROSCallbackData < event.EventData
    %ROSCallbackData A simple callback to emulate ROS communication in simulation.
    %
    %   A key aspect of the design is that the interface to the simulator
    %   and the real hardware is as identical as we can make it. There are
    %   many aspects to that but the relevant one here is that the simulator
    %   uses this class to produce ROS messages in order to communicate
    %   simulation results to the application. It would be far easier to
    %   just return results from function calls but that is not how
    %   controlling a robot over wifi behaves.
    %
    
    properties
        LatestMessage; % the latest message from the robot
    end
    
    methods
        function obj = ROSCallbackData(LatestMessage)
        %ROSCallbackData Sets the latest message of the simulated ROS node to
        % a given value.
        %
        %   rcd = ROSCallbackData(msg) sets the latest message of rcd to msg.
        %
            obj.LatestMessage = LatestMessage;
        end
    end
    
end

