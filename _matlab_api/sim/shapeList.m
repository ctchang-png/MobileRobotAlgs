classdef shapeList < cellList & configurable
    %shapeList A list of shapes.
    %
    %   The basic data structure is a cell vector of shapes. This class
    %   is used represent a long list of lines describing the world
    %   for simulation purposes. 
    %
    %   Via superclasses it combines all four aspects of multi-component
    %   structure, shape (boundary) definition, geometric linkage
    %   (configuration) and animation (motion). This class is the package
    %   that makes them all work together.
    %
    %   ShapeLists are configurables and so have poses relative to their
    %   parent. Because configurables are moveables, they also have poses
    %   wrt the world frame. This class constructor is the ultimate
    %   destination for a few layers of its own subclasses that create
    %   shapes for rendering and simulation. All of them accept the same
    %   arguments as shapeList and pass them here in order to convert a
    %   MATLAB cell vector of homogeneous point matrices into a "cellList"
    %   object as defined by this system with all of the features (imparted
    %   by shapeList superclasses) of animation/rendering, and motion and
    %   lidar simulation.
    %
    %   This class is "flattening" meaning ... if you add a tree or a list
    %   to this object, the structure-being-added is first broken into its
    %   components and the components are then added individually. That is
    %   desireable behavior when processing hierarchical shapes into a line
    %   segment list for use in lidar simulation.
    %
    %   ShapeLists are also used to "initially" define shapes for animation
    %   and simulation. That "initially" means that robot and pallets are
    %   created as a single list of parts. Later, however, they may be
    %   joined together in a more complicated cellTree structure by the
    %   process of attachment that lets the pallet, for example, move
    %   (temporarily) rigidly with the forks until it is placed on the
    %   floor again.
    %
    %   $Author: AlonzoKelly $  $Date: 2020/07/15 14:00:00 $ $Revision: 2.0 $
    %   Copyright: Alonzo Kelly 2020
    %
    
    properties (Constant = true)
    end
    
    properties (GetAccess = public, SetAccess = protected)
    end
    
    properties (GetAccess = public, SetAccess = private)
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
            
            % test the tricky add method
        end
    end
    
    methods (Access = public)
        function sL = shapeList(shapeOrShapes,varargin)
        %shapeList Creates a shapeList.
        %
        %   sL = shapeList() creates an empty list. 
        %
        %   sL = shapeList(poseWrtWorld) creates an empty list at the
        %   provided pose.
        %
        %   sL = shapeList(shapeOrShapes) also adds the a) animatedShape or
        %   b) cell vector of animatedShape or c) shapeList of animatedShapes
        %   detailed in shapeOrShapes.
        %
        %   sL = shapeList(shapeOrShapes,poseWrtWorld) also sets the pose of
        %   this list wrt the world.
        %
        %   sL = shapeList(shapeOrShapes,parentList) also places this new list
        %   inside of parentList.
        %
        %   sL = shapeList(shapeOrShapes,parentList,poseWrtParent) also sets
        %   the pose of this list wrt its parent list.
        %
        end
        
        function addObj(sL,shapeOrShapes)
        %addObj Adds to this shapeList.
        %
        %   sL.addObj(shapeOrShapes) initializes list and adds the a) animatedShape or
        %   b) cell vector of animatedShape or c) shapeList of animatedShapes
        %   detailed in shapeOrShapes. The superclass add method
        %   alone cannot be used here because animatedShapes need to be updated
        %   as soon as they are added. This code is tricky due to
        %   inheritance. When shapeOrShapes is a cell array, we call the cellList
        %   superclass. It then walks through the array and calls right
        %   back here to do the actual adding.
        %
        %   This addObj method (of cellList) deliberately performs flattening of trees
        %   into a single list of all the nodes in the tree.
        %
            
            % call array case - cellList is FLATTENING!!!
        end
        
        function updateChildren(sL)
        %updateChildren Updates all the children to reflect changes.
        %
        %   sL.updateChildren() Updates all the chidren to reflect changes.
        %   Whether the change was in the parent-relative pose or the
        %   world-relative pose of this object, the children need to update.
        %
        end
        
        function setPoseAndUpdate(sL,modWrtWldPose)
        %setPoseAndUpdate sets the latest poseWrtWld.
        %
        %   sL.setPoseAndUpdate(modWrtWldPose) Sets the latest poseWrtWld
        %   of this instance to the provided pose vector or HT and then
        %   updates all of the chidren to reflect the change.
        %
        end
        
        function plot(sL)
        %plot Plots the list in a figure. 
        %
        %   sL.plot() This is a handy way to visualize this class immediately once
        %   you create an instance.
        %
            %hfig = figure; 
        end  
    end
end













