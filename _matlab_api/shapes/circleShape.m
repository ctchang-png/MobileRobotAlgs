classdef circleShape < shape
    %circleShape A circle shape.
    %
    %   A circle shape. This class merely computes points on a circle
    %   for you and most other relevant functionality comes from
    %   superclasses.
    %
    %   $Author: AlonzoKelly $  $Date: 2020/07/15 14:00:00 $ $Revision: 2.0 $
    %   Copyright: Alonzo Kelly 2020
    %
    
    properties(Constant)
        plot_props = {'LineStyle','-','LineWidth',2,'Color','Black'}; % drawing specification
    end
    
    properties
        radius; % radius of the circle
    end
    
    methods(Static)     
        function parts = makeBodyPoints(radius)
            %makeBodyPoints Creates the shape in body coordinates.
            %   Creates the shape in body coordinates.
            
            % angle arrays
        end
    end
    
    methods
        function obj = circleShape(radius,varargin)
            %circleShape Construct an instance of this class.
            %
            %   circleShape(radius,varargin) constructs a circle of the
            %   indicated radius. Arguments "varargin", if present, are compatible
            %   with shapeList.
            %
        end
    end
end