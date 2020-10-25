classdef Perceptor < handle
    %Todo:
    %function RegionOfInterest(arc || box) in robot frame
    %   Returns detected points in ROI in robot frame
    %
    %function findLineCandidate(Array of points in robot frame)
    %   Returns pose of sail
   properties
       model
   end
   
   methods (Static)
        function ranges = lidarDataGetter()
            global lidarData;
            global updatedSincePullLidar;
            while ~updatedSincePullLidar
                pause(0.001)
            end
            ranges = lidarData;
            updatedSincePullLidar = false;
        end    
   end
   
   
   methods
       function obj = Perceptor(model)
           obj = obj@handle;
           obj.model = model;
       end
      
        
       function X = irToXy(obj, i, r)
            th = (i.' - 1) * (pi/180) + obj.model.lidarOffset*(pi/180);
            x = r .* cos(th);
            y = r .* sin(th);
            X = [x, y]';
       end
       
       function points = ROI_circle(obj, radius, center)
           ranges = lidarDataGetter();
           X = obj.irToXy(1:360, ranges);
           x = X(1,:);
           y = X(2,:);
           mask = zeros(1, 360);
           for ii = 1:360
                mask(ii) = radius >= norm([x(ii);y(ii)]-center);
           end
           mask = boolean(mask);
           xpts = x(mask);
           ypts = y(mask);
           points = [xpts; ypts];
       end
       
       function findLineCandidate(points)
            %points: [x;y]
            x = points(1,:);
            y = points(2,:);
            Ixx = x' * x;
            Iyy = y' * y;
            Ixy = - x' * y;
            Inertia = [Ixx Ixy;Ixy Iyy] / numPts; % normalized
            lambda = eig(Inertia);
            lambda = sqrt(lambda)*1000.0;
       end
   end
end