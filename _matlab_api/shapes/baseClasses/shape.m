classdef shape < shapeTree
    %shape A class to create commonly used graphics entities.
    %
    %   Shapes are polyLines and polymarkers represented in their own
    %   model coordinates which are then rendered in a window (figure) 
    %   at a specified position and orientation. This class is intended to
    %   be the superclass to the shapes created by users. By inheriting
    %   from here, you get a pose for animation and hieratchical
    %   structure for articulation and plot properties for drawing.
    %
    %   Shapes are 2D in this system so there is no z coordinate and there
    %   are no surfaces, just lines (segments) and points. There are colors
    %   and line and marker types though - inherited from MATLAB.
    %
    %   For convenience, shapes are designed to remember their pose in
    %   world coordinates, so you can set it and forget it. On the other
    %   hand, that means if you want to have more than one of them in
    %   different places, you have to create multiple instances. This
    %   feature is primarily useful when an application thread does the
    %   animation (sets the pose) but a separate graphics thread does the 
    %   drawing. You can add the same shape to multiple windows and it
    %   will move identically in all of them.
    %
    %   In order to accomodate "pen up" drawing and articulation, the shape
    %   of a shape is represented as a list of point arrays called "parts"
    %   and the pen is up between the drawing of parts because each is
    %   rendered with a separate call to MATLAB's plot function. You can
    %   even write the shape description function to convert articulated
    %   components to a common body (model) frame in order to visually
    %   capture articulation of the parts with respect to each other. There
    %   are other ways to lift the pen at lower levels of the code
    %   hierarchy. See polySegment.
    %
    %   Under the hood, this class is based on a shapeList just as the
    %   lineMap class is. That means when you add a shape to a lineMap, the
    %   structures are compatible and everything related to ray casting
    %   just works.
    %
    %   As of now, this class does not do much other than provide a test
    %   routine. Derived classes could inherit from shapeList but having
    %   this class in the middle of the hierarchy is probably more
    %   readable.
    %
    %   $Author: AlonzoKelly $  $Date: 2020/07/15 14:00:00 $ $Revision: 2.0 $
    %   Copyright: Alonzo Kelly 2020
    %
    
    properties (Constant, Abstract)
        plot_props;
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

        end
    end
        
    methods
        function obj = shape(parts,varargin)
            %shape Construct an instance of this class
            %
            %   shape(parts, varargin) constructs a shape at the world origin whose
            %   parts are shapeNodes (usually articulatedShapes) specified
            %   in the cell vector called parts. Any other arguments in
            %   varargin are compatible with shapeList.
            %
            
            % Create the cellTree of polyLines from the parts
        end       
    end
end

