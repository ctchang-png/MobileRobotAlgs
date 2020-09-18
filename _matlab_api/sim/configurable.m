classdef configurable < moveable
    %configurable A node in a containment / pose hierarchy.
    %
    %   The purpose of this class is to propagate pose changes in a
    %   hierarchy. Each configurable node exists in a tree where all nodes
    %   but the root have one "parent" to which they are tied
    %   geometrically. Typically that geometric link is a rigid one but
    %   nothing prevents you from changing the link in real time to model
    %   articulation. Now every node in the tree also has a pose wrt the
    %   world frame and typically the root node is being actively moved by
    %   a motion simulator. For rendering and dynamic simulation it is
    %   fundamental to need to know the position and orientation of every
    %   part of an object in the world frame. Therefore, the pose
    %   "propagation" problem comes down to computing the poseWrtWorld of
    %   every node in the tree once the root is moved. That is a
    %   traditional tree traversal with some matrix multiplication
    %   occurring at each node.
    %
    %   The nomenclature is based on:
    %       mod = model frame of this
    %       par = parent frame
    %       wld = world frame
    %
    %   While this class would be more readable if poses were stored as
    %   vectors, that would imply a pose-HT-pose operation every time it is
    %   touched, so pose data is stored instead in terms of homogeneous
    %   transforms (HTs) in order to make animation efficient. As a
    %   compromise, the most commonly used functions accept pose vectors as
    %   arguments and will convert them to internal form.
    %
    %   This class only handles the storage and propagation of pose
    %   information. The containment hierarchy is managed and stored
    %   externally to here.
    %
    %   The verbs in the function names are suggestive of their frequency
    %   of use, The propagation of motion (poseWrtWorld) is the expensive
    %   part and you have to "update" it on a regular basis in animation.
    %   It is also the only part that really propagates. The poseWrtParent
    %   information is by definition a relative pose in a network always of
    %   length one, so you can "set" it and forget it unless you are
    %   altering configuration, or attachment, or modelling articulation.
    %
    %   Note that configurables are moveables by default based on the
    %   inheritance hierarchy. It does not have to be that way in general
    %   but for this system, there is no use for a containment hierarchy
    %   for objects that do not move.
    %
    %   $Author: AlonzoKelly $  $Date: 2020/07/15 14:00:00 $ $Revision: 2.0 $
    %   Copyright: Alonzo Kelly 2020
    %
    properties(Constant)

    end
    
    properties(Access = protected)
        isLeafNode; % set if this is a leaf node in the containment tree
        modToPar = [ 1 0 0; 0 1 0; 0 0 1]; % HT of model frame wrt parent frame
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
            
        end
    end
    
    methods(Access = public)
        
        function poseWrtParent = getPoseWrtParent(obj)
        %getPoseWrtParent Returns the pose of this object wrt its parent.
        %
        % This is a convenience function for users who want the pose in
        % vector form.
        %
        end
        
        function matToParent = getMatToParent(obj)
        %getMatToParent Returns the HT of this object wrt the parent.
        %
        % This is a convenience function for users who want the pose in
        % matrix form.
        %
        end
        
        function obj = configurable(isLeafNode)
        %configurable Creates an instance of this class.
        %
        %   configurable(isLeafNode) will create an instance and set the
        %   leafNode flag as indicated.
        %
        end
        
        function setPoseWrtParent(obj,parPose)
        %setPoseWrtParent Changes the pose of this node wrt its parent.
        %
        % setPoseWrtParent(parPose) Accepts a pose or a homogeneous
        % transform as an argument. For a typical node in a pose tree.
        % changing this pose is an expression of either real-time
        % "articulation" (not motion) or longer term configuration changes.
        % 
        % It is tempting to also update the pose wrt world in this function
        % based on how much the poseWrtParent has moved but we do not know
        % if the parent has been or is being moved yet, so that caller has to
        % be responsible for that.
        % 
        % This pose is undefined for a root node of a pose tree because it
        % has no parent and its parent, in this system, is NOT the world
        % frame. Use the other (world relative) pose to move such a node.
        % In a sense, having no parent really means being free to move in
        % the world.
        %
        end
        
        function obj = updatePoseWrtWorld(obj,parToWld)
        %updatePoseWrtWorld Updates the pose of this object in the world.
        %
        % updatePoseWrtWorld(parToWld) This function is intended to capture
        % real time motion. It is used to propagate motion changes down a
        % pose tree. Accepts a pose or a homogeneous transform as an
        % argument. That argument is the world relative pose of the PARENT
        % of this object in the tree. Given how the parent has moved (in
        % the new incoming value of parToWld), this function figures out
        % how this object has moved.
        %
        % If this object is a leaf node in the pose tree, its geometry
        % (shape points) will be moved as well. This function should not be
        % called on a root node. Its poseWrtWorld is set separately in
        % simulation by calling setPoseWrtWorld in class "moveable".
        %
        end
        
    end
end