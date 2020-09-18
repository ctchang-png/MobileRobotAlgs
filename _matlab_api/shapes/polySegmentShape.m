classdef polySegmentShape < polyLineShape
    %polySegmentShape A polySegment Shape.
    %   A polySegment shape is similiar to a polyLine shape except there
    %   is no assumption that the end of one line segment is the start of
    %   the next. Rather, two arrays of points define this shape where the
    %   first is the segment start points and the second is the segment end
    %   points. This class is not really needed because polySegments are
    %   just polyLines under the hood. It is included for convenience.
    %
    %   $Author: AlonzoKelly $  $Date: 2020/07/15 14:00:00 $ $Revision: 2.0 $
    %   Copyright: Alonzo Kelly 2020
    %
    
    properties
    end
    
    methods
        function obj = polySegmentShape(pts1,pts2,varargin)
            %polySegmentShape Construct an instance of this class
            %   
            %   polySegmentShape(pts1,pts2,varargin) constructs a
            %   polySegment where pts1 and pts2 are, respectively, the
            %   start points and end points of corresponding segments.
            %   Under the hood a polyLineShape is constructed with NaNs
            %   delimiting the segments. Arguments "varargin" are
            %   compatible with shapeList.
            %
        end
    end
end