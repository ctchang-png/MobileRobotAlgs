classdef robotBaseClass < handle
    %robotBaseClass The base class for real and simulated robots
    %
    %   This class holds the methods and properties that are common to all
    %   robots. It is not called "robot" so that it will not conflict with
    %   that common variable name.
    %
    %   A suspendable clock is created in this class that can be used as
    %   the time standard for the entire application. Derived simulators
    %   will suspend this clock so that, if you read this clock. simulation
    %   will not affect the real time performance of your application code
    %   because simulation will appear to happen in zero time. Such
    %   suspended clock simulation is turned on by default.
    %
    %   $Author: AlonzoKelly $  $Date: 2020/07/15 14:00:00 $ $Revision: 2.0 $
    %   Copyright: Alonzo Kelly 2020
    %
    
    properties (GetAccess='public', SetAccess='private')
        id = 0;                 % robot unique id number
        do_sim=true;            % simulation if on. Defaults to on.
        initial_pose=[0;0;0];   % initial pose. defaults to [0;0;0]        
        do_manual=false;        % manual updates (no interval timer) if on. Defaults to off.
        sus_clock;              % suspendable clock used to make sim cycles disappear
    end
    
    properties (Hidden, GetAccess='public', SetAccess='private')
        do_suspended_clock_sim=true; % true is the default and better "supplied time" option that hides sim CPU cycles  
    end
    
    properties (Hidden, GetAccess='protected', SetAccess='protected')
        eM = errorModel(); % systematic and stochastic errors
    end
    
    methods (Static)
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
            
            % This testClass is a test of all of the constructor signatures
        end
    end
    
    methods
        function r = robotBaseClass(id,do_sim,initial_pose,do_manual)
            %robotBaseClass Constructs an instance of this class.
            %
            %   r = robotBaseClass(id,do_sim,initial_pose,do_manual) creates a
            %   robot with the indicated id, sim flag, initial pose and
            %   manual flag settings. Any argument can be missing and if it
            %   is, it will be set to a default value and argument scanning
            %   will skip over it. Arguments are consumed as soon as
            %   possible so a single logical argument is taken to mean
            %   do_sim rather than do_manual.
            %
            
            % Optional arguments are tricky to parse. The following
            % argument parsing could instead have been done by declaring
            % varargin (it is not there if you do not declare it) but I
            % thought the following might be more readable.
            
        end
    end
    
    methods(Hidden, Access = private)
        function makeErrorModel(r)
            %makeErrorModels creates the error model for the robot.
            %
            %   The model is based on using the positive integer id of the
            %   robot as the seed in a random number generator. Initial
            %   testing shows that calling rng(n) for integer n caluses the
            %   same sequence of results to be returned by subsequent calls
            %   to randn(). In other words, the random errors that are
            %   computed once and used here for the systematic parameters
            %   will be the same from one run to the next.
            %	
            
            %   The techique is a little tricky. We will use a random
            %   number generator here to compute the systematic errors and
            %   then leave them fixed for the life of the application, and
            %   based on reusing a seed, they are fixed forever. On the
            %   other hand the variances of the random errors are fixed
            %   here but the instantaneous magnitude of those errors are
            %   computed when needed in the simulation algorithms.
            
            %   Magnitude of noise used to auto generate systematic errors
            %   Using 0.01 means the error should be under 3% (3 sigma) at a
            %   frequency of 99% of the time.
        end
    end
end

