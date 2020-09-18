classdef animatedShape < basicShape & shapeNode
    %animatedShape A class that holds a shape and updates it as an object moves.
    %
    %   This class is the workhorse of both animation and physical
    %   simulation. It adds to the basicShape both:
    %
    %   animation: the capacity be told to move (and update its shape points automtically)
    %
    %   configuration: the capacity to be connected to or contained inside other shapes. 
    %
    %   This class owns the transformed representation of a more basic shape. It isa
    %   moveable and that superclass is the mechanism by which it is made
    %   to move. BTW, that movement requirement is the driver for representing shape
    %   as a homogeneous array of points because such points can be
    %   transformed super fast by a single matrix multiply applied to a
    %   matrix of any muber of columns where every column is a homogeneous 
    %   point. MATLAB is impressively fast at transforming hundreds of
    %   points in this way.
    %
    %   This class isa shapeNode which isa configurable and those
    %   superclasses are the mechanism by which it can be articulated and
    %   attached or detached from other shapes.
    %
    %   In a nutshell, the basic shape information is in the basicShape,
    %   the pose information is in the moveable, the articulation information
    %   is in the configurable and the transformed shape is stored here.
    %
    %   The intention is that a given animatedShape (handle) will be
    %   referenced in two kinds of lists. One kind of list will be a
    %   displayList of shapes that is being drawn in in a window (MATLAB
    %   calls them figures). The same handle to an instance of this class
    %   can appear in any number of displayLists.
    %
    %   A second kind of list is a worldList of shapes whose purpose is 
    %   to characterise properties (such as shape, motion, mass properties,
    %   and lidar reflectivity) in a physical simulation
    %   
    %   When the world pose of the shape is changed in physical simulation,
    %   the world coordinate expression of all of its points will be
    %   updated by calling the updateShapeForMotion method here and every
    %   list with a handle to this instance will see those points move.
    %   Elsewhere in a shapeTree traversal, the word coordinates of
    %   all of its consituent shapes (if any) will be updated in a
    %   recursive traversal of the tree that again call the update method
    %   here to move all the points.
    %
    %   Again, this class is hierarchical and that makes animation and
    %   articulation easier. It also makes some things harder.
    %   Specifically, the animatedShape handle for all objects in the
    %   worldList will be regularly flattened. That process will produce
    %   one giant vector of the union of all of line segments for every
    %   lidar visibile surfaces of all of the components of all the shapes
    %   in the world. That instance will not normally call its
    %   updateShapeForMotion method. However once the shapes move the
    %   polyLines, they move in the world list too and raycasting
    %   automatically proceeds based on their latest poses.
    %
    %   $Author: AlonzoKelly $  $Date: 2020/07/15 14:00:00 $ $Revision: 2.0 $
    %   Copyright: Alonzo Kelly 2020
    %
    
    properties(Constant)

    end
    
    properties(Access = public)
        world_points = [];      % 3Xn array of 2D points in world coordinates
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
        
        function obj = animatedShape(mPts,myPoseWrtParent)
        %animatedShape Creates an instance of this class.
        %
        %   animatedShape() creates an empty instance
        %
        %   animatedShape(mPts) creates an instance with 3XN homogeneous array of
        %   points mpts to decribe its shape.
        %
        %   animatedShape(mPts,myPoseWrtParent) also sets the pose of this instance wrt its parent.
        %
            
        end
        
        function updateShapeForMotion(obj)
        %updateShapeForMotion Updates the coordinates of all the points.
        %
        % Points are updated based on the pose of the model frame wrt world
        % which is presumed to have been changed elsewhere (i.e. in some
        % simulation engine) to model motion.
        %   
            % Convert from model to world frame
        end
        
        function wPts = getShape(obj)
        %getShape Returns world_points array.
        %
        %   This function is used to provide the point vertices, as moved,
        %   expressed in world-fixed coordinates to any user class that
        %   needs them.
        %
        end
    end
end