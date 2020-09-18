classdef moveable < handle
    %moveable A class for things that can move in the world.
    %
    %   The purpose of this class is to separate configuration information
    %   stored in a "configurable" from the animation information stored here.
    %   Doing so lets us define classes of rigid things that can move via
    %   inheritance of this class, without having all such objects incur the
    %   overhead of hierarchy traversal for many operations.
    %
    %   $Author: AlonzoKelly $  $Date: 2020/07/15 14:00:00 $ $Revision: 2.0 $
    %   Copyright: Alonzo Kelly 2020
    %
    properties(Constant)

    end
    
    properties(Access = protected)
        modToWld = [ 1 0 0; 0 1 0; 0 0 1]; % HT of model frame wrt world frame
    end
            
    methods(Static)
    end
    
    methods(Access = public)
        function poseWrtWorld = getPoseWrtWorld(obj)
        %getPoseWrtWorld Returns the pose of this object in the world.
        %
        % This is a convenience function for users who want the pose in
        % vector form.
        %
        end
        
        function matToWorld = getMatToWorld(obj)
        %getMatToWorld Returns the HT of this object in the world.
        %
        % This is a convenience function for users who want the pose in
        % matrix form.
        %
        end
        
        function obj = moveable()
        %moveable Creates an instance of this class.
        end
    end
end