classdef scalarField < handle
    %scalarField Implements a discretized field over a finite rectangle.
    %
    %   Maps a rectangle onto an array and permits accesses to
    %   the array based on continuous (x,y) coordinates. Establishes the 
    %   relationship between discrete and continuous coordinates at construction
    %   time and remembers it thereafter. Therefore, it is suitable for 
    %   writing to a file and reading it back again without having to
    %   remember the transform externally. The special value "empty" can be
    %   used to test if a cell was never written.
    %
    %   $Author: AlonzoKelly $  $Date: 2020/07/15 14:00:00 $ $Revision: 2.0 $
    %   Copyright: Alonzo Kelly 2020
    %
    
    properties(Constant)
        empty = inf;        % special value of empty cells
    end
    
    properties(Access = private)

    end
    
    properties(Access = public)
        xMin;   % min X coordinate
        xMax;   % max X coordinate
        numX;   % number of cells in X
        yMin;   % min Y coordinate
        yMax;   % max Y coordinate
        numY;   % number of cells in Y
        dx;     % size of cells in X (computed internally)
        dy;     % size of cells in Y (computed internally)
        cellArray = []; % the array of cells
    end
    
    methods(Static = true)    
    end
    
    methods(Access = private)    
    end
            
    methods(Access = public)
        
        function obj = scalarField(xMin,xMax,numX,yMin,yMax,numY)
            %scalarField Constructs a scalar field on the supplied rectangle.
            %
            %   field = scalarField(xMin, xMax, numX, yMin, yMax, numY)
            %   constructs a scalar field with numX x values from xMin to
            %   xMax and numY y values from yMin to yMax.
            %
            if(nargin == 6)
                obj.xMin = xMin;
                obj.xMax = xMax;
                obj.numX = numX;
                obj.yMin = yMin;
                obj.yMax = yMax;
                obj.numY = numY;
                obj.dx = (xMax-xMin)/numX;
                obj.dy = (yMax-yMin)/numY;
                obj.cellArray = obj.empty*ones(numX,numY);
            end
        end
        
        function setAll(obj,value)
            %setAll Sets all cells to some value.
            for i=1:obj.numX
                for j=1:obj.numY
                    obj.cellArray(i,j) = value;
                end
            end
        end
        function set(obj,x,y,val)
            %set Sets the value of a cell.
            %
            %   obj.set(x, y, val) sets the value of (x,y) to val.
            %
            if(~obj.isInBounds(x,y))
                err = MException('scalarField:Out Of Bounds', ...
                    'Exiting...');
                throw(err);
            end
            i = obj.xToi(x);
            j = obj.yToj(y);
            obj.cellArray(i,j) = val;
        end
        
        function val = get(obj,x,y)
            %get Returns the value of a cell.
            %
            %   obj.get(x, y) retrieves the value of (x,y).
            %
            if(~obj.isInBounds(x,y))
                err = MException('scalarField:outOfbounds', ...
                    'Out of Bounds Lookup in Scalar Field');
                throw(err);
            end
            i = obj.xToi(x);
            j = obj.yToj(y);
            val = obj.cellArray(i,j);
        end
        
        function val = isInBounds(obj,x,y)
            %isInBounds Checks to see if a point is within the field boundaries.
            %
            %   val = obj.isInBounds(x, y) returns true if (x,y) is within
            %   the boundaries of the scalar field.
            %
            
            if(x<obj.xMin || x>obj.xMax || y<obj.yMin || y>obj.yMax)
                val = false;
            else
                val = true;
            end
        end
        
        function [min, max] = range(obj)
            %range Returns the range of values in the scalar field.
            %
            %   [a, b] = obj.range returns the minimum value a and the
            %   maximum value b from the scalar field.
            %
            min = inf ; max = -inf;
            for i=1:obj.numX
                for j=1:obj.numY
                    if(isinf(obj.cellArray(i,j))); continue; end
                    if(obj.cellArray(i,j) < min) 
                        min = obj.cellArray(i,j); 
                    end
                    if(obj.cellArray(i,j) > max) 
                        max = obj.cellArray(i,j); 
                    end
                end
            end
        end
        
        function points = getNeighbors(obj,pt)
            %getNeighbors Finds all neighbors of a given point.
            %
            %   Does not return anything outside the bounds of the cellArray.
            %
            %   points = obj.getNeighbors(pt) returns an array points of
            %   points (columns) neighboring the given point pt.
            %
            points = [];
            num = 1;
            i = pt(1); j = pt(2);
            for ii= -1:1:1
                for jj= -1:1:1
                    if( ii == 0 && jj == 0); continue; end
                    if(    i+ii >= 1 && i+ii <= size(obj.cellArray,1) ...
                       &&  j+jj >= 1 && j+jj <= size(obj.cellArray,2))
                        points(:,num) = [i+ii ; j+jj]; %#ok<AGROW>
                        num = num + 1;
                    end
                end
            end
        end
           
        function pt = xyToIj(obj,x,y)
            %xyToIj Converts a cell coordinates to its indices.
            %
            %   pt = obj.xyToIj(x, y) converts the value (x,y) to the index
            %   (i,j) and returns it in the form pt = [i; j].
            %
            i = xToi(obj,x);
            j = yToj(obj,y);
            pt = [i ; j];
        end
        
        function pt = ijToXy(obj,i,j)
            %ijToXy Converts cell indices to its coordinates.
            %
            %   pt = obj.ijToXy(i, j) converts the index (i,j) to the value
            %   (x,y) and returns it in the form pt = [x; y].
            %
            x = iToX(obj,i);
            y = iToy(obj,j);
            pt = [x ; y];
        end
        
        function i = xToi(obj,x)
            %xToi Converts x coordinate to row index.
            %
            %   i = obj.xToi(x) returns the row index i for the x
            %   coordinate x.
            %
            i = floor((x-obj.xMin)/obj.dx) + 1;  end  
        function j = yToj(obj,y)
            %yToj Converts y coordinate to column index.
            %
            %   j = obj.yToj(y) returns the column index j for the y
            %   coordinate y.
            %
            j = floor((y-obj.yMin)/obj.dy) + 1;  end  
        function x = iToX(obj,i)
            %iToX Converts row index to x coordinate.
            %
            %   x = obj.iToX(i) returns the x coordinate x for the row
            %   index i.
            %
            x = obj.xMin + obj.dx*(i-0.5);  end % changed Aug 21, 2014, add xmin
        function y = jToY(obj,j)
            %jToY Converts column index to y coordinate.
            %
            %   y = obj.jToY(j) returns the y coordinate y for the column
            %   index j.
            %
            y = obj.yMin + obj.dy*(j-0.5);  end % changed Aug 21, 2014 add ymin
        function dx = getDx(obj)
            %getDx Returns the x resolution of the scalar field.
            dx = obj.dx; end
        function dy = getDy(obj)
            %getDy Returns the y resolution of the scalar field.
            dy = obj.dy; end
    end
end