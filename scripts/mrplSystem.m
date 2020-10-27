classdef mrplSystem < handle
    properties
        rIF
        model
        poseEstimator
        logger
        executor
        perceptor
        trajOrigin = [0;0;0];
        trajectory
        refControl
        H_w_t = [1,0,0;0,1,0;0,0,1];
    end
    
    methods (Access = private)
        function p_r = world2robot(obj, p_w)
            %p_w -> [x;y;th] pose in world frame
           rPose = obj.poseEstimator.getPose();
           H_w_r = [cos(rPose(3)), -sin(rPose(3)), rPose(1);...
                sin(rPose(3)),  cos(rPose(3)), rPose(2);...
                0, 0, 1];
           X = H_w_r \ [p_w(1:2) ; 1];
           p_r = [X ; p_w(3) - rPose(3)];
        end
    end
    
    methods
        function obj = mrplSystem(rIF, model)
            %rIF -> instance of robotIF
            %model -> instance of Model
            obj = obj@handle;
            obj.model = model;
            obj.poseEstimator = PoseEstimator(model);
            obj.logger = Logger(true);
            obj.executor = Executor(model);
            obj.perceptor = Perceptor(model);
            obj.rIF = rIF;
        end
        
        function executeTrajectory(obj, traj)
            %traj -> reference trajectory, an instance of a sublcass of
            %ReferenceControl
            startTime = obj.rIF.toc();
            t = 0;
            Tf = traj.getTrajectoryDuration();
            obj.trajectory = traj;
            controller = Controller(traj, obj.trajOrigin, obj.model);
            initialized = false;

            while t < (Tf + 0.50) %0.5s for end corrections
                if ~initialized
                    %init
                    initialized = true;
                end
                %clc
                t = obj.rIF.toc() - startTime;
                est_pose = obj.poseEstimator.getPose();
                u = controller.getControl(est_pose, min(t,Tf));
                obj.executor.sendControl(obj.rIF, u);

                p_t = traj.getPoseAtTime(min(t,Tf)); %traj frame
                pred_pose = obj.H_w_t * [p_t(1:2) ; 1]; %world frame
                pred_pose(3) = p_t(3) + obj.trajOrigin(3); %world frame
                real_pose = obj.rIF.rob.sim_motion.pose;
                obj.logger.update_logs(pred_pose, est_pose, real_pose)

                pause(0.05)
            end
            termRefPose = traj.getPoseAtTime(Tf);
            Origin = obj.H_w_t * [termRefPose(1:2) ; 1];
            Origin(3) = termRefPose(3) + obj.trajOrigin(3);
            obj.setTrajOrigin(Origin)
            
        end
        
        function executeTrajectoryToRelativePose(obj, pose, sign)
            %pose -> [x;y;th];
            %sign -> -1 or +1, denotes reverse or forward
            x = pose(1); y = pose(2); th = pose(3);
            traj = cubicSpiralTrajectory.planTrajectory(x, y, th, sign);
            traj.planVelocities(obj.model.vMax)
            obj.trajectory = traj;
            obj.executeTrajectory(traj);
        end
        
        function setTrajOrigin(obj,newOrigin)
            %newOrigin -> [x,y,th], will always be the terminal pose of the
            %previous reference trajectory
            obj.trajOrigin = newOrigin;
            H = [cos(newOrigin(3)), -sin(newOrigin(3)), newOrigin(1);...
                 sin(newOrigin(3)),  cos(newOrigin(3)), newOrigin(2);...
                 0, 0, 1];
            obj.H_w_t = H;
        end
        
        function driveToPallet(obj, palletPose)
            %palletPose -> [x;y;th] where the pallet ~should~ be
            
            %TODO
            center = [palletPose(1); palletPose(2)];
            radius = palletSailModel.sail_width;
            %add protection to empty POI
            pointsOfInterest = obj.perceptor.ROI_circle(radius, center);
            palletPose = obj.perceptor.findLineCandidate(pointsOfInterest); %robot frame
            %Drive to 5cm in front of pallet, facing pallet
            %0cm for now
            H = [cos(palletPose(3)), -sin(palletPose(3)), palletPose(1);...
                 sin(palletPose(3)), cos(palletPose(3)), palletPose(2);...
                 0, 0, 1];
            palletOffset = [0.5 * (palletSailModel.base_depth - palletSailModel.sail_depth); 0];
            standoff = 0.050;
            X = H*[-obj.model.forkOffset - palletOffset - [standoff;0]; 1];
            goalPose = [X(1:2); palletPose(3)];
            obj.executeTrajectoryToRelativePose(goalPose, 1);
            %Drive 5cm forward
            c = obj.world2robot([center; 0]);
            c = c(1:2);
            pointsOfInterest = obj.perceptor.ROI_circle(radius, c);
            palletPose = obj.perceptor.findLineCandidate(pointsOfInterest); 
            %rotate to face
            %drive to
            standoff = palletPose(1) - obj.model.forkOffset(1) - palletOffset(1);
            disp(standoff)
            obj.forward(standoff, 0.03);
            
            pause(2.0)
        end
        
        function forward(obj, dist, vel)
            %Make robot go forward distance
            traj = forwardTrajectory([dist, vel]);
            obj.trajectory = traj;
            obj.executeTrajectory(traj);
            obj.rIF.stop()
        end
        
        function rotate(obj, theta, w)
            %Make robot rotate theta 
            %TODO - rotateTrajectory class 
            traj = rotateTrajectory([theta, w]);
            obj.trajectory = traj;
            obj.executeTrajectory(traj);
            obj.rIF.stop()
        end
   
    end
    
end