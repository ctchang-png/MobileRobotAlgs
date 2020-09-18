classdef rangeImageShape < shape
    %rangeImageShape A rangeImage Shape.
    %
    %   A rangeImageShape is similiar to a polyLineShape except that
    %   the shape is specified in terms of the content of a range image
    %   which is then converted here to a point cloud to be rendered as points.
    %   Note that a point cloud could also be rendered as a set of line
    %   segments, all of which start at the origin of the sensor frame, but
    %   this class uses points. You could use a polySegment for a line
    %   segment version.
    %
    %   This class has a setRanges function that is used to update the range
    %   image at high rates.
    %
    %   $Author: AlonzoKelly $  $Date: 2020/07/15 14:00:00 $ $Revision: 2.0 $
    %   Copyright: Alonzo Kelly 2020
    %
    
    properties(Constant)
        plot_props = {'Marker','.','MarkerSize',12,'Color','Red'}; % drawing specification
    end
    
    properties
        pL;         % polyLine
        pC;         % point cloud
    end
    
    methods(Static)     
        function [parts , pL, pC] = makeBodyPoints(ranges)
            %makeBodyPoints Creates the shape in body coordinates.
            %   Creates the shape in body coordinates.

            % make a point cloud to produce the points
        end
    end
    
    methods
        function obj = rangeImageShape(ranges,varargin)
            %RANGEIMAGESHAPE Construct an instance of this class
            %
            %   rangeImageShape(ranges,varargin) constructs a point cloud
            %   from the supplied array of ranges and produces a polyLine
            %   from the resulting points. Despite the polyLine name, those
            %   points are usually drawn as points.
            %
            %   Arguments "varargin" are compatible with shapeList.
            %
        end
        
        function setRanges(obj,ranges)
            %setRanges Updates the point cloud based on new incoming ranges
        end
                
        function setFilters(obj,skip,cleanFlag)
            %setFilters Sets the data sampling and filtering parameters.
            %
            % setFilters(skip,cleanFlag) skip is the number of pixels to
            % skip to get to the next one used and cleanFlag will cause
            % near and far points to be eliminated from the image. The
            % parameters defining near and far points, as well as the
            % sensor pose on the robot, are in the rangeSensor and
            % pointCloud classes.
            %
        end
    end
end