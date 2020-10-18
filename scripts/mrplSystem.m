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
        trajOrigin
        trajectory
        H_w_t
    end
    
    methods
        function obj = mrplSystem(rIF, model, logger)
            obj = obj@handle;
            obj.rIF = rIF;
            obj.model = model;
            obj.poseEstimator = PoseEstimator(obj.model);
            obj.logger = logger;
            obj.executor = Executor(obj.model);
        end
        
        function update_logger(obj, logger)
            obj.logger = logger;
        end
        
        function executeTrajectory(obj, traj, newOrigin)
            startTime = obj.rIF.toc();
            t = 0;
            Tf = traj.getTrajectoryDuration();
            obj.setTrajOrigin(newOrigin);
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
            
        end
        
        function executeTrajectoryToRelativePose(obj, pose, newOrigin, sign)
            x = pose(1); y = pose(2); th = pose(3);
            traj = cubicSpiralTrajectory.planTrajectory(x, y, th, sign);
            traj.planVelocities(obj.model.vMax)
            obj.trajectory = traj;
            obj.executeTrajectory(traj,newOrigin);
        end
        
        function setTrajOrigin(obj,newOrigin)
           %pose = obj.poseEstimator.getPose(); where the robot is actually 
           pose = newOrigin; %newOrigin is the previous pose target
           obj.trajOrigin = pose;
           H = [cos(pose(3)), -sin(pose(3)), pose(1);...
                sin(pose(3)),  cos(pose(3)), pose(2);...
                0, 0, 1];
           obj.H_w_t = H;
        end
    end
    
end