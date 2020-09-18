classdef shapeTree < cellTree & shapeList & configurable
    % shapeTree A tree of shapes. 
    %
    %   This class is used to represent the relatively short, hierarchical,
    %   lists of lines that describe the shapes of objects. ShapeTrees are
    %   configurables and so have poses relative to their parent. Because
    %   configurables are moveables, they also have poses wrt the world
    %   frame.
    %
    %   Via superclasses it combines all four aspects of hierarchical
    %   structure, shape (boundary) definition, geometric linkage
    %   (configuration) and animation (motion). This class is the package
    %   that makes them all work together.
    %
    %   The main point of this class is to override the add method of
    %   shapeList to allow hierarchical structure. In contrast to
    %   shapeList, it is deliberately "non flattening". That means if you
    %   add a list to a shapeTree, is is added as a list rather than being
    %   broken into its components. That is desireable behavior for
    %   attaching and detaching objects from each other.
    %
    %   This class owns those magic attach() and detach() methods which look
    %   simple enough but are in fact based heavily on significant inherited
    %   infrastructure.
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
            
            % make a big U shaped polyLine
        end
        
        function testClass2()
            %testClass2 Some (more) convenient tests that can be run from the
            %console when you change something. Run this static method
            %with className.testClass. There is no need to create an
            %instance of the class.
            
            % This is a test of attachment and detachment. It also tests
            % whether it is necessary to delete a freestanding object form
            % the world list when it is attached. Unless something changes,
            % the answer is it is not necessary.
        end
    end
    
    methods (Access = public)
        function sT = shapeTree(varargin)
        %shapeTree Creates a shapeTree.
        %
        %   Arguments are compatible with shapeList except that another
        %   shapeTree is also acceptable both as an object to add and as
        %   a parent object.
        %
        end
        
        function addObj(sT,shapeOrShapes)
        %addObj Adds to this shapeTree.
        %
        %   addObj(shapeOrShapes) initializes list and adds the polyLine or cell
        %   vector of shapes detailed in shapeOrShapes. The superclass method
        %   alone cannot be used here because polyLines need to be updated
        %   as soon as they are added. This code is tricky due to
        %   inheritance. When shapeOrShapes is a cell array, we call the cellTree
        %   superclass. It then walks through the array and calls right
        %   back to here to do the adding.
            
            % call array case - cellTree is NON FLATTENING!!!
        end
        
        function attach(sT,obT)
        %ATTACH Attaches an object to this one.
        %
        %   attach(sT,obT) makes objT a direct descendant of this object.
        %   Their relative configuration is fixed at what it was the moment
        %   they were attached.
        %
        end
        
        function detach(sT,obT)
        %DETACH Removes an object from this one.
        %
        %   detach(sT,obT) detaches objT from this object and leaves it
        %   freestanding in the world. The pose of objT relative to the
        %   world remains unchanged.
        %   
        end
    end
end













