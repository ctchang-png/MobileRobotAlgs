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
            pose = obj.pose;
        end
        
        function updateFusedPose(obj, odom_only, points)
            %Returns the fused pose with odometry and triangulation
            gain = 0.15;
            poseOdom = obj.getPoseOdom();
            if odom_only
                fusedPose = poseOdom;
            else
                [success, poseTri] = obj.getPoseTri(poseOdom, points);
                if ~success
                    fusedPose = poseOdom;
                else
                    poseErr = poseTri - poseOdom;
                    fusedPose = poseOdom + gain*poseErr;
                end
            end
            obj.pose = fusedPose;
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
        
        function [success, pose] = getPoseTri(obj, inPose, points)
            %inPose ->[x;y;th], initial guess for grad descent
            %points -> x,y in homogeneous form, world frame
            maxIters = 100; 
            points = [points ; ones(1, size(points, 2))];
            [success, pose] = obj.map.refinePose(inPose,points,maxIters);
        end
    end
    
end