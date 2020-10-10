classdef mrplSystem < handle
    
    properties
        rIF
        model
        controller
        poseEstimator
        logger
        executor
    end
    
    methods
        function obj = mrplSystem(rIF)
            obj = obj@handle;
            obj.rIF = rIF;
            obj.model = Model();
            obj.poseEstimator = PoseEstimator(obj.model);
            obj.logger = Logger(true);
            obj.executor = Executor(obj.model);
        end
        
        function executeTrajectory(traj)
            startTime = obj.rIF.toc();
            t = 0;
            Tf = traj.getTrajectoryDuration();
            controller = Controller(traj, obj.model);
            initialized = false;
            
            while t < Tf
                if ~initialized
                    %init
                    initialized = true;
                end
                clc
                t = obj.rIF.toc() - startTime;
                est_pose = obj.poseEstimator.getPose();
                u = obj.controller.getControl(est_pose, t);
                obj.executor.sendControl(obj.rIF, u);

                pred_pose = traj.getPoseAtTime(t);
                obj.logger.update_logs(pred_pose, est_pose)

                pause(0.05)
            end
        end
    end
    
end