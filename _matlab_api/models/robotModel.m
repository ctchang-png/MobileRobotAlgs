classdef robotModel < handle
    %robotModel Properties and static functions for a robot.
    %
    %   A convenience class for storing robot physical properties 
    %   and performing related kinematic transforms. You can reference the
    %   defined constants via the class name (with robotModel.W2 for
    %   example) because they are constant properties and therefore associated
    %   with the class rather than any instance. Similiarly, the kinematics
    %   routines are also referenced from the class name.
    %
    %   $Author: AlonzoKelly $  $Date: 2020/07/15 14:00:00 $ $Revision: 2.0 $
    %   Copyright: Alonzo Kelly 2020
    %
    
    
    properties(Constant)
        %W  = 9.25*2.54/100;   % NEATO wheel tread in m
        %W2 = 9.25*2.54/2/100; % NEATO 1/2 wheel tread in m
        W  = 0.09;              % Raspbot wheel tread in m
        W2 = 0.045;             % Raspbot 1/2 wheel tread in m
        maxWheelVelocity = 0.5 % max of either wheel in m/sec
        
        %rad = .165;             % NEATO robot body radius is 12.75/2 inches
        rad = 0.06;              % Raspbot robot body radius is 6cm
        %frontOffset = 6*0.0254; % NEATO front surface is 6 inch fwd of axle center
        frontOffset = 2.625*0.0254; % front robot surface is 2-5/8 inch fwd of axle center
        objOffset = 0.015;      % offset from sail face to front of sail
		%laser_l = -0.100;      % Neato laser offset (laser is behind wheels)
        laser_l = -0.000;       % Raspbot laser offset
		laser_rad = 0.04;       % laser housing radius
        laser_height = 0.125;   % floor to beam
        tdelay = 0.25;          % comms delay (bidirectional)
        forkDelay = 0.5;        % time to move forks up or down
        beNeato = false;
        
        forks_width = 0.065;    % overall width outside to outside
        forks_length = 0.046;   % overall length from robot diameter to tips
        fork_tine_width = 0.008;% width of tines
    end
    
    properties(Access = private)
    end
    
    properties(Access = public)
    end
    
    methods(Static = true)
        
        function [V, w] = vlvrToVw(vl, vr)
        %VLVRTOVW Converts wheel speeds to body linear and angular velocity.
        %
        %   [V, w] = VLVRTOVW(vl, vr) returns the linear velocity V and the
        %   angular velocity w of a body with left wheel speed vl and right
        %   wheel speed vr.
            V = (vr + vl)/2.0;
            w = (vr - vl)/robotModel.W;
        end
        
        function [vl, vr] = VwTovlvr(V, w)
        %VWTOVLVR Converts body linear and angular velocity to wheel speeds.
        %
        %   [vl, vr] = VWTOVLVR(V, w) returns the left wheel speed vl and
        %   the right wheel speed vr of a body with linear velocity V and
        %   angular velocity w.
            vr = V + robotModel.W2*w;
            vl = V - robotModel.W2*w;
        end
        
        function bodyPts = bodyGraph()
            %BODYGRAPH Returns an array of points that can be used to plot the robot
            % body in a window.
            
            % Model for D shaped Neato robot (used in 16-362 2000-2010 or so
            if(~robotModel.beNeato)
                % angle arrays
                step = pi/20;
                cir = 0: step: 2.0*pi;

                % circle for laser
                lx = robotModel.laser_rad*cos(cir);
                ly = robotModel.laser_rad*sin(cir);
                
                % body with implicit line to laser circle
                bx = [robotModel.rad*cos(cir) lx];
                by = [robotModel.rad*sin(cir) ly];                
            else
                % angle arrays
                step = pi/20;
                q1 = 0:step:pi/2;
                q2 = pi/2:step:pi;
                cir = 0:step:2*pi;          

                % circle for laser
                lx = robotModel.laser_rad*-cos(cir) + robotModel.laser_l;
                ly = robotModel.laser_rad*sin(cir);

                % body rear
                bx = [-sin(q1)*robotModel.rad lx [-sin(q2) 1  1  0]*robotModel.rad];
                by = [-cos(q1)*robotModel.rad ly [-cos(q2) 1 -1 -1]*robotModel.rad];
            end
                        
            %create homogeneous points
            bodyPts = [bx ; by ; ones(1,size(bx,2))];
        end
        
        function forksPts = forksGraph()
            %FORKSGRAPH Returns an array of points that can be used to plot the
            %forks in a window.      
            % The shape is specified with respect to a model frame origin
            % that is the center of the robot.
            
            % Short names
            fW  = robotModel.forks_width;
            fL  = robotModel.forks_length;
            fTW = robotModel.fork_tine_width;
            
            fW2 = fW /2.0;
            fLi = fL-fTW;   % forks inner length
            fWi = fW-2*fTW; % forks inner width
            fWi2 = fWi/2;   % half inner separation;
            
            % Form basic U shape. Start on robot radius and walk arond the
            % shape counterclockwise making one U shape inside the other.
            % First define a list of relative displacements.
            d0  = [0;0]; % origin
            d1  = [0 ; -fW2];
            d2  = [fL ; 0];
            d3  = [0; fTW];
            d4  = [-fLi ; 0];
            d5  = [0 ; fWi2];
            d6  = [0 ; fWi2];
            d7  = [ fLi; 0];
            d8  = [0 ; fTW];
            d9  = [- fL ; 0];
            d10 = [0 ; -fW2];
            
            d = [d0 d1 d2 d3 d4 d5 d6 d7 d8 d9 d10]; % break pt here, step, and plot
            
            % Now integrate this to produce model fraem points using
            % cumulative sums.
            fpts = cumsum(d,2);
            
            % add robot radius to result
            fpts = fpts + [robotModel.rad; 0]; % break pt here, plot(fpts(1,:),fpts(2,:))
                        
            %create homogeneous points
            forksPts = [fpts ; ones(1,size(fpts,2))];
        end
                
        function senToWorld = senToWorld(robToWorld,senToRobot)
            %SENTOWORLD Finds the sensor pose in the world given the robot 
            % pose in the world. This is just a renamed version of 
            % pose.objToWorld that is provided to enhance readability of
            % code.
            %
            %   senToWorld(robToWorld,senToRobot)returns the pose
            %   senToWorld of the sensor in the world given the robot pose
            %   in the world, robToWorld and the sensor pose on the robot
            %   senToRobot.
            senToWorld = pose.objToWorld(robToWorld,senToRobot);
        end
        
        function robToWorld = robToWorld(senToWorld,senToRobot)
            %ROBTOWORLD Finds the robot pose in the world given the sensor 
            % pose in the world. This is just a renamed version of 
            % pose.robToWorld that is provided to enhance readability of
            % code.
            %
            %   robToWorld(senToWorld,senToRobot)returns the pose
            %   robToWorld of the robot in the world given the sensor pose
            %   in the world, senToWorld and the sensor pose on the robot
            %   senToRobot.
            robToWorld = pose.robToWorld(senToWorld,senToRobot);
        end
        
        function [vl , vr, wasLimited] = limitWheelVelocities(ctrVec)
        %LIMITWHEELVELOCITIES Limits the speed of both wheels.
        %
        %   [limVL, limVR] = LIMITWHEELVELOCITIES(ctrVec) takes a vector of
        %   wheel velocities ctrVec = [vl, vr].  If one of the velocities
        %   is greater than the maximum allowed velocity, both velocities
        %   are scaled relative to the difference between the max velocity
        %   and the supplied velocity.  The function returns the scaled
        %   velocities limVL and limVR.
            wasLimited = false;
            vl = ctrVec(1);
            vr = ctrVec(2);
            scale = abs(vr) / robotModel.maxWheelVelocity;
            if(scale > 1.0)
                vr = vr/scale;
                vl = vl/scale;
                wasLimited = true;
            end
            scale = abs(vl) / robotModel.maxWheelVelocity;
            if(scale > 1.0)
                vr = vr/scale;
                vl = vl/scale;
                wasLimited = true;
            end
        end
        
        function palToWld = forkCenterPose(robot_pose)
            %FORKENTERPOSE returns the world pose of the point in the forks where
            %a pallet ideally is positioned and oriented.
            xOffsetFromRobotCenter = robotModel.rad+palletSailModel.base_depth/2.0;
            palToRob = pose.poseVecToMat([xOffsetFromRobotCenter ; 0 ; 0]);
            robToWld = pose.poseVecToMat(robot_pose);
            palToWld = robToWld*palToRob;     
        end
        
    end
    
    methods(Access = private)
        
    end
            
    methods(Access = public)
        

    end
end