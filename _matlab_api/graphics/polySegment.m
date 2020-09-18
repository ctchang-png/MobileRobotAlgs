classdef polySegment < polyLine
    %polySegment A class that efficiently represents a list of separated line segments.
    %
    %   The design of this class exploits the fact that MATLAB will skip
    %   points containing NaNs when plotting and that it will accept NaNs
    %   in matrices and simply "NaNify" anything touched by them in
    %   computations. The result of all that is that we can treat (and
    %   explicitly represent) polySegments as polyLines with NaN "holes"
    %   poked in them wherever there is a break. MATLAB is remarkably stable
    %   in the face of NaNs peppered throughout the matrices it is
    %   operating on.
    %
    %   In a sense, this means that rendering a NaN point is a "pen up"
    %   motion for both the segment before and the segment after.  While
    %   this treatment of NaNs does not require that pen down operations be
    %   one segment long (i.e. you could have multiple segments before a
    %   NaN), this class assumes in some places that pen down sequences are
    %   one segment long. Such a polySegment is said to be in "dashed"
    %   form. You can change this assumption by rewriting the class or
    %   deriving a subclass. You can also just add a second copy of the
    %   endpoint of the last segment after the NaN.
    %
    %   PolySegments are useful representations for walls in localization
    %   because they have no joints or corners where data association is
    %   ambiguous. I usually make a set of walls and then erode the corners
    %   to produce a polySegment used for localization only. PolySegments
    %   render exactly as you would hope too.
    %
    %   $Author: AlonzoKelly $  $Date: 2020/07/15 14:00:00 $ $Revision: 2.0 $
    %   Copyright: Alonzo Kelly 2020
    %
    
    properties(Constant)
    end
    
    properties(Access = public)
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
            
            % a segment from (10,20) to (40,50)
        end

        function testClass2()
            %testClass2 More convenient test routines.
            
            % test conversions to and from dashed form
        end
        
        function pts = segPtsToDashedLine(pts1,pts2)
            %segPtsToDashedLine Creates a polyLine point array from two PS
            %endpoint arrays.
            %
            %   Produces a dashed structure.
            %
        end
    
        function [pts1,pts2] = dashedLineToSegPts(pts)
            %dashedLineToSegPts Creates two polySegment endpoint arrays from one PL point array.
            %
            %   Assumes a dashed structure as input. 
            %
        end
        
        function [pts1,pts2] = polySegmentToSegPts(pS,varargin)
            %polySegmentToSegPts Extracts endpoint coordinates from a polySegment.
            %
            %   Optionally erodes the gaps or corners by the
            %   radius in second argument.
            %

        end
        
        function pS = polySegFromCoords(xCoords,yCoords,doCloseIt)
            %polySegFromCoords Creates a polySegment from coordinate arrays.
            %
            % Forms a polySegment given an ordered list of endpoint
            % coordinates. See formLineSegmentsFromPoints for more
            % information. This form is convenient if you have to enter the
            % description of geometry manually because you only have to
            % type the x and y coordinates of each point once, rather than
            % duplicate them in line segments. 
            %
        end
        
        function [pts1, pts2] = formLineSegmentsFromPoints(pts,doCloseIt,varargin)
            %formLineSegmentsFromPoints Creates line segments from an ordered  list of endpoints.
            %
            % Form a set of line segments given an ordered list of
            % endpoints. The basic idea is that pt1 = (x1;y1) etc. and then
            % the first segment is from pt1-pt2 and the second is pt2-pt3
            % etc. Optionally, a last (closing) segment is added which is
            % ptn-pt1. The result can be used in the constructor for this
            % class. If present the thrd argument is the chopping radius.
            %
        end
          
        function [pts1 , pts2] = erodeLineSegmentsByRadius(pts1, pts2, radius)
            %erodeLineSegmentsByRadius Shortens all line segments on both ends by the provided radius.
            %
            %   Shortens all line segments on both ends by the provided
            %   radius. Any segments shorter than twice the radius are
            %   deleted. The result can be used in the constructor for this
            %   class.
            %
            
        end
%         
%         function [pts1, pts2] = formLineSegmentsFromCoordinates(xCoords,yCoords,doCloseIt)
%             %formLineSegmentsFromCoordinates Creates line segments from
%             %coordinate arrays.
%             % Forms a set of line segments given an ordered list of
%             % endpoint coordinates. See formLineSegmentsFromPoints for more
%             % information. The result can be used in the constructor for
%             % this class. This form is convenient if you have to enter the
%             % description of geometry manually because you only have to
%             % type the x and y coordinates of each point once, rather than
%             % duplicate them in line segments. The result can be used in
%             % the constructor for this class.
%             pts = [xCoords; yCoords ; ones(1,length(xCoords))];
%             [pts1, pts2] = polySegment.formLineSegmentsFromPoints(pts,doCloseIt);
%         end
%         
%         function [pts1, pts2] = convertPolyLineToSegments(pL,varargin)
%             %convertPolyLineToSegments Converts the provided polyLine to
%             %a polySegments and optionally erodes the joints by the provided
%             %radius and optionally closes it.
%             %   convertPolyLineToSegments(pL,doCloseIt) adds the capacity to
%             %   close the polyLine.
%             %   convertPolyLineToSegments(pL,doCloseIt,radius) adds the
%             %   capacity to erode the joints by a radius.
%             %   The model points of the provided polyLine are used to form
%             %   the model points of the new segments. In this way the
%             %   conversion does not depends on the pose of either.
%             %
%             if(nargin >= 2) ; doCloseIt = varargin{1}; else; doCloseIt=false; end
%             if(nargin >= 3) ; radius = varargin{2}; else; radius = 0.0; end
%             % Form the segments
%             [pts1, pts2] = polySegment.formLineSegmentsFromPoints(pL.model_points,doCloseIt);
%             % Do the erosion
%             if(radius > 0.0)
%                 [pts1, pts2] = polySegment.erodeLineSegmentsByRadius(pts1, pts2, radius);
%             end
%         end
%         
%         function pS = convertPolyLineToPolySegment(pL,varargin)
%             %convertPolyLineToPolySegment Converts the provided polyLine to
%             %a polySegment and optionally erodes the joints by the provided
%             %radius and optionally closes it.
%             %   convertPolyLineToPolySegment(pL,doCloseIt) adds the capacity to
%             %   close the polyLine.
%             %   convertPolyLineToPolySegment(pL,doCloseIt,radius) adds the
%             %   capacity to erode the joints by a radius.
%             %   The model points of the provided polyLine are used to form
%             %   the model points of the new polySegment. In this way the
%             %   conversion does not depends on the pose of either.
%             %
%             [pts1, pts2] = convertPolyLineToSegments(pL,varargin);
%             
%             pS = polySegment(pts1,pts2);
%         end
    end
        
    methods(Access = public)
        
        function obj = polySegment(pts1,pts2,varargin)
        %polySegment Creates an instance of this class.
        %
        %   polySegment() creates an empty instance.
        %   
        %   polySegment(pts1,pts2) creates an instance of an equivalent
        %   polyLine to decribe the shape (start and end points) of all the
        %   segments.
        %
        %   polySegment(pts1,pts2,myPoseWrtParent) also sets the pose of
        %   this polySegment wrt its parent.
        %
        end
    end
end