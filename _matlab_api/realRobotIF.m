classdef realRobotIF < raspbot
    %realRobotIF The real robot interface to the raspbot.
    %
    %   Intended to work identically to the simRobotIF class except that the robot is
    %   real. That means you need to connect to the robot's wifi SSID
    %   before you can expect this interface to work.
    %
    %   A visualization that is identical to that simulator is provided,
    %   except of course, that the robot does not know where it is or where
    %   the walls etc. are. A robot pose is computed here that will make
    %   the robot move appropriately on screen. This pose pure dead
    %   reckoning and will drift significantly. The visualization can be
    %   run in manual mode by calling manualUpdate or it can be invoked
    %   automatically by an interval timer.
    %
    %   $Author: AlonzoKelly $  $Date: 2020/07/15 14:00:00 $ $Revision: 2.0 $
    %   Copyright: Alonzo Kelly 2020
    %
    
    properties (GetAccess='public', SetAccess='private')
		ROS_connected = 0;  % ROS connected flag
        vel_pub;        % velocity message out ROS publisher
		laser_pub;      % laser on/off message out ROS publisher
		fork_pub;       % forks up/down message out ROS publisher
%		kill_pub;       % kill message out ROS publisher
        speech_pub;     % speech message out ROS publisher
%       fileWrite_pub;
        playFile_pub;   % sound file message out ROS publisher
        timeOut = 5.0;  % connection timeout in seconds
        robot_pose = [0;0;0];   % robot pose
    end
    
    properties (GetAccess='private', SetAccess='private')
        last_et;        % last encoder time tag
        last_el;        % last left encoder
        last_er;        % last right encoder
        last_lt;        % last laser time tag        
    end            
                
    properties (Constant, Hidden, GetAccess='private')
        default_gateway = '192.168.0.1'; % IP address
        retries = 5;                    % max retries before declaring failed connection atempt
    end
        
    methods
        function r = realRobotIF(varargin)
            %realRobotIF Construct an instance of this class
            %
            %   Arguments are the same as robotBaseClass
            %
        end      
        
        function shutdown(r)
            %shutdown Shuts down the ROS interface to the robot.
            %
            %   r.shutdown()
            %
        end
        
        function sendVelocityOut(r,v_l, v_r, ~)
            %sendVelocityOut sends wheel velocities to the robot.
            %
            %   r.sendVelocityOut(v_l, v_r, t) sends the left and right
            %   wheel velocities v_l and v_r (in meters/sec). The third
            %   argument is a time t that is optionally used for delay
            %   simulation in for a simulated robot (in simRoboIF).
            %
            %   Subsampling and/or limiting of the wheel speeds may have
            %   occured before getting to this point but the speeds sent to
            %   this function actually go to the robot.
            %
        end
        
        function stop(r)
            %stop Commands the robot to stop moving.   
            %
            %   r.stop()
            %
        end
        
        function startLaser(r)
            %startLaser Turns on Neato laser sensor, causing it to spin.   
            %
            %   r.startLaser()
            %
        end
        
        function forksUp(r)
            %forksUp Moves forks to raised position.    
            %
            %   r.forksUp()
            %
        end
        
        function forksDown(r)
            %forksDown Moves forks to lowered position.
            %
            %   r.forksDown()
            %
        end	
   
        function say(r, str)
            %say Commands the robot to say a phrase from its speakers.  
            %
            %   r.say('Hello world') causes the robot to say 'Hello world'.
            %   The phrase must be a string, but the string can include
            %   numerals (str = 'I have 3 apples' is a valid input, but str
            %   = 3 is not).
            %
        end
        
        function image = captureImage(r)
             %captureImage Captures an image from the forward-facing camera on the robot.
             % 
             %  image = r.captureImage() The image is represented in Matlab's image format.
             %
        end
        
        function vizUpdate(r,~,~)
            % vizUpdate Does a display update.
            %
            % vizUpdate(r,~,~) Does a display update. Here that simply
            % means compute the pose of the robot from the latest incoming
            % encoder message. That is done either when the timer goes off
            % or when the user calls this function.
            %
            
            % Design Notes: Laser data is checked and displayed inside
            % robotIF once we call it. We could use a simDiffSteer here and
            % maybe even share it with simRobotIF but this is lightweight
            % enough as is.
            %
        end 
    end
    
    methods (Hidden = true, Access = 'private')
        function create_robot_interface(r)
            %create_robot_interface Creates the interface to the robot.
            %
            %   r.create_robot_interface() This is the real robot case.
            %   Here "creating" the interface means:
            %
            %   a) Open the wifi link on the default ip address.
            %
            %   b) Create ROS publisher and subscriber classes for the
            %   messages going each way.
            %
            %   c) wait a few (5) seconds to recieve an encoder message and
            %   shutdown if that does not happen.
            %
            %   d) start the suspendable clock if all goes well  
            %
        end
    end
end

