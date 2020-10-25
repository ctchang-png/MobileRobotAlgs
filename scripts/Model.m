classdef Model < handle
    properties (Constant)
        W = 0.090;
        W2 = 0.045;
        t_delay = 0.1632;
        vMax = 0.200;
        lidarOffset = -5;
    end
   
    methods
        function obj = Model()
            obj = obj@handle;
        end       
    end
end