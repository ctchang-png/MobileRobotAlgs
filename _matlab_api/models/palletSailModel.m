classdef palletSailModel < handle
    %palletSailModel Properties and static functions for a pallet sail.
    %
    %   A convenience class for storing palletSail physical properties 
    %   and performing related kinematic transforms. You can reference the
    %   defined constants via the class name (with palletSailModel.width for
    %   example) because they are constant properties and therefore associated
    %   with the class rather than any instance. Similiarly, the kinematics
    %   routines are also referenced from the class name.
    %
    %   $Author: AlonzoKelly $  $Date: 2020/07/15 14:00:00 $ $Revision: 2.0 $
    %   Copyright: Alonzo Kelly 2020
    %
    
    properties(Constant)
        base_width = 0.127;     % pallet width (side facing robot at pickup)
        base_depth = 0.038;     % pallet depth (along forks at pickup)
        hole_width = 0.074;     % fork hole width
        sail_width = palletSailModel.base_width;
        sail_depth = 0.006; 
        
        base_height = 0.25  % from floor to top of base
        sail_height = 145   % from floor to top of sail
        hole_height = 1.0   % from floor to top of fork hole
        
        pickup_err_thresh = 0.01; % used to decide successful pickup in simulation
    end
    
    properties(Access = private)
    end
    
    properties(Access = public)
    end
    
    methods(Static = true)
        
        function rectPts = rectGraph(width, depth)
            %RECTGRAPH Returns an array of points defining a rectangle.
            
            % The model frame is at the center of the base rectangle with the
            % x axis pointing along the depth dimension out the "back".
            y_left =   width/2.0; y_rght = - width/2.0;
            x_frnt = - depth/2.0; x_back =   depth/2.0;            
            
            % Go around ccw from front left and close it
            bx = [x_frnt x_frnt x_back x_back x_frnt];
            by = [y_left y_rght y_rght y_left y_left];
                        
            %create homogeneous points
            rectPts = [bx ; by ; ones(1,size(bx,2))];
        end
                
        function basePts = baseGraph()
            %BASEGRAPH Returns an array of points that can be used to plot
            %the palletSail base in a window. The model frame is at the
            %center of the base rectangle with the
            % x axis pointing along the depth dimension out the "back".

            basePts = palletSailModel.rectGraph(palletSailModel.base_width, ...
                palletSailModel.base_depth);
        end
        
        function sailPts = sailGraph()
            %SAILGRAPH Returns an array of points that can be used to plot
            %the palletSail sail in a window. The model frame is at the
            %center of the base rectangle with the
            % x axis pointing along the depth dimension out the "back".
            
            sailPts = palletSailModel.rectGraph(palletSailModel.sail_width, ...
                palletSailModel.sail_depth);
        end
        
        function objToWorld = objToWorld(robToWorld,objToRobot)
            %OBJTOWORLD Finds the object pose in the world given the robot 
            % pose in the world.
            %
            %   objToWorld(robPose) returns the pose objToWorld of
            %   the object in the world given the robot pose in the world,
            %   robToWorld and the object pose on the robot objToRobot.
            objToWorld = pose.objToWorld(robToWorld,objToRobot);
        end
        
        function robToWorld = robToWorld(objToWorld,objToRobot)
            %ROBTOWORLD Finds the robot pose in the world given the object 
            % pose in the world.
            %
            %   robToWorld(objPose) returns the pose robToWorld of
            %   the robot in the world given the object pose in the world,
            %   objToWorld and the object pose on the robot objToRobot.
            robToWorld = pose.robToWorld(objToWorld,objToRobot);
        end     
    end
    
    methods(Access = private)
        
    end
            
    methods(Access = public)
        
    end
end