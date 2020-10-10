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
                Vr = Vr * vMax/max(abs(Vr), abs(Vl));
                Vl = Vl * vMax/max(abs(Vr), abs(Vl));
            end
            rIF.sendVelocity(Vl, Vr)
        end
    end
    
end
