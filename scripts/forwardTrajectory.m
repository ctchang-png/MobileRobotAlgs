classdef forwardTrajectory < ReferenceControl
    %Needs to be filled in
    %probably doesn't need to be as complicated as cubicSpiral
    properties
        numSamples = 0;
        parms = 0;
        distArray = [];
        timeArray = [];
        poseArray = [];
        vlArray = []
        vrArray = []
        VArray = [];
    end
    
    methods (Access = private)
       %Put any helper methods here if necessary
       
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
    end
    
    methods (Access = public)
        function obj = forwardTrajectory(parameters, numSamples)
            obj = obj@handle();
            obj.parms = parameters;
            obj.numSamples = numSamples;
            obj.computeTimeSeries();
        end
        
      
        function pose = getPoseAtTime(obj, t)
            x = interp1(obj.timeArray,obj.poseArray(1,:),t,'pchip','extrap');
            y = interp1(obj.timeArray,obj.poseArray(2,:),t,'pchip','extrap');
            th = interp1(obj.timeArray,obj.poseArray(3,:),t,'pchip','extrap');
            pose  = [x ; y ; th];
        end
        
        function V = getVAtTime(obj, t)
            if( t < obj.timeArray(1))
                V = 0.0;
            else
                V  = interp1(obj.timeArray,obj.VArray,t,'pchip','extrap');  
            end
        end
        
        function w = getwAtTime(obj, t)
            if(t < obj.timeArray(1))
                w = 0.0;
            else
                w  = interp1(obj.timeArray,obj.wArray,t,'pchip','extrap');  
            end
        end
        
        function t = getTrajectoryDuration(obj)
            t  = obj.timeArray(:,obj.numSamples);  
        end
        
        function u = planTrajectory(x,y,th,sgn);
            t = 0;
            for t = 1:obj.numSamples
                if t == 1
                    u(t) = 0;
                else
                u(t) = u(t-1) + x/obj.numSamples;
                end
            end
            
        end
        
         function planVelocities(obj,Vmax)
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
                vr = V;
                vl = V;               
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
            end
            % Now compute the times that are implied by the velocities and
            % the distances.
            obj.computeTimeSeries();
        end

           
    end 
end