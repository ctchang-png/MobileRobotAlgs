classdef scrollFigure < objectFigure
    %scrollFigure An objectFigure that automatically alters the viewport to keep a
    % particular object in view. 
    %
    %   The size of the viewport is set in the constructor but its center
    %   is changed intermittently to track the particular object. That is,
    %   the window viewport is moved and the window is redrawn when the
    %   object center approaches the edge of the window. The choice of
    %   doing it intermittently is deliberate to allow the viewer to get a
    %   truer sense of the motion of the object in the world rather than an
    %   artificial sense of the world moving past it.
    %
    %   By default, the particular object is the first object added but you
    %   can call setTrackedObject to designate a different particular
    %   object instead. If the object is large relative to the viewport it
    %   is possible that the default 10% scroll border will be too small to
    %   avoid part of the object leaving the window before it is redrawn.
    %   This is fixable by tracking every point on the object but is
    %   considered not to be worth the CPU expense.
    %
    %   The figure can be set up to optionally draw the path of the tracked
    %   object and/or to not scroll.
    %
    %
    %   $Author: AlonzoKelly $  $Date: 2020/07/15 14:00:00 $ $Revision: 2.0 $
    %   Copyright: Alonzo Kelly 2020
    %
    
    properties (Hidden, GetAccess='private', SetAccess='private')
        trackedShape = []; % the object being tracked
        pathPlotHandle = -1; % the tracked object path handle
        do_scroll;      % scroll window or nort
        do_path;        % draw path or not
        do_update;      % path has grown/changed or not
        
        last_x = 0;    % last drawn x
		last_y = 0;    % last drawn y
		last_th = 0;   % last drawn th
    end
    
    methods
		function sF = scrollFigure(name,varargin)
        %SCROLLFIGURE creates a scrolling figure.
        % 
        %   This class has unusually rich argument parsing...
        %
        %   scrollFigure(name) creates a figure with the provided
        %   name and default limits array to define its viewport.
        %
        %   scrollFigure(name,limits) creates a figure with the provided
        %   name and limits array to define its viewport.
        %
        %   scrollFigure(name,limits,axHandle) also lets the user
        %   pass in the pointer to a pre-existing set of axes.
        %
        %   Name-Value pair arguments in addition to (and at the end of)
        %   these positional arguments are also possible:
        %
        %   scrollFigure(...,'DoScroll','Off') will turn scrolling off. It is on
        %   by default.
        %
        %   scrollFigure(...,'DrawPath','Off') will turn path drawing off. It is on
        %   by default.
        %
        %   These NV pairs are optional and they can appear in any order,
        %   but they must appear after all the optional and non optional
        %   positional arguments (axHandle in this case).
        %
        %   When scrolling is off, the figure takes on the axis command
        %   settings inherited from objectFigure.
        %
        
            % Remove parameters specific to this function
            p = inputParser;
            validOnOff = @(x) ischar(x) && (strcmpi(x,'On') || strcmpi(x,'Off'));
            addOptional(p,'limits',[]);
            addOptional(p,'axHandle',[]);
            addParameter(p,'DoScroll','On',validOnOff);
            addParameter(p,'DrawPath','On',validOnOff);
            parse(p,varargin{:});
            % Delete consumed arguments. axHandle is not consumed
            idx = find(strcmp('DoScroll', varargin));
            if (idx ~= 0); varargin(idx:idx+1) = []; end
            idx = find(strcmp('DrawPath', varargin));
            if (idx ~= 0); varargin(idx:idx+1) = []; end

            % Call superclass constructor first
            sF@objectFigure(name,varargin{:});

            % convert N-V argumenta to local variables
            charToBool = @(str) (strcmpi(str,'on'));
            sF.do_path = charToBool(p.Results.DrawPath);
            sF.do_scroll = charToBool(p.Results.DoScroll);

            % specify default limits if it was not done by user
            if(isempty(sF.limits) && sF.do_scroll)
                sF.limits = [-1 1 -1 1];
            end
        end
        
        function show(sF)
        %SHOW Erases everything in the window and redraws. 
        %
        %   If anything has moved, it will be animated. Overrides the show
        %   method of objectFigure in order to scroll and perform path
        %   rendering.
        %           
            % Call the superclass method first. This has axis auto on by
            % default. One call to setViewport will change that.
        end
        
        function setTrackedObject(sF,shape)
        %setTrackedObject Sets the identity of the tracked shape (object).
        % 
        % setTrackedObject(sF,obj) sets the identity of the tracked object
        % to be the provided Shape. The default is the first object added
        % to the figure if this functionn is not called.
        %           
        end
    end
end