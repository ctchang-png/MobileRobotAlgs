classdef errorModel
    %errorModel A set of parameters for modelling error in WMR sensors and actuators.
    %
    %   This class is a convenient place to store a set of error parameters
    %   for a robot. The parameters could mean the ground truth errors that
    %   are used in a realistic simulation or they could mean the error
    %   models used in a control or estimation system that are only
    %   attempts to capture reality (or simulated reality) but are
    %   generated through some (noise or systematic error) calibration
    %   process.
    %
    %   These error models are used in various places in the system. For
    %   clarity on their meaning, the equations where they are used are:
    %
    %   Encoders:
    %       d_el = d_el*(err_d_el + std_d_el*N());
    %       d_er = d_er*(err_d_er + std_d_er*N());
    %       Where N() is an unbiased gaussian random variable of unit variance.
    %   Commanded Velocities
    %       v_l = v_l*(err_v_l + std_v_l*N());
    %       v_r = v_r*(err_v_r + std_v_r*N());
    %   Lidar
    %       range = range*err_r + std_r*N()*range^2/cos(angle); 
    %       Where the incidence angle is 0 at normal incidence. This angle
    %       captures a physically meaningful stretching of the lirnd(0dar
    %       spot at non-normal incidence angles.
    %
    %   See the comments on the properties for their nominal values. One
    %   consequence of the above (entirely scale factor) models is that
    %   unchanging encoders are not noisy and a command of zero velocity is
    %   uncorrupted. While that is not deliberate, it also does not matter
    %   much and it is pretty realistic due to wheel friction and stable encoders.
    %
    %   The lidar noise model causes the range noise to increase
    %   significantly at glancing incidence but in that case, the range
    %   vector is along the surface so the optical effect is the range
    %   points sliding ALONG the surface.
    %
    properties
        err_d_el=1;   % left encoder systematic scale factor err (very close to 1)
        err_d_er=1;   % rght encoder systematic scale factor err (very close to 1)
        err_v_l=1;    % left velocity systematic scale factor err (very close to 1)
        err_v_r=1;    % rght velocity systematic scale factor err (very close to 1)
        err_r=1;      % lidar systematic scale factor (very close to but < 1)
        std_d_el=0;   % left encoder random scale factor stdv (< 0.05)
        std_d_er=0;   % rght encoder random scale factor stdv (< 0.05)
        std_v_l=0;    % left velocity random scale factor stdv (< 0.05)
        std_v_r=0;    % rght velocity random scale factor stdv (< 0.05)
        std_r=0;      % lidar random additive stdv (0.0033 is 1cm stdv at 1 meter normal)  
    end
end

