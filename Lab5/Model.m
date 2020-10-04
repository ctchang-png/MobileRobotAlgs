classdef Model < handle
    properties (Constant)
        W = 0.090;
        W2 = 0.045;
        t_delay = 0.1632;
    end
   
    methods
        function obj = Model()
            obj = obj@handle;
        end
        
        function [V om] = lr2vw(vl, vr)
            V = (vr + vl)/2;
            om = (vr - vl)/(2*robotModel.W2);
        end
        
        function [vl vr] = vw2lr(V, om)
            vl = V - om*robotModel.W2;
            vr = V + om*robotModel.W2;
        end
    end
end