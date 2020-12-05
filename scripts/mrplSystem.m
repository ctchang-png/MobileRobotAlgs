classdef mrplSystem < handle 
    properties
        rIF
        model
        poseEstimator
        logger
        executor
        perceptor
        map
        trajOrigin = [0;0;0];
        trajectory
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
           th = wrapToPi(p_w(3) - rPose(3)); 
           p_r = [X(1:2) ; th];
        end
    end
    
    methods
        function obj = mrplSystem(rIF, model, map)
            %rIF -> instance of robotIF
            %model -> instance of Model
            %map -> instance of lineMapLocalizer
            obj = obj@handle;
            obj.model = model;
            obj.map = map;
            obj.poseEstimator = PoseEstimator(rIF.rob.initial_pose, model, map);
            obj.logger = Logger(true);
            obj.executor = Executor(model);
            obj.perceptor = Perceptor(model);
            clear encoderEventListener
            clear lidarEventListener
            %clear PID_control
            rIF.encoders.NewMessageFcn=@encoderEventListener;
            rIF.laser.NewMessageFcn=@lidarEventListener;
            obj.setTrajOrigin(rIF.rob.initial_pose)
            obj.rIF = rIF;
            rIF.startLaser()
            pause(1.0) 
        end
        
        function executeTrajectory(obj, traj, odom_only)
            %traj -> reference trajectory, an instance of a sublcass of
            %ReferenceControl
            startTime = obj.rIF.toc();
            t = 0;
            Tf = traj.getTrajectoryDuration();
            obj.trajectory = traj;
            controller = Controller(traj, obj.trajOrigin, obj.model);
            initialized = false;

            while t < (Tf + 0.5) %1.0s for end corrections
                if ~initialized
                    %init
                    initialized = true;
                end
                t = obj.rIF.toc() - startTime;
                if ~odom_only
                    points = obj.perceptor.allPoints(10);
                    obj.poseEstimator.updateFusedPose(false, points)
                else
                    obj.poseEstimator.updateFusedPose(true, [])
                end
                
                est_pose = obj.poseEstimator.getPose();
                if isnan(t) || isnan(Tf)
                    disp('NaN')
                end
                if isinf(t) || isinf(Tf)
                    disp('inf')
                    disp(t)
                    disp(Tf)
                end
                u = controller.getControl(est_pose, min(t,Tf));
                obj.executor.sendControl(obj.rIF, u);

                p_t = traj.getPoseAtTime(min(t,Tf)); %traj frame
                pred_pose = obj.H_w_t * [p_t(1:2) ; 1]; %world frame
                pred_pose(3) = wrapToPi(p_t(3) + obj.trajOrigin(3)); %world frame
                real_pose = obj.rIF.rob.sim_motion.pose;
                obj.logger.update_logs(pred_pose, est_pose, real_pose)

                pause(0.05)
            end
            obj.rIF.stop()
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
            obj.executeTrajectory(traj, true);
        end
        
        function executeTrajectoryToWorldPose(obj, goalPose, sign)
            obj.triangulate()
            goalPose = obj.world2robot(goalPose);
            x = goalPose(1); y = goalPose(2); th = goalPose(3);
            traj = cubicSpiralTrajectory.planTrajectory(x, y, th, sign);
            traj.planVelocities(obj.model.vMax)
            obj.trajectory = traj;
            obj.executeTrajectory(traj, true);            
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
        
        function triangulate(obj)
            points = obj.perceptor.allPoints(5);
            [success, pose, err, grad] = obj.poseEstimator.setPoseWithTriangulation(points);
            pose = obj.poseEstimator.getPose();
            obj.setTrajOrigin(pose)
        end
        
        function driveToPallet(obj, palletRefPose)
            %palletPose -> [x;y;th] where the pallet ~should~ be
            obj.triangulate()
            %Drive half way
            %{
            center = obj.world2robot(palletRefPose);
            radius = (1.2)*palletSailModel.sail_width;
            pointsOfInterest = obj.perceptor.ROI_circle(radius, center(1:2));
            POI_w = obj.robot2world([pointsOfInterest; zeros(length(pointsOfInterest))]);

            palletPose = obj.perceptor.findLineCandidate(pointsOfInterest); %robot frame

            %Drive to 5cm in front of pallet, facing pallet
            H = [cos(palletPose(3)), -sin(palletPose(3)), palletPose(1);...
                 sin(palletPose(3)), cos(palletPose(3)), palletPose(2);...
                 0, 0, 1];
            palletOffset = [0.5 * (palletSailModel.base_depth - palletSailModel.sail_depth); 0];
            standoff = 0.12;
            X = H*[-obj.model.forkOffset - palletOffset - [standoff;0]; 1];
            goalPose = [(2/3)*X(1:2); 0];
            %}
            goalPose = obj.world2robot(palletRefPose);
            goalPose = [(2/3)*goalPose(1:2); 0];
            obj.executeTrajectoryToRelativePose(goalPose, 1);  
            %Drive the other half
            center = obj.world2robot(palletRefPose);
            radius = (1.2)*palletSailModel.sail_width;
            pointsOfInterest = obj.perceptor.ROI_circle(radius, center(1:2));
            POI_w = obj.robot2world([pointsOfInterest; zeros(length(pointsOfInterest))]);

            palletPose = obj.perceptor.findLineCandidate(pointsOfInterest); %robot frame

            %Drive to 5cm in front of pallet, facing pallet
            H = [cos(palletPose(3)), -sin(palletPose(3)), palletPose(1);...
                 sin(palletPose(3)), cos(palletPose(3)), palletPose(2);...
                 0, 0, 1];
            palletOffset = [0.5 * (palletSailModel.base_depth - palletSailModel.sail_depth); 0];
            standoff = 0.12;
            X = H*[-obj.model.forkOffset - palletOffset - [standoff;0]; 1];
            goalPose = [X(1:2); palletPose(3)];
            obj.executeTrajectoryToRelativePose(goalPose,1);
            
            
            %Drive standoff forward
            center = obj.world2robot(palletRefPose);
            pointsOfInterest = obj.perceptor.ROI_circle(radius, center(1:2));
            palletPose = obj.perceptor.findLineCandidate(pointsOfInterest);
            %Relative to Robot
            standoff = palletPose(1) - obj.model.forkOffset(1) - palletOffset(1);
            obj.forward(standoff);
        end
        
        function dropPallet(obj, dropRefPose)
            obj.triangulate()
            realPose = obj.rIF.rob.sim_motion.pose;
            estPose = obj.poseEstimator.getPose();
            goalPose = dropRefPose;
            standoff = 0.0;
            palletOffset = 0.5 * (palletSailModel.base_depth - palletSailModel.sail_depth);
            goalPose(2) = goalPose(2) + standoff + obj.model.forkOffset(1) + palletOffset;
            %Above only works cause all dropoffs are vertical
            points = obj.perceptor.allPoints(10);
            points_w = obj.robot2world([points;ones(1,length(points))]);
            
            figure(1)
            hold on
            plot(estPose(1), estPose(2), 'go')
            plot(realPose(1), realPose(2), 'ko')
            plot(points_w(1,:), points_w(2,:), 'bx')
            plot(goalPose(1), goalPose(2), 'rx')
            hold off
            
            
            obj.executeTrajectoryToWorldPose(goalPose, 1)
            %obj.forward(standoff)
            obj.rIF.forksDown()
            %obj.forward(-standoff)
            obj.rotate((6/8)*pi, pi)
        end
        
        function forward(obj, dist)
            %Make robot go forward a small distance
            %Triangulation is turned OFF
            x = abs(dist); y = 0; th = 0;
            traj = cubicSpiralTrajectory.planTrajectory(x, y, th, sign(dist));
            traj.planVelocities(0.15)
            obj.trajectory = traj;
            obj.executeTrajectory(traj, true);
            obj.rIF.stop()
        end
        
        function rotate(obj, theta, w)
            %Make robot rotate theta 
            traj = rotateTrajectory([theta, w]);
            obj.trajectory = traj;
            obj.executeTrajectory(traj, true);
            obj.rIF.stop();
        end
   
        function p_w = robot2world(obj, p_r)
           %p_w -> [x;y;th] pose in world frame
           rPose = obj.poseEstimator.getPose();
           H_w_r = [cos(rPose(3)), -sin(rPose(3)), rPose(1);...
                sin(rPose(3)),  cos(rPose(3)), rPose(2);...
                0, 0, 1];
           px_r = p_r(1,:);
           py_r = p_r(2,:);
           pth_r = p_r(3,:);
           X_w = H_w_r * [px_r; py_r ; ones(1, size(px_r,2))];
           px_w = X_w(1,:);
           py_w = X_w(2,:);
           pth_w = wrapToPi(pth_r - rPose(3));
           p_w = [px_w; py_w; pth_w];
        end
        
        function teleOp(obj)
            %A lot of this is super hacky/specific to lab 10
            %I didn't want to change getPose() because it's used everywhere
            %and will be finalized during the next lab, so this function is
            %going to look ugly until then.
            bodyPts_r = obj.model.bodyGraph();
            points_r = obj.perceptor.allPoints(10);
            poseTri = [0;0;0];
            H_w_r = [cos(poseTri(3)), -sin(poseTri(3)), poseTri(1);...
                     sin(poseTri(3)),  cos(poseTri(3)), poseTri(2);...
                     0, 0, 1];
            bodyPts_w = H_w_r * [bodyPts_r ; ones(1,size(bodyPts_r,2))];
            points_w = H_w_r * [points_r ; ones(1, size(points_r, 2))];
            p1 = obj.poseEstimator.map.lines_p1;
            p2 = obj.poseEstimator.map.lines_p2;
            fig = figure(2);
            hold on
            robPlot = plot(bodyPts_w(1,:), bodyPts_w(2,:), 'g');
            ptsPlot = plot(points_w(1,:), points_w(2,:), 'ro');
            for idx = 1:size(p1,2)
                plot([p1(1,idx) p2(1,idx)], [p1(2,idx) p2(2,idx)], 'b')
            end
            hold off
            xlim([-2.1 2.1])
            ylim([-2.1 2.1])
            d = robotKeypressDriver(fig);
            while true
                vGain = 1.0;
                d.drive(obj.rIF, vGain);
                points_r = obj.perceptor.allPoints(10);
                [success, poseTri] = obj.poseEstimator.getPoseTri(poseTri, points_r);
                
                H_w_r = [cos(poseTri(3)), -sin(poseTri(3)), poseTri(1);...
                         sin(poseTri(3)),  cos(poseTri(3)), poseTri(2);...
                         0, 0, 1];
                bodyPts_w = H_w_r * [bodyPts_r ; ones(1,size(bodyPts_r,2))];
                points_w = H_w_r * [points_r; ones(1, size(points_r,2))];
                set(robPlot, 'XData', bodyPts_w(1,:))
                set(robPlot, 'YData', bodyPts_w(2,:))
                set(ptsPlot, 'XData', points_w(1,:))
                set(ptsPlot, 'YData', points_w(2,:))
            end
        end
                
    end
    
end