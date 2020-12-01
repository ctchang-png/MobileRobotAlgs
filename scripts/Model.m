classdef Model < handle
    properties (Constant)
        W = 0.090;
        W2 = 0.045;
        t_delay = 0.1632;
        vMax = 0.200;
        lidarOffset = -6;
        forkOffset = [0.075; 0];
    end
   
    methods(Static)
        function bodyPts = bodyGraph()
            rad = 0.06; % robot radius
            laser_rad = 0.04; % laser housing radius
            % return an array of points that can be used to plot robot
            % body in a window.
            % angle arrays
            step = pi/20;
            cir = 0: step: 2.0*pi;
            % circle for laser
            lx = laser_rad*cos(cir);
            ly = laser_rad*sin(cir);

            % body with implicit line to laser circle
            bx = [rad*cos(cir) lx];
            by = [rad*sin(cir) ly];

            %create points
            bodyPts = [bx ; by];
        end   
    end
    
    methods
        function obj = Model()
            obj = obj@handle;
        end  
        
    end
end