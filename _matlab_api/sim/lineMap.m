classdef lineMap < shapeList
    %lineMap An environment map made up of polyLines.
    %
    %   Al Kelly: Jun 2020. A rewrite of lineMap to deal with the fact that the class
    %   does not work for heterogeneous arrays formed from derived classes of
    %   lineObject (now polyLine).
    %
    %   In particular, in order to force everything in the array to be the same type,
    %   the line of code:
    %
    %           lc = cell2mat({lm.polyLines{:}.world_points}'); 
    %
    %   in rayCast was DELETING world_points for classes different from the
    %   first class added.
    %
    %   This behavior was traced to the MATLAB treatment of arrays of
    %   different types (even though all were derived from lineObject. In
    %   the end, I decided to change the array structure of this class to a
    %   cell array which is made specifically for lists of homogeneous
    %   objects. See shapeList < cellList for that.
    %
    %   Note that formSegmentEndpoints herein relies on
    %   lineMapInstance.theList being a FLAT list of polyLines rather than
    %   a tree. Subclassing from shapeList should guarantee that. It is
    %   possible to change this assumption but it is done that way now for
    %   efficiency. That is why we have both cellLists and cellTrees even
    %   though the latter subsumes the former as a special case. The
    %   present design can exploit the efficiency of cellFun and cellToMat.
    %
    %   Also, the segment endpoints are recomputed every time rayCast is
    %   called. That has the advantage that code is simpler and more
    %   self-contained and the disadvantage that it is expensive and
    %   potentially wasteful. Wasteful because somewhere else in the code
    %   it it known when objects are added and deleted and the segment
    %   computation could be triggered from there instead of redone in
    %   every rayCast.
    %
    %   This class also includes convenience routines to produce sampled
    %   point clouds from the line segments and to find line segments that
    %   intersect a ray.
    %
    %   This class isa shapeList and that allows it to hold the shape
    %   handles of the objects added. Because line segments are recomputed
    %   from the shapes every time rayCast is called, the process of
    %   deleting line segments is as easy as deleting the shape that
    %   produced them.
    %
    %   In other words, due to this "lazy", "delayed", or "continuous"
    %   conversion to line segments design, this class implicitly enforces
    %   the consistency between line segments used in the ray casting and
    %   the objects in this shapeList which are the interface to the rest
    %   of the system. Ideally, the rest of the system talks to world
    %   modelling in terms of shapes and does not have to deal with line
    %   segments.
    %
    %   Sept 2013: Original version for Neatos by Mike Shomin and Al Kelly
    %   Sept 2015: Modified version inckuding noise sim by Abhijeet Tellavajhula
    %   Sept 2017: Additions by Ariana Keeling
    %   June 2020: Partial Redesign and numerous bug fixes by Al Kelly
    %
    %   $Author: AlonzoKelly $  $Date: 2020/07/15 14:00:00 $ $Revision: 2.0 $
    %   Copyright: Alonzo Kelly 2020
    %
    
    properties (Constant = true)
        sampleResln = 0.05;  % 5 cm sampling resolution
        doIncidence = false; % added by Al Nov 20, 2016. Default is off.
    end
    
    properties (GetAccess = public, SetAccess = protected)
    end
    
    properties (GetAccess = public, SetAccess = private)
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
            
            % Create lines for four walls of standard (4 ft or 6 ft) length.
            
            % Set up lines
        end
    end
    
    methods (Access = public)
        
        function [ranges,incidence_angles] = raycast(lm, pose, max_range, ang_range)
            %raycast Returns the distance and angle of incidence to each polyLine
            % in a line map for use in simulating laser data.
            %
            %   [r, ang] = lm.raycast(pose, max_range, ang_range) returns the
            %   ranges r (in meters) and incidence angles ang (in radians) from
            %   a simulated laser scan from a sensor located at coordinate (x,y)
            %   with orientation theta (from pose = [x; y; theta]), with the
            %   range limited by max_range (in meters) for each direction given in
            %   ang_range (in radians).
            %
            %   The essential algorithm a) joins all line segments together in one
            %   polyline, b) computes the distance from every ray to every segment
            %   of the giant polyline, c) eliminates the hits produced when rays intersect
            %   "spurious" segments joining polylines that do not exist, d) then
            %   finds the shortest range for every ray. The algorithm works for
            %   polySegments (containing NaNs to delimit segments) as well.
            %
                      
            % Create line segments for the rays of the laser beams       
        end
        
        function [ranges,angles] = raycastNoisy(lm, pose, max_range, ang_range,err_r,std_r)
            %raycastNoisy Introduces noise to the raycast function.
            %
            %   [r, ang] = lm.raycastNoisy(pose, max_range, ang_range,err_r,std_r) does
            %   raycasting as in raycast, but adds:
            %       scale factor error by multiplying range by err_r
            %       gaussian noise of magnitude std_r*N()*range^2/cos(angle)
            %   where angle is the angle of incidence.
            %
            %   See also raycast
            %
        end
        
        function [lc , visPolys] = formSegmentEndpoints(lm)
        %formSegmentEndpoints Places the endpoints of all of the lidarVisible line segments in a column vector.
            
            % first remove polyLines that are not visible to lidar
        end
         
        function ng = identifySpuriousSegments(~,visPolys)
            %identifySpuriousSegments Finds those line segemnts that are not really there.
            %
            %   The initial steps of ray tracing treat all points as if they
            %   form one giant polyLine and computes the range to every line
            %   segment of every ray. Now before we find the minimum of all the
            %   ranges for each ray, we find the ones that join the polyLines.
            %
        
            %ng = cumsum(cellfun(@(x) size(x,1), {visPolys{:}.world_points}'));
            %ng = cumsum(cellfun(@(x) size(x.world_points,1), visPolys)); % col list
            %ng = cumsum(cellfun(@(x) size(x.world_points,1), visPolys')); % row list
        end
        
		function [dist, ob_num, line_num] = closestPolyLine(lm, pos)
            %closestPolyLine Determines the closest polyLine on a ray for use in simulating laser data
            %
            %   [dist, ob_num, line_num] = lm.closestPolyLine(pos) returns the
            %   distance dist to the closest polyLine, identified by the polyLine
            %   number ob_num, to another polyLine located at pos = [x, y].  It
            %   also returns the index of the line that intersected that
            %   polyLine, line_num. This function is provided for convenience.
            %   It is not used in raycast.
            %

            % get the endpoints of all line segments
            [lc , visPolys] = lm.formSegmentEndpoints();
            
            if( all(size(pos) == [1 2]) )
				P = pos;
			elseif( all(size(pos) == [2 1]) )
				P = pos';
			else
				error('pos must be 2x1');
            end
			
			%line endpoints
			P0 = lc(1:end-1,:);
			P1 = lc(2:end,:);
			
			%Query Point
			P = repmat(P, size(P0,1),1);
			
			D = zeros(size(P0,1),1);
			
			%useful vectors
			v = P1 - P0;
			w = P - P0;

			%dot products to check case
			c1 = sum(v.*w,2);
			c2 = sum(v.*v,2);
			
			%before P0
			bp0 = c1<=0;
			D(bp0) = sqrt(sum((P(bp0,:) - P0(bp0,:)).^2,2));
			
			%after P1
			ap1 = c2<=c1;
			D(ap1) = sqrt(sum((P(ap1,:) - P1(ap1,:)).^2,2));
			
			%perpedicular to line
			per = ~(bp0 | ap1);
			
			b = c1 ./ c2;
			Pb = P0 + ([b b].*v);
			D(per) = sqrt(sum((P(per,:) - Pb(per,:)).^2,2));
					
            % remove spurious line segments between points not belonging to some
            % polyLine
            ng = lm.identifySpuriousSegments(visPolys);
			D(ng(1:end-1)) = inf;

			%get minimum distance
			[dist, ind] = min(D);
			
			%find the polyLine and line number
			zng = [0;ng];
			ob_num = find(ind > zng, 1, 'last');
			line_num = ind - zng(ob_num);
        end
        
        function pcd = getPCD(lm,resln)
            %getPCD Returns point cloud data sampled uniformly from the line map
            %
            %   pcd = lm.getPCD() returns a n x 2 vector of points sampled from
            %   the line map.  The number of points sampled is related to the
            %   sample resolution of the map and it is padded with zeros.
            %
            %   pcd = lm.GETPCD(resln) returns a n x 2 vector of points sampled
            %   from the line map.  The number of points sampled is related to
            %   the resolution resln and is padded with zeros. The number of
            %   samples is related to the resolution resln.
            %
        end
    end
    
    methods (Static = true)
        function pts = sampleFromLines(lineArray,resln)
            %sampleFromLines Returns points sampled from a line array 
            %
            %   pts = sampleFromLines(lines, resln) samples points from an
            %   array of polyLines, lines, and returns them as an n x 2
            %   vector pts (where n is the number of lines in the array).
            %   The number of samples is related to the resolution resln.
            %
            
        end
    end
end













