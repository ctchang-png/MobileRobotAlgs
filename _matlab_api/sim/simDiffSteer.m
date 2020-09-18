classdef simDiffSteer < handle
    %simDiffSteer Simulates a differential steer robot. 
    %
    %   Renamed from earlier "simRobot" because the entire simulator
    %   contains this class solely for the purpose of motion simulation.
    %
    %   Accepts left and right wheel commands or encoder readings for a
    %   differentially steered robot and integrates them with respect to
    %   time in the plane. Produces a pose estimate of the form [x y th].
    %
    %   Independently from the nature of time that is used, the class can
    %   be used for estimation if you drive it with encoder readings or for
    %   predictive control if you drive it with commands.
    %
    %   It actually makes sense to have up to three independent instances
    %   of this class - for reference trajectories, estimated trajectories,
    %   and simulation but it makes no sense to use one instance for any
    %   two or more more simultaneously.
    %
    %   Like almost any motion simulator, this class models the velocity
    %   kinematics of the platform, and it converts from commanded or
    %   sensed wheel velocities or distances to the resulting position and
    %   orientation by integrating a nonlinear underactuated kinematic
    %   differential equation. That is the easy part and it takes just a
    %   few lines of code.
    %
    %   A key design feature is accurate simulation of a fixed delay
    %   between the sending of commands to the robot and the resulting
    %   action. In the case where this object is driven by commands,
    %   they are placed in a FIFO implemented as a sliding vector so
    %   that an (interpolated and) delayed command is the one being
    %   simulated. Commands are assumed to arrive with monotone time tags
    %   and it is only possible to query the latest state. In effect, when
    %   driven by commands, this object simulates the data at RECIEVE TIME
    %   and the latest commands provided are treated as not having arrived
    %   yet. This interpolated FIFO business is an attempt to do this right
    %   because the problem requires you to deal with the fact that the
    %   delay is almost never an integer number of cycles of this
    %   simulator. Therefore, in addition to using a FIFO to model the
    %   delays, the FIFO has to be interpolated when the delayed time
    %   queried falls between two historical samples.
    %
    %   This class can be configured to work in "real time" (from the
    %   processor clock) or to work from "supplied time" - time tags on
    %   commands or sensor data; you choose which when the object is turned
    %   on and you have to stick with that choice afterwards. This is a
    %   design feature to prevent mixing up time sources (which cannot ever
    %   be correct). 
    %
    %   This feature matters because a) the clock on a remote robot is not
    %   even close to synchronized with the one used to run this object and
    %   b) even if it was, the delays and sampling of the signals going
    %   back and forth would make it irrelevant even if they were
    %   synchronized. The most accurate way to process incoming encoder
    %   data is to use the time tags produced on the robot but the most
    %   accurate way to model output command latency is to use the clock on
    %   this computer. Further complicating things is the fact that
    %   simulation takes significant processing so using a simulator slows
    %   down your controller algorithn and changes its real time
    %   performance for the worse. All of that adds up to it being best for
    %   this simulation purpose to use a) encoder time tags for state
    %   estimation and b) supplied time from a suspendable clock for
    %   processing commands. Neither of those is "real" in the sense of
    %   reading the actual clock on this computer but that option remains
    %   here so you can try it yourself.
    %
    %   As complicated as all that is, it makes controlling a simulated
    %   robot pretty close to the real thing from a timing point of view.
    %   All of that discussion is about how this simulator works. In your
    %   own control code, use real time (tic and toc) or robotIF.toc when
    %   controlling a real robot and ask the parent simulator of this
    %   object for the time on the suspendable clock when controlling the
    %   simulator.
    %
    %   Logging a dedicated number of samples of pose, command, and time is
    %   built-in for convenience if enabled in the constructor. This can be
    %   useful for producing plots to debug your code or to debug this
    %   class. As of now (May 2020) delayed velocity is interpolated at the
    %   encoder (state update) rate and this means the simulated robot will
    %   come to a stop tDelay seconds after the first zero command is
    %   issued.
    %
    %   This class is implemented to support concurrent programming despite
    %   MATLABs scant facilities to support it. In the absence of a test
    %   and set facility in MATLAB to implement a semaphone, the design
    %   performs all FIFO processing inside the call to updateState() and
    %   its descendants. That function is intended to tolerate being called
    %   inside a timer interrupt service routine (ISR) which is configured
    %   so that it runs to completion and cannot interrupt itself. The most
    %   "critical" code sections are those that update the FIFOs and shift
    %   the data. All three of the FIFOs for (vl,vr,t) must be in a
    %   consistent state and not in the middle of shifting when they are
    %   queried by the interp1 function. To ensure this, commands are
    %   placed in holding variables "lastvr" etc. by the user thread and
    %   then moved to the FIFOs in the ISR thread. A dozen other designs
    %   were tried and all did not avoid deadlock and/or inconsistent
    %   accesses. Of course, the holding variables could be queried in an
    %   inconsistent state too but in that case we are talking about smooth
    %   time signals rather than shifting data in memory, so the effects
    %   will be tolerable.
    %
    %   Due to the nondeterministic behavior of concurrent threads, you
    %   should not change that aspect of this class lightly. It was a
    %   painful process to get where we are. Note that adding printfs to
    %   debug it can change or eliminate the timing issues that caused the
    %   bug you are trying to find. Despite all that emphasis on
    %   concurrency, you do not have to use this class with two different
    %   threads. It is perfectly fine to send it commands or encoders using
    %   real or provided time and query state.
    %
    %   Because we are integrating a nonlinear DE here, it is a basic
    %   assumption that state updates are requested fast enough to reduce
    %   integration error to tolerable levels. There is no required update
    %   rate for commands though. You can send it just one and integrate it
    %   forever.
    %
    %   In the case of real-time, it is critical that you fire up the
    %   instance right before (and not "some time" before) you start
    %   feeding it commands or sensor readings. This makes the delays and
    %   time derivatives work correctly.  This 2020 update has also removed
    %   the need to "fire_up" this object externally in order to reduce the
    %   burden on the user. You can still do it but if you do not, it will
    %   be done when the first command or encoder frame comes in. Again,
    %   this last minute (microsecond?) fire up is important for delays and
    %   time derivatives to work correctly and it is a key pragma for
    %   tolerating MATLABs delayed parsing techniques. MATLAB was never
    %   intended to be real time so we merely do our best anyway.
    %
    %   Attempting to read past the FIFO on either end will now return the
    %   first or last element as appropriate. This feature should prevent
    %   MATLABs interp1 from ever returning a NaN -- which used to be a
    %   signficant failure mode.
    %
    %   Error models are used to corrupt both encoder data and outgoing
    %   commands by amounts that are peculiar to each robot id.
    %
    %   Sept 2013: Original design and first implementation by Al Kelly
    %   Sept 2014: Integration into MRPL course infrastructure by Mike Shomin
    %   June 2020: Redesign for better performance, more concurrency
    %   robustness, error models by Al Kelly
    %
    %   $Author: AlonzoKelly $  $Date: 2020/07/15 14:00:00 $ $Revision: 2.0 $
    %   Copyright: Alonzo Kelly 2020
    %
    
    properties(Constant)
        W  = robotModel.W;     % wheelTread in m
        W2 = robotModel.W2;    % 1/2 wheelTread in m
        maxFifo = 100;         % max length of command FIFOs (100)
        maxLogLen = 10000;     % max length of logging buffers
    end
    
    properties(Access = public)
        encoders = struct('LatestMessage',struct('Vector',struct('X',0,'Y',0))); % wheel encoders
        s = 0.0;            % distance traveled
        pose = [0;0;0];     % pose of robot
    end
    
    properties(Access = private)
        firedUp = false;        % off til first comand comes in
        realTimeMode = true;    % use a real clock or supplied time
        
        Vcd = 0.0; % linear velocity cmd delayed;
        wcd = 0.0; % angular velocity cmd delayed
        Va  = 0.0; % linear velocity act
        wa  = 0.0; % angular velocity act
        vlcd = 0.0; % left wheel velocity cmd delayed
        vrcd = 0.0; % right wheel velocity cmd delayed
        vlcu = 0.0; % undelayed vl
        vrcu = 0.0; % undelayed vr
        vla = 0.0;  % left wheel act speed
        vra = 0.0;  % rght wheel act speed
        startTic = 0;
        lastStateTime = 0.0;
        started = false;
        doLogging = false;
        doDebug = false;
        tdelay = 0.0;
        % holding area for commands while waiting for ISR
        lastvlcu=0.0; % left velocity undelayed cmd holding
        lastvrcu=0.0; % rght velocity undelayed cmd holding
        lastvtcu=0.0; % time of undelayed cmd holding
        % FIFO queues for commands
        vlcuHistory;   % left wheel speed undelayed command history
        vrcuHistory;   % rght wheel speed undelayed command history
        tHistory;  % time tag history
        
        stateLogIndex = 1; % index of last logged data point in the state arrays
        cmdLogIndex=1;     % index of last logged data point in the cmd arrays
        actLogIndex=1;     % index of last logged data point in the ct arrays
        
        logArrayT; % time log array
        logArrayS; % (signed) distance log array
        logArrayX; % x log array
        logArrayY; % y log array
        logArrayTh; % heading log array
        logArrayVcd; % linear velocity delayed cmd log array
        logArrayWcd; % angular velocity delayed cmd log array
        
        logArrayVlcd; % left wheel delayed cmd velocity
        logArrayVrcd; % right wheel delayed cmd velocity
        logArrayVlcu; % left wheel cmd undelayed velocity
        logArrayVrcu; % right wheel cmd undelayed velocity
        
        logArrayVa;  % linear act velocity
        logArraywa;  % rotary act velocity  
        logArrayVla; % left wheel act velocity
        logArrayVra; % right wheel act velocity  
    end
    
    properties(Hidden, Access = private)
        eM; % error model
    end
    
    methods(Static = true)
        
    end
    
    methods(Access = private)
        
        function logStateAndTimeData(obj)
            %logStateAndTimeData Stores state data in the logging buffers until they are full.
            %
            %   obj.logStateAndTimeData() Stores state data in the logging buffers.
            %
        end
        
        function logCmdVelocityData(obj)
            %logCmdVelocityData Stores commanded velocity  data in the logging buffers until they are full.
            %
            %   obj.logCmdVelocityData() Stores commanded velocity data in the logging buffers.
            %
        end   
        
        function logActVelocityData(obj)       
            %logActVelocityData Stores actual velocity  data in the logging buffers until they are full.
            %
            %   obj.logActVelocityData() Stores actual velocity data in the logging buffers.
            %
        
        end 

        function addCommands(obj,vl,vr,timeTag)
            %addCommands Adds the robot commands to the FIFO queue.
            %
            %   obj.addCommands(vl, vr, t) adds the left and right wheel 
            %   velocities vl and vr.  The time tag t is used for
            %   logging and time history.
            %
        end
        
        function updateDelayedCommands(obj,timeTag,delay)
            %updateDelayedCommands Implements a time delay on the robot commands.
            %
            %   obj.updateDelayedCommands(t, d) Updates the delayed velocities 
            %   obj.vlcd and obj.vrcd.  The time tag t is used for logging and time 
            %   history.
            %
        
            % check for queue underflow. Warn and move on. If this
            % happens, it is likely due to minor timing issues right after
            % object creation. It could also be that time tags are wrong or
            % FIFO is too short relative to delay and frequency of velocity
            % command updates. Or update freq is too high.
        end
                        
        function updateStateStep(obj,time,doLimiting)
            %updateStateStep Updates state based only on the passage of the
            % supplied time step and the active commanded velocities.
            %
            %   obj.updateStateStep(t) updates the state using the difference
            %   between the time of the last update and the supplied time t.
            %
        end
        
        function sendVelocityStep(obj,vl,vr,time)
            %sendVelocityStep Sends commands to the left and right wheels. Note
            % that the commands are sent through a FIFO so these commands will
            % actually affect the prediction/estimation after the delay has
            % elapsed.  The delay is affected in continuous time with linear
            % interpolation of the command FIFO.
            %
            %   obj.sendVelocityStep(vl, vr, t) sends left and right wheel
            %   velocity commands vl and vr to the simulated robot.  The time t
            %   is used as the time tag for the delayCommands function.
            %
            
            % Corrupt velocities by noise model before they are staged
        end
        
        function checkRealTimeMode(obj,mode,time)
            %checkRealTimeMode Panics if the wrong time is used in a public method.
            %   obj.checkRealTimeMode(m) throws an error if the mode of the
            %   simulated robot and the supplied mode do not match.            
            
            % Fire up if needed
        end
          
    end
            
    methods(Access = public)
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Constructor and Related Methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function obj = simDiffSteer(tdelay,pose,leftEnc,rightEnc,doLogging,errModel)
            %simDiffSteer Constructs a simDiffSteer. 
            %
            %   robot = simDiffSteer(tdelay, pose, leftEnc, rightEnc, log)
            %   constructs a simulated robot at coordinate (x,y) with
            %   orientation theta (taken from pose = [x; y; theta]).  Commands
            %   will be delayed by time tdelay.  Initial encoder values for the
            %   left and right wheels are leftEnc and rightEnc, respectively.
            %   Logging is turned on if log = true and off if log = false.
            %
            %   After construction you must then "fireUp" the simulation RIGHT
            %   BEFORE you start using it in real time so that the simulation
            %   delay works correctly. If you forget, it will be done for you,
            %   and that is probably the better performance option.
            %
        
            %   Initialize handle classes
        end
        
        %
        function initializeHandleClasses(obj)
            %initializeHandleClasses Initializes all of the properties for this object that 
            % are handle classes. 
            %
            %   See this article: 
            %   https://www.mathworks.com/help/matlab/matlab_oop/specifying-properties.html#br18hyr.
            %   Initialization of properties that are handles are performed only
            %   when MATLAB loads the class.That would mean that multiple
            %   instances of this clqss aould share the same command history.
            %   That would be flat wrong for the purpose here. Ecen though there
            %   is no obvious need to create two simulators, the timers used to 
            %   force regular updates are persistent if not shut down properly
            %   and that leads to two instnces of this calss existing at the same
            %   time. Bottom line of all of that is thAt this function is an
            %   insurance policy that prevents you from searching for impossible
            %   to find random bugs related to FIFO queues when a second (maybe
            %   invisible) instance of this class is running.
                    
        end   
                
        function dumpQueues(obj)
            %dumpQueues Dumps the contents of the FIFO queues. 
            %
            %   obj.dumpQueues() Dumps the contents of the FIFO queues. use
            %   this like a core dump if there is a fatal error.
            %
        
            %fprintf("time is:%f\n",toc(obj.startTic)); 
            
        end
        
            
        function fireUpForRealTime(obj)
            %fireUpForRealTime Starts the clock for real time sim.
            %
            %   Also puts the sim in real time mode where state updates will be
            %   tagged based on true elapsed time. Calls
            %   fireUpForSuppliedTime() for the present time.
            %
        end
        
        function fireUpForSuppliedTime(obj, time)
            %fireUpForSuppliedTime Starts the clock for supplied time sim.
            %
            %   obj.FIREUPFORSUPPLIEDTIME(t) starts the simulation clock and
            %   supplies the given time t to simulation functions.
            %
            %   Starts the clock and puts the robot in simulated time mode
            %   where state updates will be tagged based on true supplied time.
            %   Save the present state as the start state. Issue and pad the
            %   command history with zero commands. Call this right before you
            %   want to use the object in real time so that the time taken to
            %   set it up does not corrupt the clock.
            %
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Control and Estimation Methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        

        function stop(obj)
            %stop Sends zero velocity to stop the robot.
            %
            %   obj.stop() Sends zero velocity to stop the robot.
            %
        end
        

        function stopAtTime(obj,time)
            %stopAtTime Sends zero velocity to stop the robot.
            %
            %   obj.stopAtTime(time) Sends zero velocity to stop the robot with
            %   the indicated time tag.
            %
        end
        
        function sendVelocity(obj,vl,vr)
            %sendVelocity Sends velocity commands to the left and right wheels.
            %
            %   obj.sendVelocity(vl, vr) commands the simulation to apply
            %   velocity vl to the left wheel and velocity vr to the right
            %   wheel. Calls sendVelocityForSuppliedTime for the present time.
            %
        end
        
        function sendVelocityAtTime(obj,vl,vr,time)
            %sendVelocityAtTime Sends velocity commands with the provided time tag.
            %
            %   obj.sendVelocityAtTime(vl, vr, t) commands the simulation to
            %   apply velocity vl to the left wheel and velocity vr to the
            %   right wheel at time t.
            %
            %   Note that the commands are sent through a FIFO so these
            %   commands will actually affect the prediction and estimation
            %   after the delay has elapsed. The delay is effected in
            %   continuous time with linear interpolation of the command
            %   FIFO.
            %

        end
        
        function setDebug(obj)
            %setDebug Used to turn on debugging for this instance only. 
            %
            %   You can insert code and test (obj.debug == true) to activate it.
            %
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Update State Methods
        %
        % The next three methods are used to update the state. Both
        % updateState() and updateStateFromEncoders() call
        % updateStateStep() and the latter will call the logger to log all
        % the data.
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
        function updateState(obj)
            %updateState Updates state based only on the passage of real time.
            %
        end
        
        function updateStateAtTime(obj,time)
            %updateStateAtTime Updates state based on a supplied time.
            %
            %   obj.updateStateAtTime(t) updates the simulation state based on
            %   the supplied time t.
            %
        end

        function updateStateFromEncodersAtTime(obj,newLeft,newRght,time)
            % updateStateFromEncodersAtTime updates posn and orientation.
            %
            %   obj.updateStateFromEncodersAtTime(newL, newR, t) updates the
            %   simulated wheel and body velocities using encoder values from
            %   the left and right wheels (newL and newR, respectively) and the
            %   supplied time t.
            %
            %   Sets wheel and body velocities based on encoders and supplied
            %   time tag and then integrates.
            %

        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Access Methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function [V, w] = getDelayedVw(obj)
            %getDelayedVw Returns the most recent velocity commands processed. 
            %
            %   [V, w] = obj.getDelayedVw() These are delayed because they went
            %   through the velocity command FIFO.
            %
        end
        
        function pose = getPose(obj)
            %getPose Returns the most recent computed pose.
            %
            %   pose = obj.getPose()
            %
        end
        
        function time = getlastStateTime(obj)
            %getlastStateTime Returns the most recent computed time.
            %
            %   time = obj.getlastStateTime()
            %
        end
        
        function dist = getDistance(obj)
            %getDistance Returns the most recent computed distance.
            %
            %   dist = obj.getDistance()
            %
        
        end
            
    end
end