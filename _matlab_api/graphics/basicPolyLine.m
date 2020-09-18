classdef basicPolyLine < basicShape
    %basicPolyLine A class that holds an (x,y) pts description of a shape.
    %
    %   The shape here is directly specified as (x,y) coordinates. It is
    %   functionally redundant relative to basicShape but its purpose is to
    %   clarify the intention of the user to directly specify the shape
    %   points, as opposed to, for example, specifying just the radius in
    %   the case of a circle and having the points computed for you.
    %
    %   $Author: AlonzoKelly $  $Date: 2020/07/15 14:00:00 $ $Revision: 2.0 $
    %   Copyright: Alonzo Kelly 2020
    %
    properties(Constant)
    end
    
    properties(Access = public)
    end
    
    methods(Static)
    end
    
    methods(Access = public)
        
        function obj = basicPolyLine(varargin)
        %BASICPOLYLINE Creates an instance of this class.
        %
        %   basicPolyLine() creates an empty instance
        %
        %   basicPolyLine(mPts) creates an instance with 3XN homogeneous array
        %   of points that describe its shape.
        %
        end
    end
end