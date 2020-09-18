classdef basicDisplayedShape < handle
    %basicDisplayedShape A class for a basicShape that draws itself in a window.
    %
    %   These objects can be drawn as a set of lines joining the points or
    %   as a set of markers at the points. In the former case, MATLAB will
    %   lift the "pen" when coordinates of points contain NaNs. This
    %   behavior is useful for efficient rendering of disconnected line
    %   segments in one call.
    %
    %   $Author: AlonzoKelly $  $Date: 2020/07/15 14:00:00 $ $Revision: 2.0 $
    %   Copyright: Alonzo Kelly 2020
    %
    properties(Constant)

    end
    
    properties(Access = public)
        shape;                  % The shape to be drawn
        axHandle;               % MATLAB axes to draw in
        plotSpec = {'LineStyle','-', 'LineWidth', 2, 'Color','Blue'}; % MATLAB line properties
		plotHandle = [];         % MATLAB plot function "line" object
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
        end
    end
    
    methods(Access = public)
        
        function dS = basicDisplayedShape(basicSh,axHandle,varargin)
            %basicDisplayedShape Creates an instance of this class.
            %
            %   basicDisplayedShape(basicSh,axHandle) creates and instance that wraps
            %   the provided shape (which must have a getShape() method to
            %   return its shape points) and will draw it in the provided
            %   axes in axHandle.
            %
            %   basicDisplayedShape(shape,axHandle,plotSpec) also accepts
            %   MATLAB line properties to override defaults and specify how the shape is to be
            %   drawn (color, linetype etc).
            %
        end
        
        function pH = setupForDrawing(dS,varargin)
            %setupForDrawing Creates a plotHandle and a plotSpec for this.
            
            % save the plotspec
        end
        
        function showShape(dS)
        %showShape Draws the shape in a figure.
        %
        %   The drawing will occur in the currently active figure or one
        %   will be created if none exists.
        %
            pts = dS.shape.getShape();
			if( ~isempty(pts) ) % plot only if we have data
                x = pts(1,:); y = pts(2,:);
                hold(dS.axHandle,'on');
                dS.plotHandle = plot(x,y,dS.plotSpec{:});
                set(dS.plotHandle,'visible','on');
                %hold(dS.axHandle,'off');
			end
		end
    end
end
    