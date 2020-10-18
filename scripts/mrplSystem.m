classdef mrplSystem < handle
    %TODO:
    %Add pred and est pose relative to traj origin to logger
    %Add getTerminalError to logger (traj specific)
    properties
        rIF
        model
        poseEstimator
        logger
        executor
        %traj stuff will eventually migrate to a planner class
        trajOrigin = [0;0;0];
        trajectory
        H_w_t = [1,0,0;0,1,0;0,0,1];
    end
    
    methods
        function obj = mrplSystem(rIF, model)
            obj = obj@handle;
            obj.rIF = rIF;
            obj.model = model;
            obj.poseEstimator = PoseEstimator(obj.model);
            obj.logger = Logger(true);
            obj.executor = Executor(obj.model);
        end
        
        function update_logger(obj, logger)
            obj.logger = logger;
        end
        
        function executeTrajectory(obj, traj)
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
                obj.logger.update_logs(pred_pose, est_pose)

                pause(0.05)
            end
            termRefPose = traj.getPoseAtTime(Tf);
            Origin = obj.H_w_t * [termRefPose(1:2) ; 1];
            Origin(3) = termRefPose(3) + obj.trajOrigin(3);
            obj.setTrajOrigin(Origin)
            
        end
        
        function executeTrajectoryToRelativePose(obj, pose, sign)
            x = pose(1); y = pose(2); th = pose(3);
            traj = cubicSpiralTrajectory.planTrajectory(x, y, th, sign);
            traj.planVelocities(obj.model.vMax)
            obj.trajectory = traj;
            obj.executeTrajectory(traj);
        end
        
        function setTrajOrigin(obj,newOrigin)
           %pose = obj.poseEstimator.getPose(); where the robot is actually 
           obj.trajOrigin = newOrigin;
           H = [cos(newOrigin(3)), -sin(newOrigin(3)), newOrigin(1);...
                sin(newOrigin(3)),  cos(newOrigin(3)), newOrigin(2);...
                0, 0, 1];
           obj.H_w_t = H;
        end
    end
    
end