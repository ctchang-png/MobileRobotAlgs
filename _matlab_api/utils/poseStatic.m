classdef poseStatic < handle
    %poseStatic A set of static functions related to poses.
    %
    %   These functions are placed here to avoid cluttering up the pose
    %   class but because pose inherits this, you can still refer to these
    %   functions as pose.function(). They are also useful for anyone who wants
    %   a canned package of the relevant and commonly used mathematics
    %   without having to create an instance of the pose class. The pose
    %   class can be very convenient but it will make porting your code
    %   elsewhere harder.
    % 
    %   For the purpose of naming the homogeneous transforms, the pose is
    %   considered to be that of frame b relative to frame a. Therefore, if
    %   your pose is the robot pose in the world, then the transform bToA()
    %   will convert coordinates from the robot to the world.
    %   
    %   If you do not use the pose class, here are some suggested
    %   conventions:
    %   1) pass pose vectors into functions by default. Name them so that
    %   they end in "poseVec". This will help avoid the common bug of
    %   confusing a pose from the pose class and a column vector. That
    %   crashes MATLAB and can be hard to track down.
    %   2) In cases where poses are being used ultimately to transform
    %   coordinates of points or vectors (like displacements), name a
    %   poseVec variable based on the "from" frame and the "to" frame
    %   with "Wrt" in between. Thus robWrtWld is the pose vector describing
    %   the pose of the robot with respect to the world.
    %   3) Conversely, name homogeneous transforms (special 3X3 matrices)
    %   similiarly with "To" in between. So robToWld, the HT derived
    %   directly from robWrtWld converts coordinates from the robot frame
    %   to the world frame. So the convention is anything with Wrt in its
    %   name is a pose and anything with To in its name is an HT.
    %
    %   $Author: AlonzoKelly $  $Date: 2020/07/15 14:00:00 $ $Revision: 2.0 $
    %   Copyright: Alonzo Kelly 2020
    %
    properties(Constant)
    end
    
    properties(Access = private)
    end
    
    properties(Access = public)
    end
    
    methods(Static = true)
        
        function vec = matToPoseVec(mat)
        %matToPoseVec Convert a homogeneous transform into a pose column vector.
        %
        %   pose = MATTOPOSEVEC(mat) retrieves the pose vector pose in the form
        %   [x; y; w] from the transform matrix mat.
        %
            x = mat(1,3);
            y = mat(2,3);
            w = atan2(-mat(1,2),mat(1,1));
            vec = [x ; y ; w];
        end
        
        function mat = poseVecToMat(vec)
        %poseVecToMat Converts a pose column vector into a homogeneous transform.
        %
        %   pose = MATTOPOSEVEC(mat) retrieves the 3 X 3 matrix that
        %   corresponds to the provided ppose column vector.
        %
        mat = zeros(3,3);
        x = vec(1); y = vec(2); th = vec(3);
        
        mat(1,1) =  cos(th); mat(1,2) = -sin(th); mat(1,3) = x;
        mat(2,1) =  sin(th); mat(2,2) =  cos(th); mat(2,3) = y;
        mat(3,1) =  0.0    ; mat(3,2) =  0.0    ; mat(3,3) = 1;
        end
        
        % The following two functions are two of three possibilities in the
        % general case of the most mininal pose network. That is three frames
        % in space and two relative poses known. These two cases assume objToRobot 
        % is known and solve for the third given a second that is known.
        function objToWorld = objToWorld(robToWorld,objToRobot)
            %objToWorld Object pose in the world given robot pose in the world.
            %
            %   objToWorld(robPose) returns the pose objToWorld of
            %   the object in the world given the robot pose in the world,
            %   robToWorld and the object pose on the robot objToRobot.
            %
            objToWorld = robToWorld.bToA()*objToRobot.bToA();
        end
        
        function robToWorld = robToWorld(objToWorld,objToRobot)
            %robToWorld Robot pose in the world given object pose in the world.
            %
            %   robToWorld(objPose) returns the pose robToWorld of
            %   the robot in the world given the object pose in the world,
            %   objToWorld and the object pose on the robot objToRobot.
            %
            robToWorld = objToWorld.bToA()*objToRobot.aToB();
        end
        
        function error = poseError(ob1ToWld,ob2ToWld,len)
        %poseError Provides a scalar measure of pose error.
        %
        %   Provides a scalar measure of all 3 axes of pose error between
        %   two provided object poses. len is used to scale orientation
        %   error.
        %
            % Compute pose of ob2 in ob1 frame
            ob2Wrtob1 = pose(ob1ToWld^-1*ob2ToWld);
            
            % compute error in all coordinates
            eX = ob2Wrtob1.x;
            eY = ob2Wrtob1.y;
            eT = ob2Wrtob1.th;
            
            if(eT > pi()/2)
                eT = eT - pi;
            elseif (eT < - pi()/2)
                eT = eT + pi;
            end
            
            %fprintf("pose_error: x:%f y:%f t:%f\n",eX,eY,eT);
            eT = eT*len;
            
            error = norm([eX eY eT]);        
        end
    end
    
    methods(Access = private)
    end
            
    methods(Access = public)
    end
        
end