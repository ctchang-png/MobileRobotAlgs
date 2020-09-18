classdef pose < poseStatic
    %pose A pose object in 2D with special operators defined.
    %
    %   A layer over a pose vector that permits you to treat it like a
    %   homegeneous transform or a parameter vector whenever each is
    %   convenient. 
    %
    %   NOTE: This help file may be shadowed by other MATLAB toolboxes and
    %   not visible when you "view help". In my case, I turned off help for
    %   the sensor fusion and tracking toolbox (in Preferences>Help) in
    %   order to see it.
    %
    %   Homogeneous transforms and pose vectors contain the same semantic
    %   information, but we often want to manipulate them in many different
    %   ways:
    %       1) as an operator or transform on points: pt2 = pose^-1 * pt1 
    %       2) as a struct containing coordinates: pose.x and pose.th 
    %       3a) as a vector of coordinates: y = pose(2); 
    %       3b) as a vector of coordinates: dPose = - gradient*0.001; 
    %       3c) as a vector of coordinates: pose = pose + dPose; 
    %       4) as a class with useful functions: vec2 = pose.bToA()* vec1
    %
    %   All of the above are legal uses of an instance of this class and
    %   best of all, it automatically figures out which one you mean. This
    %   class is very special in that it redefines several MATLAB
    %   operations to make the user's life much easier. As a general rule,
    %   if the operation you asked for can be construed to produce a pose, it
    %   will be coerced to produce a pose. Otherwise, it will produce a
    %   native vector or matrix.
    %
    %   The poseStatic class is also provided (and inherited here) if you
    %   want to avoid dependence of your code on this special class. To use
    %   that, for example:
    %           myHT = pose.poseVecToMat([1 ; 2 ; pi]))
    %   provides the homogeneous transform that corresponds to the
    %   provided pose vector.
    %
    %   In order to support direct left multiplication by a Jacobian matrix
    %   in localization pose refinement, poses behave like column vectors.
    %
    %   $Author: AlonzoKelly $  $Date: 2020/07/15 14:00:00 $ $Revision: 2.0 $
    %   Copyright: Alonzo Kelly 2020
    %
    properties(Constant)
    end
    
    properties(Access = private)
        poseVec; % A column vector of the three doubles [x;y;th];
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
        end
    end
    
    methods(Access = private)
    end
            
    methods(Access = public)
        
        function obj = pose(x,y,th)
            %pose Constructs an instance of this class.
            %
            %   pose() will create a pose with default coordinates of [0;0;0]
            %
            %   pose(vec) will create a pose from a vector of length 3.
            %
            %   pose(mat) will create a pose from a homegeneous transform
            %
            %   pose(x,y,th) will create a pose with those 3 coords
            %
        end
      
        function disp(pose1)
            %disp Display the conten of this pose.
            %
            %   Overrides the native MATLAB disp function to see past the
            %   pose struct and display a pose as if it was a native vector.
            %   This mostly matters because it is called by the debugger.
            %
        end
        
        function result = plus(pose1,pose2)
            %plus Adds a poses and a pose or vector to produce a new pose.
            %
            %   Overrides the MATLAB matrix addition operator so
            %   you can treat a pose directly as a vector and use it like a
            %   vector.
            %
            %   By defining this function, we make it possible to write
            %   pose+vector (and vector+pose) instead of an incantation like
            %   pose(vector(pose) + vector). Row vectors will be transposed
            %   before use.
            %
        end
        
        function result = minus(pose1,pose2)
            %minus Subtracts a pose and a pose or vector to produce a new pose.
            %
            %   Overrides the MATLAB matrix subtraction operator so you can
            %   treat a pose directly as a vector and use it like a vector.
            %
            %   By defining this function, we make it possible to write
            %   pose-vector (and vector-pose) instead of an incantation
            %   like pose(vector(pose) - vector). Row vectors will be
            %   transposed before use.
            %
        end
        
        function result = mtimes(pose1,pose2)
            %mtimes multiplies a pose (it's HT) times a pose (it's HT) or a vector. 
            %
            %   Overrides the MATLAB matrix multiplication operator so
            %   you can treat a pose directly as a matrix and use it like a
            %   matrix.
            %
            %   By defining this function, we make it possible to write
            %   pose*vector instead of an incantation like
            %   pose.bToa()*vector. This function returns a vector unless
            %   both arguments are poses. it is BOTH a way to multiply two
            %   HTs and a way to transform a vector.
            %
        end
 
        function result = mpower(pose1,pow)
            %mpower Raises a pose (its HT) to a power. Pow=-1 means inversion.
            %
            %   Overrides the MATLAB matrix power operator. By defining
            %   this function, we make it possible to write pose^2, and
            %   most importantly, pose^-1.
            %
        end
        
        function result = ctranspose(pose1)
            %ctranspose Transposes a pose and produces a row vector. 
            %
            %   Overrides the MATLAB transpose operator.
            %   By defining this function, we make it possible to write
            %   pose'. Careful! This routine treats the pose as a vector
            %   so it does not transpose the HT. A transposed HT has no
            %   legitimate use. A transposed rotation matrix does.
            %
        end
                
        function result = subsref(pose1,idx)
            %subsref Returns an indexed component of this pose.
            %
            %   Overrides the MATLAB matrix subscript reference operator.
            %   By defining this function and subsasgn, we make it possible to write
            %   pose(2), and to simply add and subtract poses like native vectors.
            %
        end
        
        function result = subsasgn(pose1,idx,val)
            %subsasgn Assigns an indexed component of this pose.
            %
            %   Overrides the MATLAB matrix subscript assignment operator.
            %   By defining this function and subsref, we make it possible to write
            %   pose(2) = 5, and to simply add and subtract poses like native vectors.
        end
        
        function x = x(obj)
            %x Returns the x coordinate of this pose object.
            %
            %   This function exists for legacy reasons. p.x() is
            %   now equivalent to p(1).
            %
        end
        
        function y = y(obj)
            %y Returns the y coordinate of this pose object.
            %
            %   This function exists for legacy reasons. p.y() is
            %   now equivalent to p(2).
            %
        end
        
        function th = th(obj)
            %th Returns the th coordinate of this pose object.
            %
            %   This function exists for legacy reasons. p.th() is
            %   now equivalent to p(3).
            %
        end
        
        function mat = bToA(obj)
            %bToA Returns the direct homogeneous transform.
            %
            %   The direct HT converts coordinates from the b frame to the
            %   a frame where the pose itself is interpreted to mean the
            %   pose of the b frame relative to the a frame. This function
            %   exists for legacy reasons. p.bToA()*vec is now equivalent
            %   to p*vec;
            %
            
        end
        
        function mat = aToB(obj)
            %aToB Returns the reverse homogeneous transform.
            %
            %   The reverse HT converts coordinates from the a frame to the
            %   b frame where the pose itself is interpreted to mean the
            %   pose of the b frame relative to the a frame. This function
            %   exists for legacy reasons. p.aToB()*vec is now equivalent
            %   to p^-1*vec;
            %
        
        end
                 
        function mat = bToARot(obj)
            %bToARot Returns 2X2 rotation matrix part of the direct HT.
        
        end
        
        function mat = aToBRot(obj)
            %aToBRot Returns 2X2 rotation matrix part of the reverse HT.

        end
    end
end