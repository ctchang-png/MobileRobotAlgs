classdef ReferenceControl < handle
    %Generic ref control class. Update this to fit cubicSpiralTrajectory
    properties
         numSamples = 0;
         parms = 0;
        distArray = [];
        timeArray = [];
        poseArray = [];
        curvArray = [];
        vlArray = []
        vrArray = []
        VArray = [];
        wArray = [];
    end
    
    methods
        function obj = ReferenceControl(parameters, numSamples)
            obj = obj@handle();
            obj.parms = parameters;
            obj.numSamples = numSamples;
            obj.computeTimeSeries();
            obj.planVelocities(0.2);
        end
        
        function refTraj = planTrajectory(x, y, th, sgn)
            refTraj = [x, y, th, sgn];
        end
        
        function computeTimeSeries(obj)
        %COMPUTETIMESERIES Finds the times implied by the distances and the
        % velocities.
            len = obj.numSamples;
            obj.timeArray  = zeros(1,len);

            % Place robot in initial state
            obj.timeArray(1) = 0.0;

            for i=1:obj.numSamples-1
                ds = obj.distArray(i+1) - obj.distArray(i);
                V = obj.VArray(i);
                % Avoid division by zero
                if(abs(V) < 0.001); V = obj.VArray(i+1); end

                obj.timeArray(i+1)= obj.timeArray(i)+ds/V;
            end
        end   
        
      
        function pose = getPoseAtTime(obj, t)
            %GETPOSEATTIME Returns the planned pose of the robot at a given
        % time.
        %
        %   pose = obj.GETPOSEATTIME(t) returns the intended pose of the
        %   robot in the form pose = [x; y; theta] at time t as the robot
        %   traverses a cubic spiral path.
            x = interp1(obj.timeArray,obj.poseArray(1,:),t,'pchip','extrap');
            y = interp1(obj.timeArray,obj.poseArray(2,:),t,'pchip','extrap');
            th = interp1(obj.timeArray,obj.poseArray(3,:),t,'pchip','extrap');
            pose  = [x ; y ; th];  
        end
        
        function V = getVAtTime(obj, t)
            %GETVATTIME Returns the planned linear velocity for the robot at a
        % given time.
        %
        %   v = obj.GETVATTIME(t) returns the intended linear velocity v
        %   for the robot at time t as it travels along the cubic spiral
        %   path.
            if( t < obj.timeArray(1))
                V = 0.0;
            else
                V  = interp1(obj.timeArray,obj.VArray,t,'pchip','extrap');  
            end
        end
        
        function w = getwAtTime(obj, t)
         %GETWATTIME Returns the planned angular velocity for the robot at a
        % given time.
        %
        %   w = obj.GETWATTIME(t) returns the intended angular velocity w
        %   for the robot at time t as it travels along the cubic spiral
        %   path.
            if(t < obj.timeArray(1))
                w = 0.0;
            else
                w  = interp1(obj.timeArray,obj.wArray,t,'pchip','extrap');  
            end
        end
        
        function t = getTrajectoryDuration(obj)
        %GETTRAJECTORYDURATION Returns the amount of time required for the
        % robot to traverse the cubic spiral path.
            t  = obj.timeArray(:,obj.numSamples);  
        end
        
        function planVelocities(obj, Vmax)
             %PLANVELOCITIES Plans velocities for the path.
       %
       %    obj.PLANVELOCITIES(Vmax) plans the highest velocities possible
       %    for the cubic spiral path while ensuring that the absolute
       %    value of all wheel velocities remains below Vmax.
            for i=1:obj.numSamples
                Vbase = Vmax;
                % Add velocity ramps for first and last 5 cm
                s = obj.distArray(i);
                sf = obj.distArray(obj.numSamples);
                if(abs(sf) > 2.0*obj.rampLength) % no ramp for short trajectories
                    sUp = abs(s);
                    sDn = abs(sf-s);
                    if(sUp < obj.rampLength) % ramp up
                        Vbase = Vbase * sUp/obj.rampLength;
                    elseif(sDn < 0.05) % ramp down
                        Vbase = Vbase * sDn/obj.rampLength;
                    end
                end
                % Now proceed with base velocity 
                %disp(Vbase);
                V = Vbase*obj.sgn; % Drive forward or backward as desired.
                K = obj.curvArray(i);
                w = K*V;
                vr = V + robotModel.W2*w;
                vl = V - robotModel.W2*w;               
                if(abs(vr) > Vbase)
                    vrNew = Vbase * sign(vr);
                    vl = vl * vrNew/vr;
                    vr = vrNew;
                end
                if(abs(vl) > Vbase)
                    vlNew = Vbase * sign(vl);
                    vr = vr * vlNew/vl;
                    vl = vlNew;
                end
                obj.vlArray(i) = vl;
                obj.vrArray(i) = vr;
                obj.VArray(i) = (vr + vl)/2.0;
                obj.wArray(i) = (vr - vl)/robotModel.W;                
            end
            % Now compute the times that are implied by the velocities and
            % the distances.
            obj.computeTimeSeries();
        end
        
        function plot(obj)
        %PLOT Plots the pose array for the cubic spiral.
            plotArray1 = obj.poseArray(1,:);
            plotArray2 = obj.poseArray(2,:);
            plot(plotArray1,plotArray2,'r');
            xf = obj.poseArray(1,obj.numSamples);
            yf = obj.poseArray(2,obj.numSamples);
            r = max([abs(xf) abs(yf)]);
            xlim([-2*r 2*r]);
            ylim([-2*r 2*r]);
        end      
    end
   
    
end