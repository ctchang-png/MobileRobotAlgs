classdef polyLine < animatedShape
    %polyLine A class that holds a list of (x,y) coordinates. 
    %
    %   This class is functionally equivalent to animatedShape but its
    %   purpose is to clarify the intention of the user to specify the
    %   shape explicitly as a list of points.
    %
    %   NOTE: This help file may be shadowed by other MATLAB toolboxes and
    %   not visible when you "view help". In my case, I turned off help for
    %   the image processing toolbox (in Preferences>Help) in
    %   order to see it.
    %
    %   $Author: AlonzoKelly $  $Date: 2020/07/15 14:00:00 $ $Revision: 2.0 $
    %   Copyright: Alonzo Kelly 2020
    %
    
    properties(Constant)
    end
    
    properties(Access = public)
    end
            
    methods(Static)
    end
    
    methods(Access = public)
        function obj = polyLine(varargin)
        %polyLine Creates an instance of this class.
        %   polyLine() creates an empty instance
        %   polyLine(mPts) creates an instance with 3XN homogeneous array of
        %   points mpts to decribe its shape.
        %   polyLine(mPts,myPoseWrtParent) also sets the pose of this polyLine wrt its parent.   
        %
        end
    end
end