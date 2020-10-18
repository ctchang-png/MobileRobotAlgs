classdef Logger < handle
   
    properties(Access = public)
        do_live_plotting;
        pred_logs_X;
        pred_logs_Y;
        est_logs_X;
        est_logs_Y;
        real_logs_X;
        real_logs_Y;
        pred_plt;
        est_plt;
        plot_idx = 0;
    end
    
    properties (Constant)
        plot_n = 200;
    end
    
    methods
        function obj = Logger(do_live_plotting)
           obj = obj@handle;
           obj.do_live_plotting = do_live_plotting;
           obj.pred_logs_X = zeros(1, obj.plot_n);
           obj.pred_logs_Y = zeros(1, obj.plot_n);
           obj.est_logs_X = zeros(1, obj.plot_n);
           obj.est_logs_Y = zeros(1, obj.plot_n);
           obj.real_logs_X = zeros(1, obj.plot_n);
           obj.real_logs_Y = zeros(1, obj.plot_n);
           if do_live_plotting
               	figure
                clf
                title('Pred vs. Est path - Pose')
                xlabel('robotX (m)')
                ylabel('robotY (m)')
                xlim([-1.0 1.0]);
                ylim([-1.0 1.0]);
                hold on
                %Implement if we want to see the target trajectory
                %plot(traj.pose(1,:), traj.pose(2,:), 'k-')
                obj.pred_plt = plot(obj.pred_logs_X, obj.pred_logs_Y, 'g-');
                obj.est_plt = plot(obj.est_logs_X, obj.est_logs_Y, 'b-');
                hold off
                legend({'pred','est'}, 'Location', 'northeastoutside')
           end
        end
        
        function update_logs(obj, pred_pose, est_pose, real_pose)
           obj.plot_idx = obj.plot_idx + 1;
           if obj.plot_idx > length(obj.pred_logs_X)
               obj.pred_logs_X = [obj.pred_logs_X , zeros(1, obj.plot_n)];
               obj.pred_logs_Y = [obj.pred_logs_Y , zeros(1, obj.plot_n)];
               obj.est_logs_X = [obj.est_logs_X , zeros(1, obj.plot_n)];
               obj.est_logs_Y = [obj.est_logs_Y , zeros(1, obj.plot_n)];
               obj.real_logs_X = [obj.real_logs_X , zeros(1, obj.plot_n)];
               obj.real_logs_Y = [obj.real_logs_Y , zeros(1, obj.plot_n)];
           end
           obj.pred_logs_X(obj.plot_idx) = pred_pose(1);
           obj.pred_logs_Y(obj.plot_idx) = pred_pose(2);
           obj.est_logs_X(obj.plot_idx) = est_pose(1);
           obj.est_logs_Y(obj.plot_idx) = est_pose(2);
           obj.real_logs_X(obj.plot_idx) = real_pose(1);
           obj.real_logs_Y(obj.plot_idx) = real_pose(2);
           if obj.do_live_plotting
               set(obj.pred_plt, 'xdata', obj.pred_logs_X(1:obj.plot_idx), ...
                   'ydata', obj.pred_logs_Y(1:obj.plot_idx))
               set(obj.est_plt, 'xdata', obj.est_logs_X(1:obj.plot_idx), ...
                   'ydata', obj.est_logs_Y(1:obj.plot_idx))
           end
        end
        
        function dispTermError(obj)
           predPose = [obj.pred_logs_X(obj.plot_idx), obj.pred_logs_Y(obj.plot_idx)];
           estPose = [obj.est_logs_X(obj.plot_idx), obj.est_logs_Y(obj.plot_idx)];
           realPose = [obj.real_logs_X(obj.plot_idx), obj.real_logs_Y(obj.plot_idx)];
           odomErr = 1000*norm(predPose-estPose);
           trueErr = 1000*norm(predPose-realPose); %Assumes ref traj is perfect
           %(Ignores discretization error but should be good enough)
           fprintf("Odom error: %2.1fmm, true error: %2.1fmm\n", odomErr, trueErr)
        end
    end
    
end
%{
classdef Log < Logger
    properties
       do_live_plotting
       X
       Y
       plt
       plt_idx
    end
end
%}