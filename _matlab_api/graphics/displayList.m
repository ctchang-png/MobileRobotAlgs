classdef displayList < cellList
    %displayList A list of objects to be drawn in a window.
    %
    %   A displayList stores a list of objects to be drawn as well as the
    %   specification of how and where they are to be drawn. Once you add
    %   to the displayList for a window the added objects will be redrawn
    %   whenever the window is redrawn. 
    %   
    %   Different windows should each have their own displayList and the
    %   same object (shape) can be drawn in different ways in each window
    %   but the pose of the shape is stored in the shape. In other words,
    %   you can have different views of the same thing but only one thing.
    %   If you want the same shape to appear in different places, you need
    %   to make more than one shape instance.
    %
    %   $Author: AlonzoKelly $  $Date: 2020/07/15 14:00:00 $ $Revision: 2.0 $
    %   Copyright: Alonzo Kelly 2020
    %
    
    properties
    end
    
    methods
        function dL = displayList(varargin)
            %displayList Construct an instance of this class
            %   displayList() Constructs an empty instance  of this class.
            %   displayList(objects) Also adds the provided objects which
            %   are provided in the form of a cell vector.
            %
        end
        
        function dS = find(dL,phOrSh)
        %find Finds the displayedShape corresponding to the provided plot handle or shape.
        %
        % find(dLphOrSpr) Finds the displayShape corresponding to the
        % provided plot handle (or shape) "phOrSh" or returns the null list
        % if no match is found.
        %
        % It is possible to test what type phOrSpr is but that is not
        % necessary here and it may be less robust to changes. This
        % function can be used to do pick correlation with MATLAB when the
        % user clicks on an object in a window and you want to get handle
        % to that object to manupulate it.
        %
            % Look for the object
        end
    end
end

