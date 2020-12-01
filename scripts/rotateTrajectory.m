classdef rotateTrajectory < ReferenceControl
    %Needs to be filled in
    %probably doesn't need to be as complicated as cubicSpiral
    properties
        numSamples = 0;
        theta = 0;
        w = 0;
        timeArray = [];
        poseArray = [];
    end
    
    methods (Access = private)
       %Put any helper methods here if necessary
        
    end
    
    methods (Access = public)
        function obj = rotateTrajectory(parameters)
            obj = obj@ReferenceControl();
            obj.theta = parameters(1);
            obj.w = parameters(2);
        end
        
        function pose = getPoseAtTime(obj, t)
            Tf = obj.getTrajectoryDuration();
            if t > Tf
                th = obj.theta;
            else
                th = obj.theta * (t / Tf);
            end
            x = 0;
            y = 0;
            pose  = [x ; y ; th];
        end
        
        function V = getVAtTime(obj, t)
            V = 0;
        end
        
        function w = getwAtTime(obj, t)
            w = obj.w;
        end
        
        function t = getTrajectoryDuration(obj)
            t  = abs(obj.theta) / obj.w;
        end
        
        function planVelocities(obj,wmax)
       %PLANVELOCITIES Plans velocities for the path.
       %
       %    obj.PLANVELOCITIES(Vmax) plans the highest velocities possible
       %    for the cubic spiral path while ensuring that the absolute
       %    value of all wheel velocities remains below Vmax.
            for i=1:obj.numSamples
                wbase = wmax;
                % Add velocity ramps for first and last 5 cm
                obj.w = obj.warray;
                wf = obj.warray(obj.numSamples);
                if(abs(wf) > 2.0*obj.rampLength) % no ramp for short trajectories
                    wUp = abs(obj.w);
                    wDn = abs(wf-obj.w);
                    if(sUp < obj.rampLength) % ramp up
                        wbase = wbase * wUp/obj.rampLength;
                    elseif(wDn < 0.05) % ramp down
                        wbase = wbase * wDn/obj.rampLength;
                    end
                end
                % Now proceed with base velocity 
                %disp(Vbase);
               
                vr = V + robotModel.W2*obj.w;
                vl = V - robotModel.W2*obj.w;               
                if(abs(vr) > wbase)
                    vrNew = wbase * sign(vr);
                    vl = vl * vrNew/vr;
                    vr = vrNew;
                end
                if(abs(vl) > wbase)
                    vlNew = wbase * sign(vl);
                    vr = vr * vlNew/vl;
                    vl = vlNew;
                end
                obj.vlArray(i) = vl;
                obj.vrArray(i) = vr;
                obj.VArray(i) = (vr + vl)/2.0;
                obj.wArray(i) = (vr - vl)/robotModel.W;                
            end
        end

    end 
end