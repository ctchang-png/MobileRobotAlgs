classdef Executor < handle
    properties
        model;
    end
    
    methods
        function obj = Executor(model)
           obj = obj@handle;
           obj.model = model;
        end
        
        function sendControl(obj, rIF, u)
            V = u(1);
            om = u(2);
            W = obj.model.W2;
            vMax = obj.model.vMax;
            
            Vr = V + om*W;
            Vl = V - om*W;
            if (abs(Vr) > vMax || abs(Vl) > vMax)
                scale = vMax / max(abs(Vr), abs(Vl));
                Vr = Vr * scale;
                Vl = Vl * scale;
            end
            if Vr > 0.500 || Vl > 0.500
                disp('youre fuckin bad at coding')
            end
            rIF.sendVelocity(Vl, Vr)
        end
    end
    
end
