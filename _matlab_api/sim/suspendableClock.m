classdef suspendableClock < handle
    %suspendableClock A layer over the system clock that makes it suspendable.
    %
    %   This class is a layer over the system clock that allows it to be
    %   started and stopped in controlled circumstances. This type of clock
    %   is useful in real time control and simulation in order to be able
    %   to:
    %
    %   a) start the measurement of time once set up operations have
    %   finished.
    %
    %   b) make CPU cycles used to simulate something disappear from your
    %   measure of elapsed time
    %
    %   This object is neither an interval timer nor a stopwatch timer,
    %   both of which MATLAB already provides. You create an instance of
    %   this and you "read" the time as often as you like. Typically,
    %   you will never reset it but you may start and stop it very often
    %   when running a simulator. More likely, the simulator will do that
    %   for you and you need not care. The time it reports is relative to
    %   the moment it was started so it is not "time of day" but rather is
    %   the elapsed time since it was started. Under the hood, this is
    %   based on tic() and toc(). 
    %
    %   Like tic() and toc(), the implementation is lightweight so there is
    %   no point using the same clock for two purposes and doing fancy math
    %   to make it work. You can create as many of these objects as you
    %   like and start them all at a slightly different moment.
    %
    %   On the other hand, there are times when you should read THE clock
    %   because there is only one purpose, controlling a robot, and all of
    %   the time tags on all of the data must be absolutely consistent.
    %   The raspbot robot base class creates and starts a suspendable clock
    %   that you should probably treat as THE clock in your controller
    %   algorithms. If you do, they will probably perform close to the same
    %   in simulation as they do on the real robot even though they may be
    %   running much more slowly. You can access this clock by calling the
    %   toc() method on an instance of robotIF. 
    %
    %   The advance function is useful if you have calls to clock functions
    %   in your code but you want to explicitly control the apparent time
    %   elapsed regardless of how much time has actually elapsed. It may be
    %   easier to do that than to track down and alter every clock read in
    %   your code.
    %
    %   $Author: AlonzoKelly $  $Date: 2020/07/15 14:00:00 $ $Revision: 2.0 $
    %   Copyright: Alonzo Kelly 2020
    %
    
    properties(Access = public)
        MATLABTimer % time base tied to the local processor
        lastStartTime; % last start time (from timer)
        lastStopTime; % last stop time (from timer)
        lostTimeIntegral; % integral of all periods when clock was off
        running = false;
        debug=false; % for use in conditional breakpoints
    end
    
    methods(Access = public)
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Constructor and Related Methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function obj = suspendableClock()
        %suspendableClock Construct a suspendableClock. It starts out in stopped mode.
            % Create the system clock
        end
        
        function t = start(obj)
        %start Start the clock at zero. Returns current time on clock. 
        end
        
        function t = stop(obj)
        %stop Stop the clock. Returns current time on clock. 
        end
        
        function t = advance(obj,dt)
        %advance the time by the indicated amount. Returns current time on clock. 
        %
        %   The clock must be
        %   stopped. Returns current time on clock.
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Access Methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function t = read(obj)
        %read Returns the time elapsed since this clock was started. Works like toc().
        end
                
        function r = isRunning(obj)
        %check if clock is started
        end

    end
end