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
           ranges = Perceptor.lidarDataGetter();
           X = obj.irToXy(1:360, ranges);
           x = X(1,:);
           y = X(2,:);
           mask = zeros(1, 360);
           for ii = 1:360
                if isnan(x(ii)) || isnan(y(ii))
                    mask(ii) = false;
                else
                    mask(ii) = radius <= norm([x(ii);y(ii)]-center);
                end
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
            xPoints = points(1,:)';
            yPoints = points(2,:)';
            searchRad = 1.1*palletSailModel.sail_width/2;
            xrep = repmat(xPoints, 1, length(xPoints));
            yrep = repmat(yPoints, 1, length(yPoints));

            xcrep = repmat(diag(xrep)', length(xPoints), 1);
            ycrep = repmat(diag(yrep)', length(yPoints), 1);

            %Each col i is coord relative to point i
            xc = xrep - xcrep;
            yc = yrep - ycrep;
            
            distFromCentSqr = xc.*xc + yc.*yc; 
            mask = distFromCentSqr < searchRad^2;

            x = xrep .* mask;
            y = yrep .* mask;
            numPts = sum(mask, 1);
            xBar = sum(x, 1) ./ numPts;
            xBarRep = repmat(xBar, size(xrep, 1), 1);
            yBar = sum(y, 1) ./ numPts;
            yBarRep = repmat(yBar, size(yrep, 1), 1);
            X = (x - xBarRep);
            Y = (y - yBarRep);

            diagonal = zeros(size(numPts)); %allocate
            thetas = zeros(size(numPts));
            for col = 1:length(numPts)
                colmask = mask(:,col);
                x = X(:,col);
                x = x(colmask);
                y = Y(:,col);
                y = y(colmask);
                Ixx = x' * x;
                Iyy = y' * y;
                Ixy = - x' * y;
                Inertia = [Ixx, Ixy;Ixy, Iyy] / numPts(col); % normalized
                lambda = eig(Inertia);
                lambda = sqrt(lambda) * 1000;
                diagonal(col) = norm([x(end) - x(1); y(end) - y(1)]);
                thetas(col) = atan2(2*Ixy, Iyy-Ixx)/2;
            end
            theoDiag = norm([palletSailModel.sail_width, palletSailModel.sail_depth]);
            diff = abs(diagonal - theoDiag);
            idx = find(diff == min(diff));
            idx = idx(1); %in case there are two identical means
            palletPose = [xBar(idx), yBar(idx), thetas(idx)];
       end
   end
end