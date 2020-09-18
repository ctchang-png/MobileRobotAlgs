classdef objectFigure < displayList
    %objectFigure A class that renders a displaylist of objects in a window.
    %
    %   Objects here are graphics entities that correspond or relate to a
    %   real thing, so this class is not for plotting graphs of data. More
    %   precisely, the rendered objects must have a getShape() method and a
    %   getPoseWrtParent() method and the data structures need to be
    %   structured as they are for Shapes.
    % 
    %   This class is designed to play nicely with a MATLAB GUI. A figure and
    %   axes will be created if they are not passed in. If they are passed
    %   in, and the figure is standalone, it will be sized and positioned. If
    %   the passed in axes are part of a GUI, they are left alone.
    %
    %   Animation is accomplished elsewhere by editing the XData and YData
    %   in line objects that are plotted initially. In this way the native
    %   capacity of MATLAB to clear and redraw a changing plot is used
    %   without having to erase and redraw objects at the application
    %   level.
    %
    %   This class is in 'axis auto' mode by default. You can also set the
    %   viewport explicitly with the optional "limits" argument in the
    %   constructor (or by calling setLimits()) or you can use the
    %   scrollFigure derived class to keep a particular object (usually the
    %   robot) in view.
    %
    %   Hierarchy: This class inherits from displayList and performs
    %   special traversals to accomodate attachment and detachment. See the
    %   discussion of displayList structure in displayedShape.showShape().
    %
    %   Events and Pick Correlation: This class provides a means
    %   (editingMouseHandlers) for you to place the window in a mode where
    %   users can click on objects in a window and manipulate them. This
    %   was done to allow an object to be moved with your mouse while
    %   visible to lidar and while the simulated robot is trying to follow
    %   or avoid it. You mostly do not have to manage any of this. Just turn
    %   on the handlers and click away. These are expensive so don't use
    %   them all the time.
    %
    %   This class is in "hold on" state most of the time but it should
    %   never become the currently selected figure unless you make that
    %   happen. That should mean you can do whatever you want with other
    %   MATLAB figures but if you write in this class yourself (without
    %   adding to the dispay list), your content will all be erased on the
    %   next draw.
    %
    %   $Author: AlonzoKelly $  $Date: 2020/07/15 14:00:00 $ $Revision: 2.0 $
    %   Copyright: Alonzo Kelly 2020
    %

    properties
		name;       % Name for this window
        limits;     % MATLAB viewport limits in form [xmin xmax ymin ymax]
        figHandle;  % MATLAB figure handle
        axHandle;   % MATAB axes handle
    end
    
    properties (Access = 'protected')
        do_draw_grid=true;  % Draws axis tick marks if on
        do_axis_auto=true;  % MATLAB axis auto mode if on
    end
    
    properties (Access = 'private')             
        leftButtonPressed=false;	% Mouse event as named.
        rghtButtonPressed=false;    % Mouse event as named.
        leftButtonReleased=false;   % Mouse event as named.
        rghtButtonReleased=false;   % Mouse event as named.
        mouseMotion=false;          % True if mouse is moving
        mousePoint;
        curObj; % current selected object
    end

    methods
		function oF = objectFigure(name,limits,axHandle)
        %OBJECTFIGURE creates an object figure.
        % 
        %   objectFigure(name) creates a figure with the provided
        %   name and a default viewport.
        %
        %   objectFigure(name,limits) creates a figure with the provided
        %   name and limits array to define its viewport.
        %
        %   objectFigure(name,axHandle) creates a figure with the provided
        %   name, and a default viewport, in a pre-existing set of axes.
        %
        %   objectFigure(name,limits,axHandle) lets the user
        %   pass in limts and a pointer to a pre-existing set of axes.
        %
        
        %   Slight trickery here in parsing varrgin to allow the limits to
        %   be omitted while axHandle is specified.
            if exist('limits','var')
                if(isa(limits,'matlab.graphics.axis.Axes'))
                    axHandle = limits;
                    clear limits;
                else
                    oF.limits = limits;
                    oF.do_axis_auto=false;
                end
            end
            
            if ~exist('axHandle','var')
                figure('Name',name);
                axis equal;
                oF.axHandle = gca(); % force creation and get the axes for this figure
            else
                oF.clearAll(); % reusing existing window
                oF.axHandle = axHandle;
            end
            
            oF.figHandle = gcf();
            %oF.displayList = displayList();
            %oF.figHandle.set('HandleVisibility','off'); % let no one else draw in here
       
            % set initial and default window size based on the aspect
            % screen size (bottom left of window in screen center) and the 
            % aspect ratio of the plot itself.
            oF.resetGraphics();
        end
        
        function setLimits(oF,limits)
        %SETLIMITS Sets the limits of the viewport. Turns off automatic zoom.
        % 
        end
        
        function dS = addObj(oF,shOrDs,varargin)
        %addObj Adds a shape or a displayedShape to the display list for this window.
        %
        % This function is placed here rather than in the displayList
        % superclass so that the caller does not have to form a
        % displayedShape before a shape is added. On the other hand, if you
        % pass in a displayedShape, it will be added directly. Whethet you
        % pass in a displayedShape or retain the handle returned by this
        % function, this is very useful if you want to retain a handle to a
        % displayedShape to control its drawing properties (aka "plot spec").
        %
        % addObj(oF,shOrDs) adds the shape or displayedShape with default plot
        % specification.
        %
        % addObj(oF,shOrDs,plotSpec) adds the shape or displayedShape with
        % specified plot specification.
        %
        % Returns the displayedShape that is created. This permits you to,
        % for example, turn off its visibility or change its plot properties.
        %
        end
        
        function delObj(oF,phOrSh)
        %delObj Deletes a shape from the display list of this window.
        %
        % delObj(oF,shape) Deletes a displayedShape from the display list
        % which corresponds to the supplied shape or displayedShape.
        % Thereafter, it will cease to appear in the window, or it may be
        % garbage collected if no other valid handles exist. If you retain
        % a handle to it, it will not be garbage collected. The argument
        % can be a a shape or its corresppnding dispayedShape the caller
        % typically does not have to know the handle to the corresponding
        % displayShape because it may have been generated internally. This
        % method could go in displayList but it is left here with its
        % complementary add method.
        %
            %oF.displayList.delObj(shape);
        end
        
        function clearAll(oF)
        %clearAll Removes everything in the window.
        % 
        % clearAll Gets back to original empty state without deleting the window or
        % the axes. Provided for persistent GUI windows and axes.
        
            % careful. calling cla() on null will create a figure !!!
        end
        
        function close(oF)
        %CLOSE Closes the window.
        % 
        end
                
        function show(oF)
        %show Redraws everything in the window based on its latest shape,
        %pose, and plot spec data.
        % 
        %   show() Erases everything in the window and redraws. If anything has
        %   moved, it will be animated.
        %
        %   This function calls drawnow limitrate to flush the event queue.
        %   Therefore, you probably do not want to call drawnow yourself too
        %   often (or maybe ever) to avoid the cost of excessive context switching.
        %           
            % draw every object at its present position
        end
        
        function setVisible(oF,val)
        %setVisible Sets the visibility flag for the window.
        %
        %   This function is used to show the window or not. Use the char
        %   array 'on' or 'off' for val.
        % 
        %   One use of this function is to add objects to the window while it
        %   is still invisible without having to worry about saving the contents 
        %   elsewhere until it is time to show it. That techique is used to
        %   add walls to the world model before the robot is created.
        %      
        end
                    
        function f = getAxHandle(oF)
        %getAxHandle Returns the MATLAB axis handle for this window.
        end
        
        function setDefaultMouseHandlers(oF)
        %setDefaultMouseHandlers Registers default mouse handlers.
        %
        % setDefaultMouseHandlers Registers mouse handlers for mouse
        % clicks, and releases. These handlers allow you to poll for mouse
        % events without setting up your own handlers and dealing with
        % concurrent programming issues. The following member variables are
        % booleans etc. They are set by the handlers when the indicated
        % event occurs but they are never cleared.
        %
        %   leftButtonPressed;
        %   rghtButtonPressed;
        %   leftButtonReleased;
        %   rghtButtonReleased;
        %   mousePoint; % (x,y) position of mouse during click events
        %
        % You will normally want to detect an event, so the procedure is to
        % clear the particular state you care about (e.g. left mouse down)
        % and then enter while loop that waits until the state is set.
        % 
        % The default handlers are defaultButtonDownFcn, and defaultButtonUpFcn.
        %
            % setup mouse listeners that can be queried
        end
        
        function setDefaultMotionHandler(oF)
        %SETDEFAULTMOTIONHANDLER Registers the default mouse motion handler.
        % setDefaultMotionHandler Registers the default mouse handler for
        % mouse motion. This handlers allows you to poll for mouse events
        % without setting up your own handlers and dealing with concurrent
        % programming issues. The following member variables are booleans
        % etc. set by the handler when the indicated event occurs but they
        % are never cleared.
        %
        %   mouseMotion;
        %   mousePoint; % (x,y) position of mouse during motion events
        %
        % You will normally want to detect an event, so the procedure is to
        % clear the particular state you care about (e.g. mouseMotion) and
        % then enter while loop that waits until the state is set.
        % 
        % The default handler is defaultMouseMotionFcn. This handler is called
        % every time the mouse moves, so it can waste a lot of CPU cycles.
        % It may be adviseable to register it only when the mouse is in the
        % state you want (e.g. left button down) and then clear it as soon
        % as you are done with it. See clearDefaultMotionHandler to remove
        % it.
        %
            % setup mouse listener that can be queried
        end
        
        function clearDefaultMotionHandler(oF)
        %CLEARDEFAULTMOTIONHANDLER Removes the default mouse motion handler.
        % clearDefaultMotionHandler Removes the default mouse handlers for
        % mouse motion. This handler is called every time the mouse moves,
        % so it can waste a lot of CPU cycles. It may be adviseable to
        % register it only when the mouse is in the state you want (e.g.
        % left button down) and then clear it as soon as you are done with
        % it. See setDefaultMotionHandler to
        % register it.
        %
            % clear mouse listener
        end
        
        function setEditingMouseHandlers(oF)
        %SETEDITINGMOUSEHANDLERS Registers editing mouse handlers.
        % setEditingMouseHandlers Registers mouse handlers for mouse
        % clicks, and releases. These handlers allow you to poll for mouse
        % events without setting up your own handlers and dealing with
        % concurrent programming issues. The following member variables are
        % booleans etc. They are set by the handlers when the indicated
        % event occurs but they are never cleared.
        %
        %   leftButtonPressed;
        %   rghtButtonPressed;
        %   leftButtonReleased;
        %   rghtButtonReleased;
        %   mousePoint; % (x,y) position of mouse during click events
        %
        % You will normally want to detect an event, so the procedure is to
        % clear the particular state you care about (e.g. left mouse down)
        % and then enter while loop that waits until the state is set.
        % 
        % The editing handlers are editingButtonDownFcn, and editingButtonUpFcn.
        %
            % setup mouse listeners that can be queried
        end
        
        function setEditingMotionHandler(oF)
        %SETEDITINGMOTIONHANDLER Registers the editing mouse motion handler.
        % setEditingMotionHandler Registers the editing mouse handler for
        % mouse motion. This handlers allows you to poll for mouse events
        % without setting up your own handlers and dealing with concurrent
        % programming issues. The following member variables are booleans
        % etc. set by the handler when the indicated event occurs but they
        % are never cleared.
        %
        %   mouseMotion;
        %   mousePoint; % (x,y) position of mouse during motion events
        %
        % You will normally want to detect an event, so the procedure is to
        % clear the particular state you care about (e.g. mouseMotion) and
        % then enter while loop that waits until the state is set.
        % 
        % The editing handler is editingMouseMotionFcn. This handler is called
        % every time the mouse moves, so it can waste a lot of CPU cycles.
        % It may be adviseable to register it only when the mouse is in the
        % state you want (e.g. left button down) and then clear it as soon
        % as you are done with it. See clearEditingMotionHandler to remove
        % it.
        %
            % setup mouse listener that can be queried
        end
        
        function clearEditingMotionHandler(oF)
        %CLEAREDITINGMOTIONHANDLER Rmoves the editing mouse motion handler.
        % clearEditingMotionHandler Removes the editing mouse handlers for
        % mouse motion. This handler is called every time the mouse moves,
        % so it can waste a lot of CPU cycles. It may be adviseable to
        % register it only when the mouse is in the state you want (e.g.
        % left button down) and then clear it as soon as you are done with
        % it. See setEditingMotionHandler to register it.
        %
            % clear mouse listener
        end
    end
    
	methods (Hidden = true, Access = 'protected')
        
        function setFigLimits(oF)
        %setFigLimits sets the limits of the figure without cleaering it.
        %
        %
        end
        
        function resetGraphics(oF)
        %resetGraphics Clears everything in a window.
        %
        %   Also sets its viewport to the default.
        %
        end
        
        function setViewport(oF,pose)
        %setViewport Sets the viewport center to pose.
        %
        %   Sets the viewport to be centered at the position of
        %   the tracked object pose if the tracked object reference point 
        %   is about to leave the field of view.
        %
        end
        
        function defaultButtonDownFcn(oF,varargin)
            %defaultButtonDownFcn Records button down events.
            %
            %   Sets the mousePt and the appropriate buttonPressed state
            %   variable.
            %
        end
        
        function defaultButtonUpFcn(oF,varargin)
            %defaultButtonUpFcn Records button up events.
            %
            %   Sets the mousePt and the appropriate buttonPressed state
            %   variable.
            %            
        end
        
        function defaultMouseMotionFcn(oF,varargin)
            %defaultButtonUpFcn Records mouse motion events.
            %
            %   Sets the mousePt and the mouseMotion state
            %   variable.
            % 
            %fHandle = varargin{1};
        end
        
        function editingButtonDownFcn(oF,varargin)
            %editingButtonDownFcn Records button down events in editing mode.
            %
            %   Sets the mousePt and the appropriate buttonPressed state
            %   variable. For left button, sets the curObj state variable
            %   when an object is selected.
            %
        end
        
        function editingButtonUpFcn(oF,varargin)
            %editingButtonUpFcn Records button up events in editing mode.
            %
            %   Sets the mousePt and the appropriate buttonPressed state
            %   variable. For left button, clears the curObj state variable.
            %
        end
        
        function editingMouseMotionFcn(oF,varargin)
            %editingMouseMotionFcn Processes moue motion events in editing mode.
            %
            %   Sets the mousePt as the mouse moves. Also sets the pose of
            %   the selected object to force it to track the mouse. This is
            %   how you drag an object in a window.
            %
            %fHandle = varargin{1};
        end        
    end
end