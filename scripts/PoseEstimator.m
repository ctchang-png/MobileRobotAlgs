classdef PoseEstimator < handle
    properties
        W2
        prevPose = [0;0;0];
        prevEncoderData = [0;0;0];
        model
    end
    
    methods (Static)
        function [E] = encoderDataGetter()
            global encoderData;
            global updatedSincePull;
            while ~updatedSincePull
                pause(0.001)
            end
            E = [encoderData(1), encoderData(2), encoderData(3)];
            % Left, Right, Timestamp
            updatedSincePull = false;
        end
    end
    
    methods
        function obj = PoseEstimator(model)
            obj = obj@handle;
            obj.model = model;
            obj.W2 = model.W2;
            
        end
 
        function pose = getPose(obj)
            %Update pose on call. Probably better for encoderEventListener
            %to update pose
            encoderData = encoderDataGetter();
            d_encoder = encoderData - obj.prevEncoderData;
            dl = d_encoder(1);
            dr = d_encoder(2);
            ds = (dr + dl) / 2;
            dth = (dr - dl) / (2 * obj.W2);
            th = obj.prevPose(3) + dth/2;
            x = obj.prevPose(1) + ds*cos(th);
            y = obj.prevPose(2) + ds*sin(th);
            th = th + dth/2;
            pose = [x;y;th];
            
            obj.prevPose = pose;
            obj.prevEncoderData = encoderData;
        end
        
        function setOrigin(obj)
           obj.prevPose(1) = 0; %x
           obj.prevPose(2) = 0; %y
           obj.prevPose(3) = 0; %th
           obj.prevEncoderData = encoderDataGetter();
        end
    end
    
end