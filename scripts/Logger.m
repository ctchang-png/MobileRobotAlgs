classdef Logger < handle
   
    properties(Access = public)
        %Later: expand to log posture, not just pose(x,y)
        %       expand to log real posture in addition to est
        do_live_plotting;
        pred_logs_X;
        pred_logs_Y;
        est_logs_X;
        est_logs_Y;
        pred_plt;
        est_plt;
        plot_idx = 0;
        posenum;
    end
    
    properties (Constant)
        plot_n = 200;
    end
    
    methods
        function obj = Logger(do_live_plotting)
           obj = obj@handle;
           obj.do_live_plotting = do_live_plotting;
           obj.pred_logs_X = zeros(1, 1); % Matlab is weird you don't need to instantiate the indices - RJ
           obj.pred_logs_Y = zeros(1, 1);
           obj.est_logs_X = zeros(1, 1);
           obj.est_logs_Y = zeros(1, 1);
           if do_live_plotting
               	figure
                clf
                title('Pred vs. Est path - Pose')
                xlabel('robotX (m)')
                ylabel('robotY (m)')
                xlim([-1.6 2.6]);
                ylim([-1.6 2.6]);
                hold on
                %Implement if we want to see the target trajectory
                %plot(traj.pose(1,:), traj.pose(2,:), 'k-')
                obj.pred_plt = plot(obj.pred_logs_X, obj.pred_logs_Y, 'g-');
                %obj.est_plt = plot(obj.est_logs_X, obj.est_logs_Y, 'b-');
                hold off
                legend({'pred','est'}, 'Location', 'northeastoutside')
              
           end
        end
        
        function update_logs(obj, pred_pose, est_pose)
           obj.plot_idx = obj.plot_idx + 1;
           if obj.plot_idx > length(obj.pred_logs_X)
               obj.pred_logs_X = [obj.pred_logs_X ; zeros(1, 1)];
               obj.pred_logs_Y = [obj.pred_logs_Y ; zeros(1, 1)];
               obj.est_logs_X = [obj.est_logs_X ; zeros(1, 1)];
               obj.est_logs_Y = [obj.est_logs_Y ; zeros(1, 1)];
           end
           obj.pred_logs_X(obj.plot_idx) = pred_pose(1);
           obj.pred_logs_Y(obj.plot_idx) = pred_pose(2);
           obj.est_logs_X(obj.plot_idx) = est_pose(1);
           obj.est_logs_Y(obj.plot_idx) = est_pose(2);
           if obj.do_live_plotting
               set(obj.pred_plt, 'xdata', obj.pred_logs_X(1:obj.plot_idx), ...
                   'ydata', obj.pred_logs_Y(1:obj.plot_idx))
               set(obj.est_plt, 'xdata', obj.est_logs_X(1:obj.plot_idx), ...
                   'ydata', obj.est_logs_Y(1:obj.plot_idx))
           end
        end
    end
    
end