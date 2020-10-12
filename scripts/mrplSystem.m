classdef mrplSystem < handle
    
    properties
        rIF
        model
        poseEstimatorAbs
        poseEstimatorTraj
        logger
        executor
        abs_pose
        traj_pose
    end
    
    methods
        function obj = mrplSystem(rIF, model)
            obj = obj@handle;
            obj.rIF = rIF;
            obj.model = model;
            obj.poseEstimatorAbs = PoseEstimator(obj.model);
            obj.poseEstimatorTraj = PoseEstimator(obj.model);
            obj.logger = Logger(true);
            obj.executor = Executor(obj.model);
        end
        
        function executeTrajectory(obj, traj)
            startTime = obj.rIF.toc();
            t = 0;
            Tf = traj.getTrajectoryDuration();
            controller = Controller(traj, obj.model);
            initialized = false;
            obj.poseEstimatorTraj.setOrigin()
            start_pose = obj.poseEstimatorAbs.getPose();
            while t < (Tf + 0.5) %0.5s for end corrections
                if ~initialized
                    %init
                    initialized = true;
                end
                %clc
                t = obj.rIF.toc() - startTime;
                est_pose_abs = obj.poseEstimatorAbs.getPose();
                est_pose_traj = obj.poseEstimatorTraj.getPose();
                u = controller.getControl(est_pose_traj, min(t,Tf));
                obj.executor.sendControl(obj.rIF, u);

                pred_pose = traj.getPoseAtTime(min(t,Tf)) + start_pose;
                obj.logger.update_logs(pred_pose, est_pose_abs)

                pause(0.05)
            end
        end
        
        function executeTrajectoryToRelativePose(obj, pose, sign)
            x = pose(1); y = pose(2); th = pose(3);
            traj = cubicSpiralTrajectory.planTrajectory(x, y, th, sign);
            traj.planVelocities(obj.model.vMax) 
            obj.executeTrajectory(traj);
        end
    end
    
end