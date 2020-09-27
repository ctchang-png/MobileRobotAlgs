classdef robotIF < handle
    %robotIF Your main interface to the robot or simulator.
    %
    %   A class which supplies functions for visualizing and interfacing to
    %   a real or simulated RaspBot. Displays the robot in a window,
    %   possibly in the context of walls as well, and its lidar data, if any.
    %
    %   This class now supports the common component of graphics that makes
    %   sense for simulation and real robots. No robot communications take
    %   place here. That happens in derived classes.
    %
    %   Commands: All robot commands and feedback messaages are duplicated
    %   here and transferred to and from the real or simulated robot
    %   untouched. This is done so that you do not have to keep handles to
    %   numerous objects around. Just create an instance of this class and
    %   you can treat it like both your robot and your human interface.
    %
    %   Timers: In both simulation and on the real robot, an interval timer
    %   is (by default but) optionally used. It will force regular updates
    %   of the display (in both cases) and of data in the case of
    %   simulation. That can be expensive so you also have the option of
    %   not using the timer and calling manualUpdate() in your main loop or
    %   whenever you want an update of simulated data and graphics display
    %   to occur.
    %
    %   The real robot will shut itself down if the battery is low. To
    %   mimic that here, the interface shuts down if you do nothing for a
    %   few minutes. That will train you for efficient use of the battery on
    %   the real robot.
    %
    %   Real Time Clock: In your control algorithms, you can use the toc()
    %   function here to read the time that has elapsed since the robot
    %   interface was created. The underlying "suspendable" clock makes
    %   time stand still inside the simulator so those computations do not
    %   affect your real-time controller. If you use this toc() on a real
    %   robot, it is just MATLAB toc() so you can use it in both cases and
    %   your code will work without changes.
    %
    %   Sound: To help you notice when the lidar is on, a low level very
    %   short click sound can be played for every n (=2) frames displayed.
    %   This is expensive so the default is off. Fork motions also have
    %   associated sounds as do attempts to pick up pallets. You can use
    %   the 'say' command to create other useful sounds for yourself.
    %
    %   More on timers: MATLAB's timer objects exist outside the
    %   application in the scope of MATLAB itself so the timer is not
    %   deleted (like all other objects) when your application script
    %   exits. That also means that the data (including this object) that
    %   it references is not deleted. That leads to the objects created by
    %   this object - notably including figure 99 - not only being persistent
    %   but you cannot delete the figure until the timer is deleted. One
    %   ultimate way to do that is to call delete(timerfindall) but it is
    %   more graceful to call rIF.stopTimer() if you just want to inspect
    %   the window. In the GUI, closing figure 99 by clicking on its x
    %   should work most of the time and it is a pretty clean operation
    %   leaving nothing else important lying around in memory. As things
    %   are setup now, deleting figure 99 will delete the timer and vice versa.
    %
    %   Numerous measures are in place to prevent the bad effects of enduring
    %   timers. (1) This class deletes the old timer whenever a new instance
    %   is created. In this way, only one instance can exist at a time. You
    %   can also use the togglePlot function, if you like, to make the
    %   persistent simulation window disappear when no application is
    %   running. Just call togglePlot at the very end of your program. (2)
    %   An onCleanup object is created in the scope of the base workspace
    %   so that when the workspace is cleared (for example when clear all
    %   is called) the destructor for this object is called and that will
    %   delete the timer. (3) a stopTimer function is provided. That makes
    %   it possible to pan and zoom the simulator window and to close its
    %   window. If your window is closed and your script has finished, you
    %   still have the option to call robotIF.deleteOldTimers() from the
    %   console.
    %
    %   Figure 99 is set up so that you cannot draw in it. This is done
    %   because drawing in it is likely to delete the existing display list
    %   of objects in the window with disasterous results. The primitives
    %   used to create this window are all available to you so you can use
    %   the same methods to create your own windows.
    %    
    %   Sept 2013: Original version for Neatos by Mike Shomin and Al Kelly
    %   Sept 2016: Modified version for RaspBots and ROS by Dane Bennington
    %   Sept 2017: Additions for Audio and Forks by Ariana Keeling
    %   June 2020: Redesign and numerous bug fixes by Al Kelly
    %
    %   $Author: AlonzoKelly $  $Date: 2020/07/15 14:00:00 $ $Revision: 2.0 $
    %   Copyright: Alonzo Kelly 2020
    %
    
    properties (GetAccess='public', SetAccess='public')        
        rob;            % robot being visualized
        scr_fig = [];   % scrolling figure for drawing robot
        max_vel = 0.5;  % max wheel velocity
        do_lidar_sound=false;  % lidar sound playback
    end
    
    properties (Hidden, GetAccess='protected', SetAccess='protected')
		ah;            % plot axes
        figHandle;     % plot figure
        last_x = 0;    % last drawn x
		last_y = 0;    % last drawn y
		last_th = 0;   % last drawn th
        last_lidar_time = -1; % used to draw only new lidar messages
        anim_laser;     % animate laser or not
        viz_master_timer=0; % the MATLAB timer that drives all simulation/visualization. Forces production of encoder and lidar frames at regular rates.       
        userTimerFcn;   % timer function provided by user
        in_update=false; % test for timer self interruption
        manual_ignored = false; % allows one warning about call to manualUpdate when timer is on 
        man_inited = 0;     % set when first manual updates set up
        last_man_time = 0;  % used to run simUpdates at regular rate in manual mode. Relies on clock being suspended for sim cycles
        last_cmd_stop_watch;
    end
    
    properties (Hidden, GetAccess='protected', SetAccess='protected')
        rS = [];        % robot shape
        rSdS = [];      % robot displayedShape
        rI = [];        % range image shape
        rIdS = [];      % range image displayedShape
        dS = [];        % lidar dot shape
        dSdS = [];      % lidar dot displayedShape
        dot_rad;        % dot radius
        dot_orb;        % dot orbit radius
        pS = [];        % pallet shape
        pSdS = [];      % pallet displayedShape
        
        audio_player;             % audio player (for longer files). Use sound for clips.
        lidar_sound_y;            % lidar sound amplitude signal
        lidar_sound_Fs;           % lidar sound sampling frequency 
        lidar_sound_cnt=0;        % data frames since last lidar sound
        % force a first plot
        plot_cnt  = robotIF.plot_cnt_period; % data frames between window redraws
    end

    properties (Constant, Hidden, GetAccess='protected')
        sim_freq = 90;  % freq of sim updates
        viz_freq = 20;  % frames per second drawn in viz
        plot_cnt_period = 5; % 90/5 = 18 Hz
        max_time = 240;      % 4 mins before shutdown to save "battery :)";
    end
    
  	methods (Static)          
        
        function testClass
        %testClass Simple test routines. For this one, you have to
        %temporarily comment out the abstract functions declared in any
        %superclasses to test this.
        %
            robot = simRobotIF("test");
            rIF = robotIF(robot);
            toggleVisibility(rIF);
            
            % These 4 will just draw the forks and the lidar dot and change their color.
            rIF.showForksUp();
            pause(2);
            
            rIF.showForksDown();
            pause(2);
            
            rIF.showStartLaser();
            pause(2);
            
            rIF.showStopLaser()
            pause(2);
            
        end
         
        function robotIF_closereq(fig,~) % 2nd arg is callback data
        %robotIF_closereq Cleans up when you close the main window
        %
        %   robotIF.robotIF_closereq() is called when you close the main window It
        %   will delete any active timers before closing and deleting the
        %   window.
        %
            fprintf("robotIF: Closing main window. Killing timers if any\n");
            robotIF.deleteOldTimers();
            fig.set('HandleVisibility','on'); % Just in case, so we can delete it
            %delete(fig.UserData) % deletes the robotIF; Probably cannot delete yourself
            delete(fig);
        end
        
        function deleteOldTimers()
        %deleteOldTimers Deletes old timer(s) left in memory.
        %   
        %   robotIF.deleteOldTimers() Deletes older timers left over in
        %   memory. This is critical because they outlive the app that
        %   created them if not deleted in the app. Having more than one
        %   active timer breaks everything.
        %
            timers = timerfind('Tag','raspbot_sim');
            if(~isempty(timers))
                stop(timers); delete(timers);
            end
        end
    end
        
    methods
        function rIF = robotIF(varargin)
            %robotIF Creates an instance of this class.
            %
            %   Arguments varargin are compatible with robotBaseClass, namely:
            %
            %   rIF = robotIF(id,do_sim,initial_pose,do_manual) creates a
            %   robot with the indicated id, sim flag, initial pose and
            %   manual flag settings. Any argument can be missing and if it
            %   is, it will be set to a default value and argument scanning
            %   will skip over it. Arguments are consumed as soon as
            %   possible so a single logical argument is taken to mean
            %   do_sim rather than do_manual.
            %            
            %   This class does the following:
            %
            %   a) Creates the interface to the real or simulated robot
            %
            %   b) Creates the main display window - Figure 99. Sets the
            %   viewport in the real robot case to avoid a tiny robot when lidar
            %   is displayed.
            %
            %   c) Starts the inactivity stopwatch that shuts this off
            %   after inactivity
            %
            %   d) Starts the suspendable clock.
            %   
            %   e) Starts the interval timer (if not in manual mode).
            %
            %
            do_sim = true;

            if(nargin == 1 && islogical(varargin{1}))
                do_sim = varargin{1}; % optional id argument is not present
            end
                
            if(nargin >=1) 
                if(islogical(varargin{1})) 
                    do_sim = varargin{1}; % optional id argument is not present
                elseif(isnumeric(varargin{1}) && islogical(varargin{2}))
                    do_sim = varargin{2}; % optional id argument is present
                end
            end
                
            if(do_sim)
                rIF.rob = simRobotIF(varargin{:});
            else
                rIF.rob = realRobotIF(varargin{:});
            end
            
            % create the figure / display list
            createFigure(rIF,rIF.rob.initial_pose);
                        
            % Set viewport for real robot.
            if(~do_sim)
                rIF.setAxes([-1.5 1.5 -1.5 1.5]); % set viewport size. It will still track
                set(rIF.figHandle,'visible','off');
            end
            
            % Start clock for sim. Must precede start of
            % persistent timer.
            fprintf('robotIF: Starting suspendable clock\n'); % this should happen only once per run
            rIF.rob.sus_clock.start();
                        
            % Start inactivity stopwatch. Must precede start of
            % persistent timer.
            rIF.last_cmd_stop_watch = tic();
            
            % Create the persistent timer, if needed
            if ~rIF.rob.do_manual
                if(do_sim)
                    rIF.createTimer(1/rIF.sim_freq);
                else
                    rIF.createTimer(1/rIF.viz_freq);
                end
                rIF.startTimer();
            end
            
            % The following code creates a variable named "cleanup_object"
            % in the scope of the MATLAB base and then associates
            % rIF.killTimer with that variable as the onCleanup function. The
            % net effect of this is that when the command dialog deletes
            % this object (which unfortunately is not when the application
            % exits), the killTimer function will be called and the timer is
            % then deleted in the killTimer function. This means a "clear
            % all" will kill the timer and you will not have to issue a
            % delete(timerfindall) to kill it. BTW, when the timer is
            % running, it continues redrawing the window so you cannot pan
            % and zoom the sim window when it is running. The robotIF
            % destructor is NOT called without this because the persisent
            % timer points to it!!!
            clnup = onCleanup(@() killTimer(rIF)); 
            assignin('base', 'cleanup_object', clnup);
        end
        
        function setAxes(rIF,axes)
            %setAxes sets the axes (viewport) of the main window.
            %
            %   setAxes([xmin xmax ymin ymax]) is the syntax.
            %
            rIF.scr_fig.setLimits(axes);
        end
        
        function addObjects(rIF,objs)
            %addObjects Adds object (shapes) to the display and world model.
            %
            %   rIF.addObjects(objs) Adds a shape(s) to the graphics
            %   display and, if in simulation mode, to the simulation world
            %   model.
            %
            rIF.scr_fig.addObj(objs);
            if(rIF.rob.do_sim)
                rIF.rob.addObjects(objs); % for rayCasting
            end
        end
     
        function manualUpdate(rIF)
            %manualUpdate Performs housekeeping and then calls the same update called by the timer.
            %   
            %   rIF.manualUpdate() 
            %
            %   Note: When graphics is expensive as it is
            %   here, you can ask for it too often, so this function
            %   controls how often the display is updated when it is not
            %   under timered control.
            %
            %   For your convenience, so thst you will not have to change your
            %   code when not in manual mode, it is OK to call this
            %   function in timered mode. If you do, you will get a harmless warning the
            %   first time you call it. Then and every time you call it, it will do nothing.
            %
            
            % exit if timer is on. warn once.
            if rIF.timerIsRunning() 
                if ~rIF.manual_ignored ; fprintf("Calls to manualUpdate ignored when timered\n"); end
                rIF.manual_ignored = true;
                if( rIF.rob.do_sim && ~rIF.rob.do_suspended_clock_sim)
                    fprintf('Updates may be faster than intended.\n');
                    fprintf('Turn on clock suspension for correct timing of manual sim\n');
                end
                return;
            end
            
            % We got this far, so timer is not running. Initialize on first entry
            t = rIF.rob.sus_clock.read();
            if ~rIF.man_inited
                rIF.last_man_time = t;
                rIF.man_inited = true;
            end
                        
            % Call update fcn
            rIF.localTimerFcn(rIF,0);
        end
        
        function killTimer(rIF)
            %killTimer Stops and deletes the persistent timer. 
            %
            %   rIF.killTimer() This is called when the robot object is
            %   deleted (e.g. when clear is commanded). You can use it
            %   yourself is you have an instance handle. Otherwise, use
            %   robotIF.deleteOldTimers().
            %
            if(isvalid(rIF.viz_master_timer))
                disp("robotIF: deleting persistent timer");
                stop(rIF.viz_master_timer);
                delete(rIF.viz_master_timer);
            end
            if(ishandle(rIF.figHandle))
                rIF.figHandle.set('HandleVisibility','on'); % Just in case, so we can delete it
                delete(rIF.scr_fig); % delete figure 99 and its display list
            end
        end
        
        function stopTimer(rIF)
            %stopTimer Stops (or pauses) the persistent timer.
            %
            % rIF.stopTimer() This can be useful if you call it at the end
            % of your script because it will free the simulator window to
            % be panned and zoomed and it will stop using CPU cycles. If
            % possible, call robot.stop() before stopping the timer because
            % the robot continues to move otherwise. Use 'clear all' if you
            % want to stop AND delete the timer, or close the window, or
            % call killTimer, or call deleteOldTimers().
            %
            fprintf('robotIF: stopping persistent timer\n');
            stop(rIF.viz_master_timer); %stop or pause the timer
        end
        
        function startTimer(rIF)
            %startTimer Starts (or restarts) the persistent timer. 
            %
            %   rIF.startTimer() This can be  useful to restart simulation
            %   if you stopped it for some reason.
            %
            fprintf('robotIF: starting timer\n');
            start(rIF.viz_master_timer); %start or restart the timer
        end
        
        function toggleVisibility(rIF)
            %toggleVisibility Toggles visibility of the main simulation window.
            %
            %   rIF.toggleVisibility() This does not prevent any computations other
            %   than those associated with actually drawing. it is also
            %   dangerous if you assume you know the sttae of the window
            %   and it is the opposite because it was not deleted last time.
            %
            if ishandle(rIF.ah)
                %hfig = get(get(rIF.ph(1,'parent'),'parent');
                hState = get(rIF.figHandle,'visible');
                switch hState
                    case 'on'
                        set(rIF.figHandle,'visible','off');
                    case 'off'
                        set(rIF.figHandle,'visible','on');
                end
            end
        end
        
        function setLidarSound(rIF,val)
            %setLidarSound Turns the lidar clicks on and off.
            %
            %   rIF.setLidarSound(val) Enables the sounds if val=true;
            %            
            rIF.do_lidar_sound = val;
        end
        
        function elapsedTime = toc(rIF)
            %toc Reads the time on the suspendable clock.
            %
            %   elapsedTime = rIF.toc() The suspendable clock is created
            %   when a real or simulated robot interface object is created.
            %   Simulation CPU cycles will be removed in the case of a
            %   simulated robot but otherwise, the clock behaves like
            %   toc(). You cannot call tic() on this clock.
            %
            elapsedTime = rIF.rob.sus_clock.read();
        end
            
        %   Following functions are provided to present one interface to the
        %   user. Numerous options were tested and there was no way to
        %   accomplish this via inheritance because these functions need to
        %   be implemented by EITHER simRobotIF or realRobotIF depending on
        %   whether we are in simulation mode or not.
        %
        
        function dS = do_sim(rIF)
            %do_sim Returns the value of the simulation flag.
            %
            %   dS = rIF.do_sim() 
            %
            dS = rIF.rob.do_sim;
        end
        
        function dM = do_manual(rIF)
            %do_manual Returns the value of the manual update flag.
            %
            %   dM = rIF.do_manual() 
            %
            dM = rIF.rob.do_manual;
        end
    
        function enc = encoders(rIF)
            %encoders Returns the most recent encoder message.
            %
            %   enc = rIF.encoders() or just rIF.encoders
            %
            enc = rIF.rob.encoders;
        end
        
        function lS = laser(rIF)
            %laser Returns the most recent laser laser.
            %
            %   lS = rIF.laser() or just rIF.encoders
            %
            lS = rIF.rob.laser;
        end
        
        function shutdown(rIF)
            %shutdown Shuts down the robot interface.
            %
            %   rIF.shutdown() 
            %
            rIF.rob.shutdown();
        end
        
        function sendVelocity(rIF,v_l, v_r)
            %sendVelocity Sends speed commands to the robot wheels.
            %
            %   rID.sendVelocity(v_l, v_r) Where v_l is left wheel velocity
            %   in m/s etc.
            %
            rIF.rob.sendVelocity(v_l, v_r);
            rIF.last_cmd_stop_watch = tic();
        end
        
        function stop(rIF)
            %stop Sends zero speed commands to the robot wheels.
            %
            %   rIF.stop()  Is much more reliable than sendVelocity(0,0).
            %
            rIF.rob.stop();
            rIF.last_cmd_stop_watch = tic();
        end
        function startLaser(rIF)
            %startLaser Starts the laser rotation and data stream.
            %
            %   rIF.startLaser() 
            %
            rIF.rob.startLaser();
            rIF.showStartLaser();
            rIF.last_cmd_stop_watch = tic();
        end
        function stopLaser(rIF)
            %stopLaser Stops the laser rotation and data stream.
            %
            %   rIF.stopLaser() 
            %
            rIF.rob.stopLaser();
            rIF.showStopLaser();
            rIF.last_cmd_stop_watch = tic();
        end
        function forksUp(rIF)
            %forksUp Lifts the forks.
            %
            %   rIF.forksUp() In simulation, will also detect if a pallet
            %   is sufficiently well position to be picked up. If so
            %   lifts and attaches the pallet to the forks. 
            %
            rIF.rob.forksUp();
            if(rIF.rob.do_sim)
                % get closest pallet in the world model
                frkToWld = robotModel.forkCenterPose(rIF.rob.sim_motion.pose);
                % NOTE: The robot is not in the world list, so this will not
                % return it.
                oB = rIF.rob.world_list.getClosestObjectToPose(frkToWld,palletSailModel.hole_width);
                if(~isempty(oB))
                    liftError = pose.poseError(frkToWld,oB.getMatToWorld(),palletSailModel.hole_width);
                    rIF.tryPalletLift(oB,liftError); % Take pallet off forks on screen
                end
            end
            rIF.showForksUp();
            rIF.last_cmd_stop_watch = tic();
        end
        
        function forksDown(rIF)
            %forksDown Lowers the forks.
            %
            %   rIF.forksDown() In simulation, will also detach an attached pallet. 
            %
            rIF.rob.forksDown();
            rIF.palletRelease(); % Take pallet off forks on screen
            rIF.showForksDown();
            rIF.last_cmd_stop_watch = tic();
        end
        
        function say(rIF,str)
            %say Speaks the supplied text string.
            %
            %   rIF.say(str) 
            %
            rIF.rob.say(str);
            rIF.last_cmd_stop_watch = tic();
        end
        
    end
    
    methods(Access = 'protected')
        function createTimer(rIF,timerPeriod)
            %createTimer Creates the persistent timer. 
            %
            %   rIF.createTimer(timerPeriod) This function is called by the
            %   constructor.
            %
            if(~rIF.rob.do_manual)
                rIF.viz_master_timer = timer(); % this is a call to the MATLAB timer constructor !
                rIF.viz_master_timer.Tag = 'raspbot_sim';
                rIF.viz_master_timer.ExecutionMode = 'fixedRate';
                % Queue mode is not supposed to interrupt itself but it does
                % seem to happen. Drop mode is probably best because it
                % should prevent the sim thread using the entire CPU.
                %rIF.viz_master_timer.BusyMode = 'queue';
                rIF.viz_master_timer.BusyMode = 'drop';
                rIF.viz_master_timer.TimerFcn = @rIF.localTimerFcn;
                %rIF.viz_master_timer.ErrorFcn = @rIF.ifTimerError;
                s = warning('off', 'MATLAB:TIMER:RATEPRECISION');
                rIF.viz_master_timer.Period = timerPeriod;
                warning(s);
            end
        end
                
%         function ifTimerError(~,~,~)
%             %ifTimerError Called by the timer if an errorr occurs.
%             % Deprecated.
%             %rIF.rob.sim_motion.dumpQueues();
%         end
        
        function localTimerFcn(rIF,~,ev)
            %localTimerFcn Called by the timer every time it fires. 
            %   
            %   rIF.localTimerFcn(r~,ev) After performing some
            %   concurrency housekeeping, calls the caller's timerFcn as well.
            %

            %   Although it is not supposed to happen in the queue timer
            %   mode, experiments confirm that MATLAB graphics events like
            %   opening a new window can cause the timer to interrupt
            %   itself. That leads to stopping a suspendable clock that is
            %   already stopped etc. so the in_update sempahore is used
            %   here to make this return immediately if the another thread
            %   in the timer is executing.
            %
            if(rIF.in_update)
                %fprintf("A previous update was interrupted\n");
                return;
            else
                rIF.in_update=true;
            end
            
            % Now call the user's timer function. The exception handler
            % produces much better error messages than none.
            try
                if(rIF.rob.do_sim)
                    rIF.rob.simUpdate(rIF,ev);
                else
                    rIF.rob.vizUpdate(rIF,ev);
                end
            catch me
                disp( getReport( me, 'extended', 'hyperlinks', 'on' ) );
                rIF.killTimer();
            end
            
            % Update display occasionally but not every data frame. In real
            % robot case, the timer is already 5 times slower, so there is
            % no need to count.
            if(~rIF.rob.do_sim || rIF.plot_cnt == rIF.plot_cnt_period)
				rIF.plot();
				rIF.plot_cnt = 0;
            end
            rIF.plot_cnt  = rIF.plot_cnt+1;
            
            % Check for inactivity
            if(toc(rIF.last_cmd_stop_watch) > rIF.max_time) % shutdown if we are doing nothing
                fprintf("robotIF: Robot shutdown. No activity for %6.3f seconds\n",rIF.max_time);
                str = sprintf("Turn off robot to save battery\n"); 
                rIF.say(str);
                beep();
                rIF.rob.shutdown();
                rIF.killTimer();
            end
            rIF.in_update=false;
        end
        
        function isRunning = timerIsRunning(rIF)
            %timerIsRunning Returns true if the timer is running.
            %
            %   isRunning = rIF.timerIsRunning()
            %
            
            isRunning = rIF.viz_master_timer ~= 0 && strcmp(rIF.viz_master_timer.Running,'on');
        end

        function createFigure(rIF,robot_pose)
            %createFigure Creates the main simulation window. 
            %
            %   rIF.createFigure() Because the window is also a display
            %   list you can add to it with addObjects before it is drawn on screen.
            %
            
%             f = figure('Name','Robot','visible','off',...
%                 'CloseRequestFcn',@robotIF.robotIF_closereq);
            f = figure(99);
            f.set('Name','Raspbot','CloseRequestFcn',@robotIF.robotIF_closereq);
            rIF.figHandle = f; 
            f.UserData = rIF;
            clf(f); % clears any remnants if persistent figure is reused from last run
            f.WindowStyle = 'docked';
            rIF.ah = gca();
            %rIF.ah = f.CurrentAxes; % does not work unless window is visible
            axis(rIF.ah,'equal');
           
            rIF.scr_fig = scrollFigure('Raspbot',rIF.ah);
            f.set('visible','off'); % now TURN IT OFF until something is drawn
            
            % add robot shape to window display list
            rIF.rS = raspbotShape(true,robot_pose); % true means with forks
            robot_plot_props = {'LineStyle','-','LineWidth',2,'Color',[.02 .3 .05]};
            forks_plot_props = {'LineStyle','-','LineWidth',2,'Color',[.02 .3 .05]}; % forks down color          
            both_plot_props = {robot_plot_props,forks_plot_props};
            rIF.rSdS = rIF.scr_fig.addObj(rIF.rS,both_plot_props{:});
            
            % add a circle shape to represent the light emitted on the
            % lidar. There is no such light on the real robot but it
            % represents the spinning nicely.
            rIF.dot_rad = 0.002; % 2 mm radius
            rIF.dot_orb = robotModel.laser_rad - 3.0*rIF.dot_rad; % orbit radius
            dot_pose = [rIF.dot_orb; 0; 0];
            rIF.dS = circleShape(rIF.dot_rad,robot_pose); % 2 mm radius
            rIF.dSdS = rIF.scr_fig.addObj(rIF.dS,'LineStyle','-','LineWidth',2,'Color',[.02 .3 .05]); % forks down color  
            rIF.rS.attach(rIF.dS); % attach dot to robot
            rIF.dS.setPoseWrtParent(dot_pose);
            
            % add point cloud shape to window display list
            ranges = zeros(360,1);
            rIF.rI = rangeImageShape(ranges);
            if(rIF.rob.do_sim)
                rIF.rI.setPoseAndUpdate(rIF.rob.laser_scan_pose);
            else
                rIF.rI.setPoseAndUpdate(rIF.rob.robot_pose); % real robot's have no laser_pose
            end
            rIF.rIdS = rIF.scr_fig.addObj(rIF.rI,'r.','MarkerSize',12);
            rIF.rIdS.setVisible('off'); % turn it off until we have data
            
            % open laser sound file to reduce overhead
            soundFile = "pop.wav";
            [rIF.lidar_sound_y,rIF.lidar_sound_Fs] = audioread(soundFile);
            
            f.set('HandleVisibility','callback'); % allows acccess in callbacks
        end
        
        function plot(rIF)
            %plot Draws the robot in a window in the context of other objects and data.
            %
            %   rIF. plot()This routine draws the robot, the lidar data, the walls
            %   and the pallets.
            %
            
            %if(nargin == 3); laser_pose = robot_pose; end % default laser pose is robot pose.
            % get out if there is no window to draw in
            if ~ishandle(rIF.ah); return; end
            
            % for simulator, get lidar pose. Otherwise, its same as robot
            robot = rIF.rob;
            if(rIF.rob.do_sim)
                robot_pose = rIF.rob.sim_motion.pose;
                % This laser pose eliminates jitter in simulator displays because the
                % robot often has moved past where the lidar image was generated.
                laser_pose = rIF.rob.laser_scan_pose;
            else
                robot_pose = rIF.rob.robot_pose;
                laser_pose = robot_pose;
            end
            % first call to plot turns the window on. Every other one
            % leaves it on. If walls are added after the robot is created,
            % the figure will show just the robot until the walls are
            % added and then it will resize automatically if axis is auto.
            set(rIF.figHandle,'visible','on'); 
            % Set the robot pose to the most recent
            rIF.rS.setPoseAndUpdate(robot_pose);
            if(rIF.anim_laser)
                % The lidar pose is updated only when the data is new.
                lidar_time = raspbot.timeFromStamp(robot.laser.LatestMessage.Header.Stamp);
                if(lidar_time > rIF.last_lidar_time) % plot only if data is new
                    rIF.rI.setPoseAndUpdate(laser_pose); % point cloud is in robot coordinates
                    ranges = robot.laser.LatestMessage.Ranges;
                    rIF.rI.setFilters(1,true); % no skip, do clean
                    rIF.rI.setRanges(ranges);
                    rIF.last_lidar_time = lidar_time;
                    rIF.rIdS.setVisible('on');
                else
                    % Turn off image so that dots do not lag robot. 
                    if(rIF.rob.do_sim)
                        rIF.rIdS.setVisible('off'); % do this only in simulation. Real may have no walls.
                    end
                end

            end
            % Animate lidar dot
            if(rIF.anim_laser)
                lidar_freq = 2.0; % rotate twice per sec
                dot_time = robot.sus_clock.read();
                dot_ang = 2*pi*lidar_freq*dot_time;
                dot_pose = [rIF.dot_orb*cos(dot_ang); rIF.dot_orb*sin(dot_ang); 0];
                rIF.dS.setPoseWrtParent(dot_pose);
            end
            % Show it all
            rIF.scr_fig.show();
            
            % This visibility of lidar switch is done because it is
            % less frequent than robot rendering so the robot drives past it. The
            % compromize is to turn lidar display off unless it is
            % current. 
            if(rIF.rIdS.getVisible())
                if(rIF.do_lidar_sound && rIF.lidar_sound_cnt >= 2) % 1 = every visible frame
                    sound(rIF.lidar_sound_y,rIF.lidar_sound_Fs);
                    rIF.lidar_sound_cnt = 0;
                end
                rIF.lidar_sound_cnt = rIF.lidar_sound_cnt+1;
            end
        
            drawnow; % this flushes event queue
            
            % The following commented out "hold off' turned out to be a
            % disastrous subtle bug, so leave it commented out. Its left
            % here to remind you not to do this. When the hold is off any
            % plotting to the window will erase everything in it. When the
            % fig99 handle is returned by gcf() or its axes by gca(), users
            % can trash the plothandles in all the graphics objects !!!! by
            % simply drawgin something in the window by mistake. With hold
            % on all the time, they can still draw in the window, but they
            % can also call hold off any time themselves and delete
            % everything. The moral is the the handle visibility for figure
            % 99 has to be off.
            %hold(rIF.ah,'off');
        end
        
        function tryPalletLift(rIF,pallet,liftError)
            %tryPalletLift Does.
            %
            %   rIF.tryPalletLift(pallet,liftError) Checks the provided
            %   pose error, presumed to represent the proximity to the closest pallet against
            %   if palletSailModel.pickup_err_thresh. If over 10 X, assume
            %   syou were not tryiung to pick something up. If < 1X picks it
            %   up and tells you. Otherwise, announces failure.
            %            
            if(liftError > palletSailModel.pickup_err_thresh*10) % assume you were not even trying
                return;
            elseif(liftError < palletSailModel.pickup_err_thresh)
                % attach the pallet !
                rIF.palletAttach(pallet);
                str = sprintf("Gotcha. Error was %3.1f cm",liftError*100); 
                rIF.say(str);
            else
                str = sprintf("Missed it by %3.1f cm",liftError*100);
                rIF.say(str);
                rIF.pS = [];
            end
        end
        
        function palletAttach(rIF,pallet)
            %palletAttach Attaches the pallet to the robot and indicates so on screen.
            %
            %   rIF.palletAttach(pallet) 
            %
            rIF.rS.attach(pallet);
            rIF.pS = pallet; % remember shape handle to put it back on floor
            rIF.pSdS = rIF.scr_fig.find(rIF.pS); % remember dispShape handle to change color back
            rIF.showPalletUp();
        end
    
        function palletRelease(rIF)
            %palletRelease Releases the pallet from the robot and indicates so on screen.
            %
            %   rIF.palletRelease() 
            %
            if( ~isempty(rIF.pS)) % if we have a pallet on the forks
                rIF.rS.detach(rIF.pS); % put in on the ground
                rIF.showPalletDown(); % change its color back
            end
        end
        
        function showForksUp(rIF)
            %showForksUp Changes the color of the forks to show they are up.
            %
            %   rIF.showForksUp() 
            %
            rIF.rSdS.setPlotSpec(2,'LineStyle','-','LineWidth',2,'Color',[.8  .3 .05]);
            rIF.rSdS.showShape();
        
            soundFile = "forksUp.wav";
            [y,Fs] = audioread(soundFile);
            sound(y,Fs);
        end
        
        function showForksDown(rIF)
            %showForksDown Changes the color of the forks to show they are down.
            %
            %   rIF.showForksDown() 
            %
            rIF.rSdS.setPlotSpec(2,'LineStyle','-','LineWidth',2,'Color',[.02  .3 .05]);
            rIF.rSdS.showShape();
            
            soundFile = "forksDown.wav";
            [y,Fs] = audioread(soundFile);
            sound(y,Fs);
        end
        
        function showStartLaser(rIF)
            %showStartLaser Starts laser animation.
            %
            %   rIF.showStartLaser() 
            %
            rIF.dSdS.setPlotSpec('LineStyle','-','LineWidth',2,'Color',[.8  .3 .05]);
            %rIF.scr_fig.showShape(rIF.dSdS);
            rIF.dSdS.showShape();
            rIF.anim_laser = true;
        end
        
        function showStopLaser(rIF)
            %showStopLaser Stops laser animation.
            %
            %   rIF.showStopLaser() 
            %
            rIF.dSdS.setPlotSpec('LineStyle','-','LineWidth',2,'Color',[.02  .3 .05]);
            %rIF.scr_fig.showShape(rIF.dSdS);
            rIF.dSdS.showShape();
            rIF.anim_laser = false;
%             if(rIF.audio_player.isplaying())
%                 rIF.audio_player.stop(); % does not seem to do anything
%                 delete rIF.audio_player; % this works though - NIOPE
%             end
        end
       
        function showPalletUp(rIF)
            %showPalletUp Changes pallet color to show it is lifted.
            %
            %   rIF.showPalletUp() 
            %
            rIF.pSdS.setPlotSpec('LineStyle','-','LineWidth',2,'Color',[.8  .3 .05]);
            %rIF.scr_fig.showShape(rIF.pSdS);
            rIF.pSdS.showShape();
        end
        
        function showPalletDown(rIF)
            %showPalletDown Changes pallet color to show it is dropped.
            %
            %   rIF.showPalletDown() 
            %
            %rIF.pSdS.setPlotSpec(palletSailShape.plot_props{:}); % can't figure out why this does not work
            rIF.pSdS.setPlotSpec('LineStyle','-', 'LineWidth', 2, 'Color','Blue');
            %rIF.scr_fig.showShape(rIF.pSdS);
            rIF.pSdS.showShape();
        end
   
    end
    
	methods (Hidden = true, Access = 'protected')   
        function delete(~)
            % Destructor
        end
    end
end
