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
            center = [palletPose(1), palletPose(2)];
            radius = palletSailModel.sail_width;
            %pointsOfInterest = obj.perceptor.ROI_circle(radius, center);
            %palletPose = obj.perceptor.findLineCandidate(pointsOfInterest); %robot frame
            
            %theta = palletPose(3);
            %Drive to 5cm in front of pallet, facing pallet
            goalPose = [1, 1, atan2(0.05,0.45)]; %5cm facing pallet
            obj.executeTrajectoryToRelativePose(goalPose, 1);
            pause(2.0);
            %Drive 5cm forward
            obj.forward(0.05);
        end
        
        function forward(obj, dist)
            x = dist;
            y = 0;
            th = 0;
            sgn = 1;
            forwardTraj = forwardTrajectory.planTrajectory(x,y, th, sgn);
            obj.executeTrajectory(forwardTraj);
            %Make robot go forward distance
            %Consider making a trajectory class that's just a straight line
            %and calling obj.executeTrajectory(forwardTraj)
            %TODO
        end
        
        function rotate(obj, theta)
            rotateTraj = [0, 0, theta];
            obj.executeTrajectory(rotateTraj);
            %Make robot rotate theta
            %Consider making a trajectory class that's just a rotation
            %and calling obj.executeTrajectory(rotateTraj)
            %TODO
        end
        
    end
    
end