classdef rangeImage < rangeSensor
    %rangeImage Is a class that provides properties and methods that relate
    %   to range images - not to sensors and not to point clouds. This
    %   class understands the polar coordinate representation of a planar
    %   range image - that is ranges and angles or their indices. It also
    %   inherits from rangeSensor so it knows where the sensor is on the
    %   robot. That is important because it knows how the sensor is rotated
    %   and can therefore operate, to some degree, in robot coordinates.
    %
    %   $Author: AlonzoKelly $  $Date: 2020/07/15 14:00:00 $ $Revision: 2.0 $
    %   Copyright: Alonzo Kelly 2020
    %
    
    properties(Constant)
        numRawPixels = 360;     % intrinsic range points per image
        fieldOfView = 2.0*pi;   % field of view in radians
    end
    
    properties(Access = protected)
        iArray = []; % array of pixel indices (ntegers)
        rArray = []; % array of ranges
        tArray = []; % array of bearings in sensor coordinates
    end

    properties(Access = public)
    end
    
    methods(Static = true)        
        function testClass
        end
    end
    
    methods(Access = private)
        
    end
            
    methods(Access = public)  
        function obj = rangeImage(varargin)
            % Constructs a range image.
            %
            %   Arguments "varargin" are compatible with range sensor and,
            %   if present, specify the pose of the sensor on the robot.
            %
            obj@rangeSensor(varargin{:});                                    
        end
        
        function [x, y, th] = irToXy(obj,i,r)
            %irToXy finds position and bearing of a range pixel endpoint.
            %
            % [x, y, th] = obj.irToXy(i,r) Finds the planar position and
            % bearing of the endpoint of a range pixel relative to the
            % robot. Assumes:
            %
            % a) The index i comes from a fully populated range image of
            % rangeImage.numRawPixels pixels per image.
            %
            % b) Pixel index 1 is aligned with the SENSOR x axis which is
            % itself positioned and oriented with respect to the robot by
            % the sensorPose.
            %
            % c) Indices i increase the beam angle in a counterclockwise
            % direction.
            %
            % The point (x,y) is reported in the ROBOT frame of reference. 
            % The bearing th is defined on the range (-pi,pi).
            %

            fov = obj.fieldOfView;
            th = (i-1)*fov/(obj.numRawPixels-1);
            if(th > pi) 
                th = th - 2.0*pi; 
            end
            sen_x = r * cos(th);
            sen_y = r * sin(th);
            
            rob_pt = obj.getSenToRob()*[sen_x ; sen_y ; 1];
            
            x = rob_pt(1);
            y = rob_pt(2);
        end
                
        function index = indexOfPoint(obj,pt)
            %indexOfPoint 
            %
            %   index = obj.indexOfPoint(pt) converts a point pt expressed
            %   in ROBOT coordinates to the closest range pixel index in
            %   image coordinates that contains that point.
            %
            
            % first convert point to sensor coordinates
            ptSen = obj.getRobToSen()*[pt ; 1.0];
            
            bearing = atan2(ptSen(2),ptSen(1));
            index = round(bearing*180/pi()+1);
        end
        
        function plotRvsTh(obj, maxRange)
            % plotRvsTh Plots the range image in polar coordinates.
            %
            %   Plots in the currently active figure. Plots the range image
            %   after removing all points exceeding maxRange.
            %
            plotRanges = obj.rArray;
            for i=1:length(obj.rArray)
                if(obj.rArray(i) > maxRange); plotRanges(i) = 0.0; end
            end
            plot(obj.tArray,plotRanges,'r.');
            axis([0.0 obj.fieldOfView 0.0 maxRange])
            grid on
        end     
    end
end