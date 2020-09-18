classdef palletSailShape < shape
    %palletSailShape A palletSailShape Shape.
    %
    %   A palletSailShape shape with an optional sail. Shapes are 2D so the
    %   base and the sail have the same z coordinate. Accordingly. the base
    %   of the pallet is marked as invisible to lidar so the laser beam
    %   goes through it and hits the sail. The geometry is defined in the
    %   palletSailModel class.
    %
    %   $Author: AlonzoKelly $  $Date: 2020/07/15 14:00:00 $ $Revision: 2.0 $
    %   Copyright: Alonzo Kelly 2020
    %
    properties(Constant)
        plot_props = {'LineStyle','-', 'LineWidth', 2, 'Color','Blue'}; % drawing specification
    end
    
    properties
        do_sail;        % no sail is constructed if false.
    end
    
    methods
        function obj = palletSailShape(do_sail,varargin)
            %palletSailShape Constructs an instance of this class.
            %
            %   palletSailShape(do_sail,varargin) constructs a
            %   palletSailShape. Only the base is drawn if do_sail is
            %   false. Arguments "varargin", if present, are compatible with shapeList.
            %   
            
        end
    end
end