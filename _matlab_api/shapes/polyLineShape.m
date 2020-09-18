classdef polyLineShape < shape
    %polyLineShape A polyLine Shape.
    %
    %   A polyLine shape is a fairly general way to represent shapes
    %   defined by a set of (x,y) coordinates. This class is provided so
    %   that users have a general tool that can represent anything.
    %   Remember the capital L when spelling it.
    %
    %   $Author: AlonzoKelly $  $Date: 2020/07/15 14:00:00 $ $Revision: 2.0 $
    %   Copyright: Alonzo Kelly 2020
    %
    properties(Constant) 
        plot_props = {'LineStyle','-', 'LineWidth', 2, 'Color','Blue'}; % drawing specification
    end
    
    properties
        rawPoints=[]; % the raw data represented as [xpts ; ypts ; ones]
    end
    
    methods
        function obj = polyLineShape(rawPoints,varargin)
            %polyLineShape Constructs an instance of this class.
            %
            %   polyLineShape(rawPoints,varargin) constructs a polyLine
            %   shape. The raw data rawPoints is represented as a homogeneous array
            %   of the form [xpts ; ypts ; ones]. A polyLineShape can be used
            %   instead of rawPoints and the points will then be extracted from
            %   the polyLineShape. Remaining arguments are passed to the superclass.
            %
            %   Arguments "varargin", if present, are compatible with shapeList.
            %
            
        end
    end
end