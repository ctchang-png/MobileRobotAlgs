classdef simRobotIF < raspbot
    %simRobotIF The simulated robot interface to the raspbot.
    %
    %   Intended to work identically to the realRobotIF class except that the
    %   robot is simulated. This simulator can be run in manual mode by
    %   calling manualUpdate or it can be invoked automatically by an
    %   interval timer.
    % 
    %   The interval timer case is intended to mimic the behavior of the real
    %   robot in that it is always running whether your code is running or
    %   not and it is always sending data even if no one is listening.
    %
    %   Presently, the robot is not represented in its own world list, so,
    %   for example, it cannot block its own lidar emissions. A few things
    %   would have to be changed slightly if it were in there. If that were
    %   done, and many robots were added to the worldList, they woubd be
    %   abe to see then each other in lidar.
    %
    %   The frequency of sim updates is set in robotIF. It is set at 90 Hz in
    %   Jul 2020 in order to mimic the robot. That corresponds to about 22
    %   Hz encoders and 4 Hz lidar messages.
    %
    %   Error models are used for encoders, lidar and wheel commands, to
    %   make the data and the motion imperfect. See errorModel for the
    %   models. These models are different for each robot but persistent
    %   from run to run for the same robot id. In other wiords, if you
    %   calibrate these errors out in one run, they will stay calibrated
    %   forever or until the error model is deliberately changed. For
    %   convenience in debugging, robot 0 is uncorrupted.
    %
    %   $Author: AlonzoKelly $  $Date: 2020/07/15 14:00:00 $ $Revision: 2.0 $
    %   Copyright: Alonzo Kelly 2020
    %
    
    properties (GetAccess='public', SetAccess='private')
        world_list;     % world list that produces line map for lidar sim
        do_tts=true;    % tts in say command
        sim_motion;      % motion simulator
        laser_scan_pose = [0;0;0]; % pose wrt world of most recent laser scan
    end
    
    properties (Hidden, GetAccess='private', SetAccess='private')	
        sim_laser_on = false;   % laser is off til you call startLaser
        has_map = false;        % map is empty til you add an object
        lidar_pose;             % pose of lidar on robot
                
        dist_since_cmd = 0;     % running distance since last cmd actually went out
		% force a first encoder message
        enc_cnt   = simRobotIF.enc_cnt_period;   % data frames in since last used encoder
        % force a first laser message
        laser_cnt = simRobotIF.laser_cnt_period; % data frames in since last used laser
  
        % initial encoder values mimic the possibility robot will have been
        % on and moving long before connecting to it.
        first_l = random('Uniform',0,10000); % initial value of left encoder
        first_r = random('Uniform',0,10000); % initial value of right encoder
        robotClockBias = random('Uniform',0,10000); % difference between (real) robot and laptop clocks
		last_el = 0;    % last recieved left  encoder value
		last_er = 0;    % last received right encoder value
    end
    
    properties (Constant, Hidden, GetAccess='public')
		enc_delay = 0.085;  % enc and vel delay, was 0.25 til June 2020
        % The laser delay is not currently used. It could be used by
        % creating a laser pose and reading that pose from a pose FIFO
        % in the same way that command delays are simulated now.
		laser_delay = .4;   % estimated delay in the laser data 
    end
    
    properties (Constant, Hidden, GetAccess='private')
        % These count periods convert to seconds by dividing by 90 Hz (or
        % the present value of robotIF.sim_freq). Roughly that means
        % multiply by 0.01 to convert to seconds.
        % 5 = 30 Hz enc updates
		enc_cnt_period = 5;     % sim data frames between published encoders
        % ~4 Hz raycasting, full sweep
        laser_cnt_period = 22;  % sim data frames between published laser
        
        max_dist = 0.25;    % max undriven dist in simulation
		
        laser_sweep = 360;  % laser field of view
		laser_max_range = 4.5;  % max range in meters. No reported range will be higher.
    end
    
    methods(Static)
        function testClass()
            %testClass Some convenient tests that can be run from the console.
            %
            %   You run this static method with className.testClass. There is
            %   no need to create an instance of the class, so you can test
            %   it from the console. Set breakpoints in the code to see
            %   what is happening.
            %
            %   Run this function when you change something to see if the
            %   code still works. Beware that these test routines are not
            %   maintained after the code they are testing is working, so
            %   testClass itself may not work anymore.
            %
            
            %Test for pallet acquision in forksUp.
            
            % create a robot
        end
    end
    
    methods
        function r = simRobotIF(varargin)
            %simRobotIF Construct an instance of this class.
            %
            %   r = simRobotIF(varargin) Arguments are the same as robotBaseClass
            %
        end
              
        function addObjects(r,shape)
            %addObjects Adds a shape(s) to the simulation world model.
            %
            %   r.addObjects(shape)
            %
        end
        
        function shutdown(r)
            %shutdown Stops simulation.
            %
            %   r.shutdown() Stops the suspendable clock, which effectively
            %   stops the process that accepts and processes commands. This
            %   does not stop the interval timer and that is intentional
            %   because the real robot stays up and remembers it state
            %   after you close the ROS link.
            %
        end

        function sendVelocityOut(r,v_l, v_r, t)
            %sendVelocityOut sends wheel velocities to the robot.
            %
            %   r.sendVelocityOut(v_l, v_r, t) sends the left and right wheel
            %   velocities v_l and v_r. The time t is optionally used for delay
            %   simulation.
            %
            %   Subsampling and/or limiting of the wheel speeds may have
            %   occured before getting to this point but the speeds sent to
            %   this function do actually go to the robot.
            %
        
            %r.fire_up_sim_if_needed();
            %fprintf('simRobotIF: sending velocity %f %f\n',v_l,v_r);
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

		function stopLaser(r)
            %stopLaser Turns off Neato laser sensor, causing it to stop spinning.      
            %
            %   r.stopLaser()
            %
            r.sim_laser_on = false;
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
            %   robot.say('Hello world') causes the robot to say 'Hello world'.
            %
            %   Simply prints the string on Windows, Uses the macOS say
            %   command on Macs.
            %
        end
        
        function captureImage(~)
            %captureImage Captures an image from the forward-facing camera on the robot.
            %
            %   r.captureImage()
            %
            %   The image is stored in Matlab's image format. 
            %   NOT IMPLEMENTED IN SIMULATION.
            %
        end
        
        function simUpdate(r,~,~)
            %simUpdate Runs one time step of the simulator.
            %
            %   Users should not call this function. Use robotIF.manualUpdate
            %   instead and that function will call this one for you after
            %   taking care of some other things.
            %
            %   r.simUpdate() This call:
            %
            %   a) runs the motion simulator to move the robot based on the
            %   most recent commands and the elapsed time. 
            %
            %   b) extracts encoder data from the motion simulator and
            %   publishes it if it is time to publish a frame. See
            %   enc_cnt_period.
            %
            %   b) if it is time to publish a lidar frame. See
            %   enc_cnt_period.
            %
            %   Does nothing if the suspendable clock is not running.

        end
    end
    
    methods (Hidden = true, Access = 'private')
        
        function create_sim_motion(r)
            %create_sim_motion Creates a motion simulator.
            %
            %   r.create_sim_motion()
            %            
        end
             
        function [el, er] = getEncoderData(r)
            %getEncoderData Returns the most recent encoder data. 
            %
            %   r.getEncoderData()
            %
            %   This is from the internal motion simulator. Only some
            %   reduced frequency of these messages goes to the
            %   application.
            %
        end
        
        function publishEncoderData(r)
            %publishEncoderData Sends the most recent encoder message to the application.
            %
            %   r.publishEncoderData()
            %
        end
        
        function getLaserData(r)
            %getLaserData Returns the most recent laser data.
            %
            %   r.getLaserData()
            %
        end
        
        function publishLaserData(r)
            %publishLaserData Sends the most recent laser message to the application.
            %
            %   r.publishLaserData()
            %
        end

    end
    
    methods (Hidden = true, Access = 'protected')
        function delete(~)
        end
    end
end