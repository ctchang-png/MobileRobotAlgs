classdef basicShape < handle
    %basicShape A class that holds a list of (x,y) coordinates. 
    %
    %   Its main purpose is to separate the description of shape contained
    %   here from any description of motion which may be contained
    %   elsewhere. The shape points stored here in model_points specify the
    %   locations of the points in the model (i.e. fixed to the object
    %   itself) frame. The model frame can be anywhere but the main
    %   distinction is the points never move with respect to it. If you want
    %   movement or animation, use a derived class.
    %
    %   Plotting: Create an instance of basicDisplayedShape from this class
    %   in order to plot the shape in a window.
    %
    %   Simulation: In order to accomodate both shapes that contain
    %   graphical information only as well as bodies that reflect lidar
    %   beams, each basicShape has a lidarVisible flag that can be cleared to
    %   make it invisible to lidar. This is also a good way to remove parts
    %   below lidar height from the expensive ray tracing calculation.
    %
    %   The derived class called animatedShape is the animated (and
    %   hierarchical) version of this class.
    %
    %   $Author: AlonzoKelly $  $Date: 2020/07/15 14:00:00 $ $Revision: 2.0 $
    %   Copyright: Alonzo Kelly 2020
    %
    properties(Constant)
    end
    
    properties(Access = public)
        model_points = [];      % 3Xn array of points in body (aka model) coordinates
        lidarVisible = true;    % visible to lidar or not
    end
        
    methods(Static)
    end
    
    methods(Access = public)
        
        function obj = basicShape(mPts)
        %basicShape Creates an instance of this class.
        %
        %   basicShape() creates an empty instance
        %
        %   basicShape(mPts) creates an instance with 3XN homogeneous array
        %   of points mPts that describe its shape.
        %
        end
        
        function setShape(obj,mPts)
        %setShape Sets the basic (untransformed) shape to the incoming mpts array.
        %
        %   mpts specifies the locations of the points in the model (i.e.
        %   fixed to the object itself) frame. The model frame can be
        %   anywhere but the main distintion is the point never move with
        %   respect to it. If you want movement or animation, use a derived
        %   class.
        %
        end
        
        function mPts = getShape(obj)
        %getShape Returns mpts array that describes the basic untransformed shape.
        %
        %   This function is intended to be optionally overriden by a derived class
        %   that can move. That derived class will return its own transform of
        %   these points that have been moved.
        %
        end
    end
end
    