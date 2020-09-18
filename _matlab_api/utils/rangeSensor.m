classdef rangeSensor< handle
    %rangeSensor a range sensor object.
    %
    %   rangeSensor stores the pose of the sensor on the robot and provides
    %   convenient related functions. For the raspbot, the sensor happens to
    %   be located right over the center of the robot so the physical pose is
    %   the null pose. However, the lidar data is often rotated with respect
    %   to the sensor's forward axis. This angular offset in the data is
    %   treated here as a rotation of the sensor frame with respect to the
    %   robot frame. This class defaults to the rotation of one robot (#10)
    %   so you may want to calibrate the true angle for a differant robot.
    %
    %   $Author: AlonzoKelly $  $Date: 2020/07/15 14:00:00 $ $Revision: 2.0 $
    %   Copyright: Alonzo Kelly 2020
    %
    
    properties(Constant)
        thOffset10 = -5.0*pi/180.0 % angular offset (sWrtR observed on raspbot 10 Oct 9, 2016
        %maxUsefulRange = 2.5; % Neato
        %minUsefulRange = 0.05;% Neato
        maxUsefulRange = 2.0;  % range window maximum
        minUsefulRange = 0.06; % range window minimum
    end
    
    properties(Access = private)

    end
    
    properties(Access = public)
        sensorPose = [0.0;0.0;rangeSensor.thOffset10]; % sensor is at center of robot
    end
    
    methods(Static = true)

    end
    
    methods(Access = private)
        
    end
            
    methods(Access = public)
        
        function obj = rangeSensor(varargin)
            % Constructs a rangeSensor.   
            %
            %   rangeSensor() will construct a sensor at the default pose on
            %   the robot
            %
            %   rangeSensor(sensorWrtRobot) will construct a sensor at the
            %   provided pose on the robot. sensorWrtRobot is a 3X1 vector.
            %
            if(nargin == 1)
                obj.sensorPose = varargin{1};
            end
        end
        
        function senToRob = getSenToRob(obj)
            %getSenToRob Returns the SenToRob homogeneous transform. 
            %
            %   senToRob = obj.getSenToRob() Produces the HT that converts
            %   coordinates from the sensor frame to the robot frame.
            %
            %senToRob = pose(obj.sensorPose).bToA();
            senToRob = pose(obj.sensorPose);
        end
        
        function robToSen = getRobToSen(obj)
            %getRobToSen Returns the SenToRob homogeneous transform. 
            %
            %   robToSen = obj.getRobToSen() Produces the HT that converts
            %   coordinates from the robot frame to the sensor frame.
            %
            %senToRob = pose(obj.sensorPose).aToB();
            robToSen = pose(obj.sensorPose)^-1;
        end
    end
end