classdef mrplSystem < handle
    
    properties
        rIF
        model
        poseEstimator
        logger
        executor
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
        
        function executeTrajectory(obj, traj)
            startTime = obj.rIF.toc();
            t = 0;
            Tf = traj.getTrajectoryDuration();
            obj.poseEstimator.setOrigin()
            trajOrigin = obj.poseEstimator.trajOrigin;
            H_w_t = obj.poseEstimator.H_w_t;
            controller = Controller(traj, trajOrigin, obj.model);
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

                p_t = traj.getPoseAtTime(min(t,Tf));
                pred_pose = H_w_t * [p_t(1:2) ; 1];
                pred_pose(3) = p_t(3) + trajOrigin(3);
                obj.logger.update_logs(pred_pose, est_pose)

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