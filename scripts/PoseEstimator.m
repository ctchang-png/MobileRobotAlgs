classdef PoseEstimator < handle
    properties
        pose = [0;0;0]; %wrt world frame
        encoderData = [0;0;0];
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
            
        end
 
        function pose = getPose(obj)
            %Update pose on call. Probably better for encoderEventListener
            %to update pose
            newEncoderData = obj.encoderDataGetter();
            d_encoder = newEncoderData - obj.encoderData;
            dl = d_encoder(1);
            dr = d_encoder(2);
            ds = (dr + dl) / 2;
            dth = (dr - dl) / (2 * obj.model.W2);
            th = obj.pose(3) + dth/2;
            x = obj.pose(1) + ds*cos(th);
            y = obj.pose(2) + ds*sin(th);
            th = th + dth/2;
            pose = [x;y;th];
            
            obj.pose = pose;
            obj.encoderData = newEncoderData;
        end
       
    end
    
end