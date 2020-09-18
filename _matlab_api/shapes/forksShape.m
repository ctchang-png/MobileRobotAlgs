classdef forksShape < shape
    %forksShape A Raspbot forks shape.
    %
    %   A Raspbot forks shape. This class merely computes points on the
    %   shape outline for you and most other relevant functionality comes
    %   from superclasses.
    %
    %   This shape is left detached from the robot to give the user one
    %   option to allow it to have separate plot properties. If you do not
    %   need a separte color etc for the forks, just set the do_forks flag
    %   when you create a raspbot and you will get forks of the same color.
    %   Even then, you can still set the plot properties of the 2nd part of
    %   a robot shape that was built with do_forks on.
    %
    %   $Author: AlonzoKelly $  $Date: 2020/07/15 14:00:00 $ $Revision: 2.0 $
    %   Copyright: Alonzo Kelly 2020
    %   
    properties(Constant)
        plot_props = {'LineStyle','-','LineWidth',2,'Color',[.02 .3 .05]}; % forks dwn props
    end
    
    properties
        frdn_props = {'LineStyle','-','LineWidth',2,'Color',[.02 .3 .05]}; % forks dwn props
        frup_props = {'LineStyle','-','LineWidth',2,'Color',[.8  .3 .05]}; % forks up props
    end
    
    methods(Static)     
        function parts = makeBodyPoints()
            %makeBodyPoints Creates the shape in body coordinates.
            %
            %   Creates the shape in body coordinates.   
            %
        end
        
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
        end
    end
    
    methods
        function obj = forksShape(varargin)
            %forksShape Constructs an instance of this class.
            %
            %   forksShape(varargin) constructs a forksShape.
            %   Arguments "varargin", if present, are compatible with shapeList.
            %
        end
    end
end