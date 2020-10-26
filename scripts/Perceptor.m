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
       
       function palletPose = findLineCandidate(obj, points)
            %points: [x;y]
            %TODO
            %Vectorize
            %Filter bad points
            xPoints = points(1,:);
            yPoints = points(2,:);
            searchRad = 1.1*palletSailModel.sail_width/2;
            %This can be vectorized
            for ii = 1:size(points,2)
                xc = xPoints(ii);
                yc = yPoints(ii);
                deltaX = xPoints - xc;
                deltaY = yPoints - yc;
                distFromCentSqr = deltaX .* deltaX + deltaY .* deltaY;
                mask = distFromCentSqr < searchRad^2;
                
                x = xPoints(mask)';
                y = yPoints(mask)';
                numPts = length(x);
                if numPts < 20
                    continue
                end
                xBar = sum(x) / numPts;
                yBar = sum(y) / numPts;
                x = x - xBar;
                y = y - yBar;
                
                Ixx = x' * x;
                Iyy = y' * y;
                Ixy = - x' * y;
                Inertia = [Ixx, Ixy;Ixy, Iyy] / numPts; % normalized
                disp(Inertia)
                lambda = eig(Inertia);
                lambda = sqrt(lambda) * 1000;
                disp(lambda)
                if lambda(1) < 1.3 && abs(lambda(2) - 127) < 6 %allow for 5% error now
                    th = atan2(2*Ixy,Iyy-Ixx)/2.0;
                    palletPose = [xBar; yBar; th];
                    break
                end
            end
       end
   end
end