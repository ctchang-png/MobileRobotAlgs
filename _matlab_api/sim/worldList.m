classdef worldList < cellList
    %worldList A list of shapes that are used for physical simulation. 
    %
    %   This class exists so that dealing with animated graphics and
    %   physical world modelling can be based on a unified substructure
    %   that is compatible. The idea is when you add something to a world
    %   list (used for simulation), you can add the same thing to the
    %   graphics display list (used for animation and display) and both of
    %   the recipients know what to do with it. Then you have one handle to
    %   a physical thing instead of two handles to instances of two
    %   different classes stored in three places that have to
    %   be kept consistent.
    %
    %   In this system, the window displayList will accept hierarchical
    %   structure and drawing specification but the world model (this
    %   worldList object) will at some point extract all shapes into a
    %   linear array of line segments for efficient lidar simulation. 
    %   
    %   A key design driver is that lidar simulation (world modelling)
    %   needs a flat list of line segments while expressive object
    %   visualization requires multiple line segments per object, potentially
    %   arranged in a hierarchy. So, we need to be able to treat a shape
    %   both as a collection of individual lines and as a integral
    %   hierarchically-defined unit.
    %
    %   Therefore, in this class, when you add a shape to the worldList, it
    %   is stored for future reference but it is ALSO automatically broken
    %   into its constituent polyLines and handed to the lineMap data
    %   structure (stored herein) used in ray casting. Potential design
    %   upgrades would also support efficient collision detection in motion
    %   simulation based on those same line segments.
    %   
    %   When you delete the shape, all those constituent line segments
    %   implicitly tracked down and deleted because the shape that
    %   generates them is deleted. In case you
    %   are wondering, this class is not the same as a displayList because
    %   the latter is a list of displayedShapes, not shapes.
    %
    %   Note that while this class isa cellList of shapes, it also contains
    %   a lineMap which is a shapeList. The same shapes are now stored both
    %   in this class and in the worldList. Partly, this is because there
    %   are plenty of reasons to have shapes in a word that are not visible
    %   to lidar, so those shapes would not go in the line map.
    %
    %   $Author: AlonzoKelly $  $Date: 2020/07/15 14:00:00 $ $Revision: 2.0 $
    %   Copyright: Alonzo Kelly 2020
    %
    
    properties (Constant = true)
    end
    
    properties (GetAccess = public, SetAccess = protected)
    end
    
    properties (GetAccess = public, SetAccess = private)
        lin_map; % line map for raycasting
    end
    
    methods(Static)
    end
    
    methods (Access = public)
        function wL = worldList(varargin)
        %worldList Creates an instbnce of this class.
        %
        %   wL = worldList() creates an empty instance.
        %
        %   wL = worldList(shapes) initializes list and adds the lines
        %   detailed in shapes. The shapes argument is compatible with
        %   shapeList.
        %
        %   Note that while this class isa cellList of shapes, it also
        %   contains a lineMap which is a shapeList.
        %
        end
        
        function addObj(wL,shapes)
        %addObj Adds one or more shapes to the list.
        %
        %   wL.addObj(shapes) Will add the shapes to both this and the
        %   internal lineMap. The shapes argument is compatible with
        %   shapeList. Also, if shapes is a displayedShape, its contained
        %   shape is used instead. That is needed because displayedShape
        %   does not inherit from shape.
        %
        end
        
        function delObj(wL,shapes)
        %delObj Deletes one or more shapes from the list.
        %
        %   wL.delObj(shapes) Will delete the shapes from both this and the
        %   internal lineMap. The shapes argument is compatible with
        %   shapeList.
        %
        end
        
        function shape = getClosestObjectToPose(wL,ob2ToWld,len)
        %getClosestObjectToPose Gets the object whose pose is closest to the provided one.
        %
        %   shape = wL.getClosestObjectToPose(ob2ToWld,len) Finds the top
        %   level object whose pose is closest to the provided pose. len is
        %   the length to be used to scale orientation error.
        %
        end
        
        function hfig = plot(obj)
        %PLOT Plots the worldList in a new figure.
        %
        %   hfig = obj.plot()
        %
        end      
    end
    
    methods (Static = true)
    end
end













