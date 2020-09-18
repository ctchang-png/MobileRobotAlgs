classdef cellTree < cellList
    %cellTree A subclass of cellList that permits lists of lists.
    %
    %   The purpose of this class is to override the addObj() method of
    %   cellList to prevent explosion of an incoming list into its
    %   components before it is added. The delObj() method is overriden also. 
    %
    %   This structure is useful in representing hierarchy. In fact, a list
    %   whose elements may also be lists is the manner in which most
    %   computer languages represent trees and graphs.
    %
    %   Despite the name, nothing in here prevents you from building
    %   directed acyclic graphs (which are decidedly not trees). In other
    %   words, the same node can appear as a child to more than one parent.
    %   Indeed, that occurs in this system at a higher level because shapes
    %   can be BOTH at the top level of the displayList and attached to
    %   something else at a lower level.
    %
    %   This class is wholly about structure: parents, children, sibings,
    %   addition and deletion etc. If you want the nodes in the structure
    %   to mean something, that is done outside here.
    %
    %   $Author: AlonzoKelly $  $Date: 2020/07/15 14:00:00 $ $Revision: 2.0 $
    %   Copyright: Alonzo Kelly 2020
    %
    properties

    end
    
    methods (Static)
        function testClass()
            %testClass Some convenient tests that can be run from the console.
            %
            %   You run this static method with className.testClass. There is
            %   no need to create an instance of the class, so you can test
            %   it from the console. Set breakpoints in the code to see
            %   what is happening.
            %
            %   Run this function when you change something to see if the
            %   code still works. Beware that these test routines are not
            %   maintained after the code they are testing is working, so
            %   testClass itself may not work anymore.
            %
            
            % test that you can add a shape to a cellList of shapes.
        end
    end
    
    methods
        function cT = cellTree(theClass,varargin)
            %cellTree Construct an instance of this class
            %
            %   cellList(cT,theClass) will construct an empty instance for
            %   the specified class
            %
            %   cellList(cT,theClass,cellvec) will also add the cell vector (row or column) of objects
            %
            %   cellList(cT,theClass,cellTree) will also add the cellTree
            %   of objects (as a tree)
            %
        end
                
        function addList(cT,obj)
            %addList adds a list of objects.
            %
            %   cT.addList(obj) In this class, a list of objects is added as a list. The
            %   base class method cellList will explode such a list and add its
            %   components but that does not occur here.
            %
        end
        
        function delObj(cT,obj)
            %delObj Deletes the object from this list.
            %
            %   cT.delObj(obj) will delete one object 
            %   
            %   cT.delObj(objects) will delete the cell vector (row or column) of objects
            %
            %   Deletes all instances, not just the first. Depends on the
            %   == test working for the class you are storing in this list.
            %
        end
    end

end

