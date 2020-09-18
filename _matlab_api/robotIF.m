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
    %   of objects in the window with disasterous results. The primitves
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
        end
         
        function robotIF_closereq(fig,~) % 2nd arg is callback data
        %robotIF_closereq Cleans up when you close the main window
        %
        %   robotIF.robotIF_closereq() is called when you close the main window It
        %   will delete any active timers before closing and deleting the
        %   window.
        %
        end
        
        function deleteOldTimers()
        %deleteOldTimers Deletes old timer(s) left in memory.
        %   
        %   robotIF.deleteOldTimers() Deletes older timers left over in
        %   memory. This is critical because they outlive the app that
        %   created them if not deleted in the app. Having more than one
        %   active timer breaks everything.
        %
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
        end
        
        function setAxes(rIF,axes)
            %setAxes sets the axes (viewport) of the main window.
            %
            %   setAxes([xmin xmax ymin ymax]) is the syntax.
            %
        end
        
        function addObjects(rIF,objs)
            %addObjects Adds object (shapes) to the display and world model.
            %
            %   rIF.addObjects(objs) Adds a shape(s) to the graphics
            %   display and, if in simulation mode, to the simulation world
            %   model.
            %
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
        end
        
        function killTimer(rIF)
            %killTimer Stops and deletes the persistent timer. 
            %
            %   rIF.killTimer() This is called when the robot object is
            %   deleted (e.g. when clear is commanded). You can use it
            %   yourself is you have an instance handle. Otherwise, use
            %   robotIF.deleteOldTimers().
            %
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
        end
        
        function startTimer(rIF)
            %startTimer Starts (or restarts) the persistent timer. 
            %
            %   rIF.startTimer() This can be  useful to restart simulation
            %   if you stopped it for some reason.
            %
        end
        
        function toggleVisibility(rIF)
            %toggleVisibility Toggles visibility of the main simulation window.
            %
            %   rIF.toggleVisibility() This does not prevent any computations other
            %   than those associated with actually drawing. it is also
            %   dangerous if you assume you know the sttae of the window
            %   and it is the opposite because it was not deleted last time.
            %
        end
        
        function setLidarSound(rIF,val)
            %setLidarSound Turns the lidar clicks on and off.
            %
            %   rIF.setLidarSound(val) Enables the sounds if val=true;
            %            
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
        end
        
        function dM = do_manual(rIF)
            %do_manual Returns the value of the manual update flag.
            %
            %   dM = rIF.do_manual() 
            %
        end
    
        function enc = encoders(rIF)
            %encoders Returns the most recent encoder message.
            %
            %   enc = rIF.encoders() or just rIF.encoders
            %
        end
        
        function lS = laser(rIF)
            %laser Returns the most recent laser laser.
            %
            %   lS = rIF.laser() or just rIF.encoders
            %
        end
        
        function shutdown(rIF)
            %shutdown Shuts down the robot interface.
            %
            %   rIF.shutdown() 
            %
        end
        
        function sendVelocity(rIF,v_l, v_r)
            %sendVelocity Sends speed commands to the robot wheels.
            %
            %   rID.sendVelocity(v_l, v_r) Where v_l is left wheel velocity
            %   in m/s etc.
            %
        end
        
        function stop(rIF)
            %stop Sends zero speed commands to the robot wheels.
            %
            %   rIF.stop()  Is much more reliable than sendVelocity(0,0).
            %
        end
        function startLaser(rIF)
            %startLaser Starts the laser rotation and data stream.
            %
            %   rIF.startLaser() 
            %
        end
        function stopLaser(rIF)
            %stopLaser Stops the laser rotation and data stream.
            %
            %   rIF.stopLaser() 
            %
        end
        function forksUp(rIF)
            %forksUp Lifts the forks.
            %
            %   rIF.forksUp() In simulation, will also detect if a pallet
            %   is sufficiently well position to be picked up. If so
            %   lifts and attaches the pallet to the forks. 
            %
        end
        
        function forksDown(rIF)
            %forksDown Lowers the forks.
            %
            %   rIF.forksDown() In simulation, will also detach an attached pallet. 
            %
        end
        
        function say(rIF,str)
            %say Speaks the supplied text string.
            %
            %   rIF.say(str) 
            %
        end
        
    end
    
    methods(Access = 'protected')
        function createTimer(rIF,timerPeriod)
            %createTimer Creates the persistent timer. 
            %
            %   rIF.createTimer(timerPeriod) This function is called by the
            %   constructor.
            %
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
        end
        
        function isRunning = timerIsRunning(rIF)
            %timerIsRunning Returns true if the timer is running.
            %
            %   isRunning = rIF.timerIsRunning()
            %
            
        end

        function createFigure(rIF,robot_pose)
            %createFigure Creates the main simulation window. 
            %
            %   rIF.createFigure() Because the window is also a display
            %   list you can add to it with addObjects before it is drawn on screen.
            %
            
%             f = figure('Name','Robot','visible','off',...
%                 'CloseRequestFcn',@robotIF.robotIF_closereq);
        end
        
        function plot(rIF)
            %plot Draws the robot in a window in the context of other objects and data.
            %
            %   rIF. plot()This routine draws the robot, the lidar data, the walls
            %   and the pallets.
            %
            
            %if(nargin == 3); laser_pose = robot_pose; end % default laser pose is robot pose.
            % get out if there is no window to draw in
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
        end
        
        function palletAttach(rIF,pallet)
            %palletAttach Attaches the pallet to the robot and indicates so on screen.
            %
            %   rIF.palletAttach(pallet) 
            %
        end
    
        function palletRelease(rIF)
            %palletRelease Releases the pallet from the robot and indicates so on screen.
            %
            %   rIF.palletRelease() 
            %
        end
        
        function showForksUp(rIF)
            %showForksUp Changes the color of the forks to show they are up.
            %
            %   rIF.showForksUp() 
            %
        end
        
        function showForksDown(rIF)
            %showForksDown Changes the color of the forks to show they are down.
            %
            %   rIF.showForksDown() 
            %
        end
        
        function showStartLaser(rIF)
            %showStartLaser Starts laser animation.
            %
            %   rIF.showStartLaser() 
            %
        end
        
        function showStopLaser(rIF)
            %showStopLaser Stops laser animation.
            %
            %   rIF.showStopLaser() 
            %
        end
       
        function showPalletUp(rIF)
            %showPalletUp Changes pallet color to show it is lifted.
            %
            %   rIF.showPalletUp() 
            %
        end
        
        function showPalletDown(rIF)
            %showPalletDown Changes pallet color to show it is dropped.
            %
            %   rIF.showPalletDown() 
            %
            %rIF.pSdS.setPlotSpec(palletSailShape.plot_props{:}); % can't figure out why this does not work
        end
   
    end
    
	methods (Hidden = true, Access = 'protected')   
        function delete(~)
            % Destructor
        end
    end
end
