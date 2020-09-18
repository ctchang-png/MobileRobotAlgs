classdef shapeNode < configurable
    %shapeNode A leaf node in a shapeTree.
    %   
    %   Although this class isa configurable, it does not have any
    %   component parts. That aspect is added in the derived class called
    %   shape < shapeTree. The distinction allows us to distinguish
    %   between the thing that contains things and one of the things
    %   contained. In other words, a shape can contain other shapes or
    %   animatedShapes but an animatedShapes is a leaf in the
    %   hierarchy and it cannot contain anything.
    %
    %   $Author: AlonzoKelly $  $Date: 2020/07/15 14:00:00 $ $Revision: 2.0 $
    %   Copyright: Alonzo Kelly 2020
    %
    
    properties
        Property1
    end
    
    methods
        function obj = shapeNode()
            %shapeNode Create an instance of this class
            %   shapeNode() creates an empty instance
        end
    end
end

