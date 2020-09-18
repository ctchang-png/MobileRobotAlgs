classdef SimSubscriber < handle
    %SimSubscriber Imitates a ROS subscriber for the RaspBot simulator.
    %
    %   This class uses the event notification features of MATLAB to mimic
    %   ROS. When a simulator produces simulated data, it calls publish()
    %   here which will then both a) raise an OnMessageReceived event to
    %   notify all "listeners" that it has occurred and b) directly call the
    %   newMessageFcn registered on this subscriber object if one exists.
    %
	events
        OnMessageReceived % Nofified when message is received by this subscriber
    end
    
    properties
        LatestMessage; % the most recent message data
        NewMessageFcn; % callback invoked when new messages arrive
	end
    
    methods
		function obj = SimSubscriber(LatestMessage)
        %SimSubscriber Creates an instance of this class.
        %   
        %   obj = SimSubscriber(LatestMessage) Creates an instance and also
        %   sets the latest message of the simulated ROS node to a given
        %   value.
        %
        %   sub = SimSubscriber(msg) sets the latest message of sub to msg.
        %
			obj.LatestMessage = LatestMessage;
        end
        
        function publish(obj)
        %publish Sends a notification to listeners of new data and calls the callback.
        %
        %   When this function is invoked, it is assumed that the new data
        %   has already been placed in LatestMessage. The generated event
        %   creates a new instance of ROSCallbackData for every frame of
        %   data.
        %
			notify(obj, 'OnMessageReceived',ROSCallbackData(obj.LatestMessage));
            % Oct 30,2016, Al Changed 2nd argument from ROSCallbackData(obj.LatestMessage)
            % to make it look the same as the hardware.
            %
            if ~isempty(obj.NewMessageFcn)
                obj.NewMessageFcn(obj,obj.LatestMessage); 
            end
        end
    end 
end