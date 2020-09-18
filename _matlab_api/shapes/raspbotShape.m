classdef raspbotShape < shape
    %raspbotShape A Raspbot Shape.
    %   A Raspbot shape. The instance may or may not have forks attached.
    %   The geometry is defined in the robotModel class.
    %
    %   $Author: AlonzoKelly $  $Date: 2020/07/15 14:00:00 $ $Revision: 2.0 $
    %   Copyright: Alonzo Kelly 2020
    %
    
    properties(Constant)
        plot_props = {'LineStyle','-','LineWidth',2,'Color',[.02 .3 .05]}; % drawing specification
    end
    
    properties
        do_forks; % construct forks if true
    end
    
    methods(Static)     
        function parts = makeBodyPoints(do_forks)
            %makeBodyPoints Creates the shape in body coordinates.
            %
            %   makeBodyPoints(do_forks) creates the shape and will add
            %   forks if do_forks is true.
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
        function obj = raspbotShape(do_forks,varargin)
            %raspbotShape Constructs an instance of this class.
            %
            %   raspbotShape(do_forks,varargin) Set do_forks to have forks
            %   drawn with the shape. You can also create your own forks
            %   shape with forksShape and attach it.   
            %
            %   Arguments "varargin" are compatible with shapeList.
            %
        end
    end
end