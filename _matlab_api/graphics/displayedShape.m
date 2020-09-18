classdef displayedShape < basicDisplayedShape
    %displayedShape A shape that is displayed in a window (figure).
    %
    %   This class is used for persistent storage of the line specs and
    %   drawing handles etc associated with shapes that are displayed in a
    %   window. The value of storing all that stuff is that you can set it
    %   once and forget about it when animating shapes.
    %
    %   The pose and the shape of "shapes" is queried before every draw in
    %   the window drawing code in order to make animation as simple as
    %   changing the pose. However, if you want to change the lineSpec,
    %   call setupForDrawing in this class.
    %
    %   Because shapes are composed of a cell vector of body parts, this
    %   class creates a cell vector of plotHandles, each based on a
    %   provided plot spec so that there is one plotHandle per body part.
    %   PlotHandles are associated with a figure so putting the same shape
    %   in two figures requires two displayedShapes (but only one shape).
    %
    %   A plotHandle is a MATLAB line object (returned by the plot or line
    %   commands). A plot spec is a set of drawing attributes like
    %   {'LineStyle','--'}
    %
    %   $Author: AlonzoKelly $  $Date: 2020/07/15 14:00:00 $ $Revision: 2.0 $
    %   Copyright: Alonzo Kelly 2020
    %
    properties
        plotHandles;    % MATLAB line object handles for each part
        visible=true;   % Visibility flag. Applies to all its parts.
    end
    
    methods
        function dS = displayedShape(shape,axHandle,varargin)
            %displayedShape Construct an instance of this class.
            %
            %   displayedShape(shape,axHandle) creates a displayedShape
            %   in the provided axes with default plot specification.
            %
            %   displayedShape(shape,axHandle, plotSpec) will also accept any number 
            %   of MATLAB linetype, color, etc. specifications in plotSpec.
            %
            %   Provide the plotSpec just as you would in a call to MATLAB
            %   plot().
            %
        end
        
        function setupForDrawing(dS,varargin)
            %setupForDrawing Associates this shape with this figure.
            %
            %   Associates and remembers, for every part in this
            %   displayedShape, the plotHandle in these axes and the plot
            %   specification.
            %
        end
        
        function showShape(dS)
        %showShape Draws the components of the displayedShape. 
        % 
        %   This function exists so that hierarchical structure can be
        %   parsed correctly. A displayedShape may contain parts
        %   (shapeNodes) as well as other displayedShapes (shapeTrees). In
        %   the second case, when a part is itself a displayedShape, the
        %   function calls itself.
        %
        %   The design is such that a DisplayList is a list of
        %   displayedShapes at the top level. Each displayedShape will
        %   wrap a shape which often includes a list of "part" shapes.
        %   Furthermore, in order to support attachment, the parsing of the
        %   display list has to support other displayedShapes among the
        %   shapes. It was therefore tempting to duplicate the structure of
        %   a shape hierarchy and associate plotProps with every shape in
        %   the original shape hierarchy to produce a displayedShape
        %   hierarchy of mimicking structure. Ultimately this was not done
        %   for fear a) that it would be necessary to keep the two
        %   consistent through attachment, detachment, addition and
        %   deletion and b) that while it would be nice to be able to
        %   associate plotProps with every part of a shape, it would be
        %   tedious to always have to do so. In the present design, a list
        %   of plotProps is maintained in the displayedShape that
        %   corresponds to each part of the list of shapes in the
        %   top-level shape in the displayedShape. Furthermore, various
        %   traversals of a displayedShape tolerate and react properly to
        %   the appearance of a displayedShape in the hierarchy. This is
        %   the mechanism by which a pallet is attached to the forks, for
        %   example.
        %    
        end
        
        function setVisible(dS,val)
        %setVisible Sets the visibility flag for this shape.
        %
        %   This function is used to show the shape or
        %   not. Use the char array 'on' or 'off' for val.
        %      
        end
        
        function val = getVisible(dS)
        %getVisible Gets the value of the visibility flag.
        %
        %   Used to show the shape or not. Value is returned as a boolean.
        % 
        end
        
        function setPlotSpec(dS,varargin)
        %setPlotSpec Sets the plotting specification for this object.
        %
        %   Standard MATLAB Name-Value pairs are accepted. For example
        %   setPlotSpec(dS,'r-',Markersize,12). If the first argument is an
        %   integer, only that specific plotSpec (for part N) is changed.
        %   Doing so, requires you to know the order in which the subshapes
        %   were specified and added when the shape was constructed.
        % 
        end
    end
    
    methods(Access = 'private')
        
        function setAndPadPlotSpecs(dS,varargin)
            %setAndPadPlotSpecs Sets and pads the plotSpec cell array.
            %
            %   Sets and "pads" and empty slots with the first value if
            %   necessary to ensure that each part has a plotSpec.
            %
        end
        
        function pS = cellifyPlotSpec(~,pS)
            %cellifyPlotSpec converts a single plotSpec to a cell array.
            %
            %   This is a convenience so that you can specify something
            %   like (..,'LineWdith',12) in an argument list and it will be
            %   converted to internal form for you.
            %
        end
    end
end

