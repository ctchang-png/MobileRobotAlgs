classdef PoseEstimator < handle
    properties
        pose = [0;0;0]; %wrt world frame
        encoderData = [0;0;0];
        model
        map
    end
    
    methods (Static)
        function [E] = encoderDataGetter()
            global encoderData;
            global updatedSincePullEncoder;
            while ~updatedSincePullEncoder
                pause(0.001)
            end
            E = [encoderData(1), encoderData(2), encoderData(3)];
            % Left, Right, Timestamp
            updatedSincePullEncoder = false;
        end
    end
    
    methods
        function obj = PoseEstimator(initial_pose, model, map)
            obj = obj@handle;
            obj.model = model;
            obj.pose = initial_pose;
            obj.map = map;
        end
 
        function pose = getPose(obj)
            %For now assume use_DR and use_triangulation are mutually
            %exclusive
            use_odom = true;
            use_tri = false;
            
            poseOdom = obj.getPoseOdom();
            if use_odom && ~use_tri
                pose = poseOdom;
            elseif use_tri && ~use_odom
                pose = poseTri;
            else
                error('Not Yet implemented')
            end
            obj.pose = pose;
        end
       
        function pose = getPoseOdom(obj)
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
            
            obj.encoderData = newEncoderData;
        end
        
        function pose = getPoseTri(obj, points)
            inPose = obj.pose;
            maxIters = 100; 
            points = [points ; ones(1, size(points, 2))];
            [success, pose] = obj.map.refinePose(inPose,points,maxIters);
            obj.pose = pose;
        end
    end
    
end