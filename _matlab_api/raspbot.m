classdef raspbot < robotBaseClass
    %raspbot An abstract class to define a common interface for sim and reality.
    %
    %   A class which supplies functions for connecting to, controlling, and
    %   acquiring data from a RaspBot. The commands can be used both in
    %   simulation and with a real robot. They are declared abstract here to
    %   enforce the required interface on sub classes.
    %
    %   The real robots send ROS messages to this class and the simulated one
    %   produces identical simulated messages so that the interface to
    %   application code is identical.
    %
    %   When used in simulation, the derived simulation class uses a
    %   suspendable clock in order to make CPU cycles spent in simulation
    %   disappear. This time standard is used to time tag simulated encoder
    %   data that is passed out of here directly or via the simulated ROS
    %   interface.
    %
    %   No robot communications or graphics take place here. That happens in
    %   derived and support classes.
    %
    %   Commands to "sendVelocity" to real or simulated robots go through
    %   here where they are checked for validity and subsampled to avoid
    %   overloading the robot with commands. Once the decision to actually
    %   send a particular command is made, the sub class sendVelocityOut()
    %   function is called to actually do the sending. Part of the point of
    %   this is to subsample commands to the simulator exactly as they are
    %   subsampled for the real robot. One outcome of this subsampling is
    %   you cannot rely on a single command of zero velocity stopping the
    %   robot. Call stop() if you want to guarantee that your command gets
    %   to the (real or simulated) robot.
    %
    %   Sept 2013: Original version for Neatos by Mike Shomin and Al Kelly
    %   Sept 2016: Modified version for RaspBots and ROS by Dane Bennington
    %   Sept 2017: Additions for Audio and Forks by Ariana Keeling
    %   June 2020: Redesign and numerous bug fixes by Al Kelly
    %
    %   $Author: AlonzoKelly $  $Date: 2020/07/15 14:00:00 $ $Revision: 2.0 $
    %   Copyright: Alonzo Kelly 2020
    %
    
    properties (GetAccess='public', SetAccess='protected')        
		encoders;       % encoder message in ROS subscriber
		laser;          % laser message in ROS subscriber
        camera;         % camera message in ROS subscriber
    end
    
    properties (Hidden, GetAccess='protected', SetAccess='protected')
        vel_inited = 0;     % set when first speed command goes out
        last_vel_time = 0;  % used to send vel cmds out at regular rate
    end
    
    properties (Hidden, GetAccess='protected', SetAccess='protected')
        vel_cmd = [0 0];    % last velocity command
    end

    properties (Constant, Hidden, GetAccess='protected')
        min_vel_period = 0.1;       % limits rate of commands to hardware
		limit_wheel_speeds = true;    %Switch to scale velocities down.
    end
    
  	methods (Static)   
        function t = timeFromStamp(stamp)
            %timeFromStamp Converts a ROS timestamp to a time.
            %
            %   t = raspbot.timeFromStamp(stamp) Converts a ROS timestamp
            %   (seconds and nanoseconds stored in two ints) to a double
            %   representing time in seconds.
            %
        end
    end
        
    methods
		function r = raspbot(varargin)
            %raspbot Creates an instance of this class.
            %
            %   Arguments are the same as robotBaseClass
            %
            r@robotBaseClass(varargin{:});
                           
            % Add location of raspbot.m to the MATLAB path
            fname = which('raspbot.m');
            fname = strrep(fname,'raspbot.m','');
            addpath(genpath(fname));
   
        end
        
		function sendVelocity(r, v_l, v_r)
            %sendVelocity Sends left and right wheel velocity commands to the robot. 
            %
            %   robot.sendVelocity(v_l, v_r) commands the left wheel to spin at
            %   speed v_l and the right wheel at speed v_r.  The values cannot
            %   be NaN, and have a maximum value of 0.5. 
            %
            %   THESE COMMANDS ARE DELIBERATELY UNDERSAMPLED TO AVOID
            %   OVERLOADING THE ROBOT. CALL STOP IF YOU WANT A GUARANTEED
            %   STOP.
            %
            
            if (isnan(v_l) || isnan(v_r))
                r.stop();
                error('You sent a NaN velocity, robot stopping');            
            end

            % Velocity limiting
            wasLimited = false;
            if(r.limit_wheel_speeds)
                [v_l , v_r, wasLimited] = robotModel.limitWheelVelocities([v_l v_r]);
            end
            if(wasLimited)
                error(['Max Vel is ' num2str(r.max_vel) ...
						', you sent ' num2str(max(abs([v_l,v_r])))]);
            end
            
            % send command only if delay has elapsed
            %t = toc(r.vel_timer);
            t = r.sus_clock.read();

            if(~r.vel_inited || (t - r.last_vel_time) > r.min_vel_period)
                % Send velocity to subclass
                r.sendVelocityOut(v_l, v_r, t); % all commands go through here
                r.last_vel_time = t;
                r.vel_inited = true;
            end
			r.vel_cmd = [v_l v_r];
        end
        
        function stamp = stampFromTime(r,clockBias)
            %stampFromTime Converts a time to a ROS timestamp.
            %
            %   stamp = r.stampFromTime(clockBias) Converts a double
            %   representing time in seconds to a ROS timestamp (seconds
            %   and nanoseconds stored in two ints). A clock bias (which
            %   may be zero) is added to force simulation users to deal
            %   with the distinct clock on the robot.
            %
        end
    end
	
    % The following abstract methods must be overriden and fully specified
    % in derived classes. They are provided here to force derived classes
    % to satisfy the API provided to users.
    methods (Abstract)
        shutdown(r)         % shutdown comms to the robot. kill interval timer
        sendVelocityOut(r)  % actually send a velocity command to the robot
        stop(r)             % stop the robot from moving
        startLaser(r)       % turn on the laser and start it rotating
        stopLaser(r)        % turn off the laser and stop it from rotating
        forksUp(r)          % lift forks up
        forksDown(r)        % drop forks down
        say(r,str)          % speak a text string (comes out robot speaker or your speaker for sim)
        captureImage(r)     % take a picture on robot. No sim equivalent.
    end
    
	methods (Hidden = true, Access = 'protected')     
        function delete(~)
            % Destructor
        end
    end
end
