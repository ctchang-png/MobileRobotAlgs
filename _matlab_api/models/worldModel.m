classdef worldModel < handle
    %worldModel Properties and static functions for a world.
    %
    %   Provides useful parameters and methods for creating walls
    %   around the robot and pick and drop locations for pallets.
    %
    %   $Author: AlonzoKelly $  $Date: 2020/07/15 14:00:00 $ $Revision: 2.0 $
    %   Copyright: Alonzo Kelly 2020
    %    
    
    properties(Constant)
        wallLength =  4.0*12*0.0254;    % standard wall length
    end
    
    properties(Access = private)

    end
    
    properties(Access = public)

    end
    
    methods(Static = true)

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
            win = objectFigure('worldModel.testClass');
            pLs = worldModel.wallsPolylineShape([1 1 1 0 0],1,1); % xy axes
            win.addObj(pLs,'b-','LineWidth', 4);
            win.show();
            pause(1);
            win.delObj(pLs);
            pLs = worldModel.wallsPolylineShape([1 1 1 1 0],1,1); % 3 walls
            win.addObj(pLs,'b-','LineWidth', 4);
            win.show();
            pause(1);
            win.delObj(pLs);
            pLs = worldModel.wallsPolylineShape([1 1 1 1 1],2,3); % 4 walls, 2 wide, 3 high
            win.addObj(pLs,'b-','LineWidth', 4);
            win.show();
            pause(1);
            win.delObj(pLs);
            
            % test polySegment chopping and rendering
            chopRad = 0.25;
            pS = polySegment.convertPolyLineToPolySegment(pLs.theList{1},false,chopRad);
            pSS = polySegmentShape(pS.pL1.model_points,pS.pL2.model_points);
            win.addObj(pSS,'b-','LineWidth', 4);
            win.show();
            win.close();
        end
                      
        function mPts = createXYAxes()
            % Create lines for x and y axes of standard (4 ft) panels.
            mPts = worldModel.wallsPoints([1 1 1 0 0],1,1); % xy axes
        end
       
 
        function mPts = createThreeWalls()
            % Create lines for 3 walls of standard (4 ft) panels.
            mPts = worldModel.wallsPoints([1 1 1 1 0],1,1); % 3 walls
        end
        
        function mPts = createFourWalls()
            % Create lines for 4 walls of 2 wide and 3 high standard panels.
            mPts = worldModel.wallsPoints([1 1 1 1 1],2,3); % 4 walls, 2 wide, 3 high
        end
        
        function pLs = wallsPolylineShape(wallsVec,wid,hgh)
            %WALLSPOLYLINESHAPE Produces a polyLine for all or a fraction of a 4
            %walled room. 
            % This is just a convenience layer over wallsPoints that
            % converts the points to a polyLine shape for you.
            %
            mPts = worldModel.wallsPoints(wallsVec,wid,hgh);
            pLs = polyLineShape(mPts);
        end
        
        function mPts = wallsPoints(wallsVec,wid,hgh)
            %WORLDPOLYLINE Produces a polyLine for all or a fraction of a 4
            %walled room.
            % WallsVec is a vector of ones and zeros specifying which points
            % are to be included. The 4 points are designated in order as
            % NW, SW, SE, NE. So, xy axes are denoted [1 1 1 0 0]. You can
            % always close the polyLine by specifying a fifth point equal
            % to the first. hgh and wid are the width and height in units
            % of 4 ft walls. The SW point is the origin. Results are
            % reported in meters.   
            
            % Dimensions of the rectangle
            wid =  wid*worldModel.wallLength;
            hgh =  hgh*worldModel.wallLength;
            
            % Set up points
            nw = [0 ;   hgh ; 1];
            sw = [0 ;     0 ; 1];
            se = [wid ;   0 ; 1];   
            ne = [wid ; hgh ; 1];
            
            % form the polyLine
            points = [nw sw se ne nw];
            wallsVec = logical(wallsVec);	% convert to boolenn
            mPts = points(:,wallsVec);      % logical indexing
        end
        
        function poses = pickDropPoseArray(n,x0,dx,y0,dy,th)
            %PICKDROPOSEARRAY Produces a linear array of pick and drop poses.
            %   n - the number of poses to create
            %   x0 - the initial x coordinate
            %   dx - the spacing in x
            %   x0 - the initial x coordinate
            %   dx - the spacing in x
            %   th - the orientation
            %   Typically, one of dx or dy will be zero.
            poses = [];
            for i=1:n
                xPose = x0*0.0254+(i-1)*dx*0.0254;
                yPose = y0*0.0254+(i-1)*dy*0.0254;
                newPose = [xPose; yPose; th];
                poses = [poses newPose]; %#ok<AGROW>
            end
        end
    end
            
    methods(Access = public)
    end

end