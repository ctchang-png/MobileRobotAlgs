classdef cellList < handle
    %cellList A linear list of components. 
    %
    %   A basic mechanism to store and manipulate a list of "stuff" in a
    %   standard manner. MATLAB already has ways to store stuff in cell
    %   arrays and object arrays but this class is created to enforce some
    %   standards like: 
    %   1) every list is a homogeneous cell array, not a
    %   matrix or a heterogeneous array or an object array. These are
    %   pretty efficient. 
    %   2) it is a row vector, not a column vector 
    %   3) simple error checking will prevent you making mistakes
    %
    %   Why bother? Because:
    %   1) MATLAB silently coerces your data when you put different things
    %   in an array and, even for derived classes, deletes some of it!
    %   2) MATLAB will occasionally concatenate new information to the
    %   last component of an array rather than to the array itself. No
    %   doubt that is what you asked for but why bother with such subtle
    %   syntax?
    %   3) Your code sometimes breaks when you assume a row is a column or
    %   vice versa.
    %   4) Generally, there are just too many ways to get yourself into
    %   trouble with MATLAB's various ways to provide data sructures in a
    %   math language. And there are too many ways for you to remember
    %   which one is being used unless you impose your own standards on
    %   "your" way of dong things.
    %
    %   This class depends on the isa() MATLAB function to enforce
    %   homogeneity and the delete function here depends on '==' also known
    %   as 'eq' working. eq does work for handles and that is mostly the
    %   intended use of this class. Once you specify "theClass" in the
    %   construtor, only objects of that class (i.e. including subclasses)
    %   are permitted in the structure.
    %
    %   This class also depends on subclasses passing the isa
    %   test for its superclass. In other words if a < b < c then an
    %   instance of a isa c. This property allows you to store numerous
    %   different subclasses in the same list when you want to treat them
    %   as the superclass. In practice here, that means robotShapes,
    %   circleShapes, rangeImageShapes etc are all shapes so they can all
    %   go in a displayList of shapes to remember what is to be rendered.
    %
    %   In THIS class (not cellTree), there is a convention that when a
    %   list is added to a list, the incoming list is exploded into its
    %   components before it is added. This is useful in, for example,
    %   rayCasting which just needs a list of lines (the bare position of
    %   all the points that can reflect lidar) and does not care about the
    %   semantics or hierarchy of the objects participating. If you want
    %   more complicated structure, use the derived class cellTree.
    %
    %   This class is wholly about structure, addition and deletion etc. If
    %   you want the nodes stored in the structure to mean something, that
    %   is done outside here. Think of this class as an abstract data
    %   structure that MATLAB should have provided which is equivalent to
    %   Java's ArrayList.
    %
    %   $Author: AlonzoKelly $  $Date: 2020/07/15 14:00:00 $ $Revision: 2.0 $
    %   Copyright: Alonzo Kelly 2020
    %
       
    properties
        theList = {};
        theClass;
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

            % make sure to enforce homogeneity
            % = cellList('double');
            %newCL.add('this should fail'); % comment me out when not testing this
            
            % make sure add and delete work with doubles
        end
    end

    methods
        function cL = cellList(theClass,objects)
            %cellList Construct an instance of this class.
            %
            %   cL = cellList(theClass) will construct an empty instance for
            %   the specified class (specified as a char array like
            %   'double')
            %
            %   cL = cellList(theClass,cellvec) will also add the MATLAB cell
            %   vector (row or column) of objects one at a time
            %
            %   cL = cellList(theClass,cellList) will also add the cellList
            %   of objects one at a time
            %
        end
        
        function check(cL,obj)
            %check Checks incoming data to see if it is compatible with theClass.
            %
            %   Remember: subclasses of theClass will pass the test and be
            %   admitted and that allows you to structure your inheritnce
            %   to admit a related set of things with a minimum required API.
            %
        end
        
        function addObj(cL,objOrObjs)
            %addObj Adds to this list.
            %
            %   addObj(cL,object) will add one object
            %
            %   addObj(cL,cellvec) will add the MATLAB cell vector (row or column) of
            %   objects one at a time
            %
            %   addObj(cL,cellList) will add the cellList of objects one zt a
            %   time
            %

            % Check this case before cellList because shapes are cellLists and
            % we want to add the entire shape, not its components.
        end

        function addList(cL,obj)
            %addList adds a list of objects.
            %
            %   addList(cL,objWithComponentsList) In this class, a list of
            %   objects is exploded and added as components. This property is
            %   also recursive - so lists of lists are all exploded, all the
            %   way down, into one list.
            %
        end
        
        function delObj(cL,obj)
            %delObj Deletes the object from this list.
            %   delObj(cL,obj) will delete one object 
            %
            %   delObj(cL,cellVec) will delete the cell vector (row or column) of objects
            %
            %   Deletes all instances in the cellList, not just the first.
            %   Depends on the == test working for the class you are
            %   storing in this list.
            %

            % test this before cellList because shapes are cellLists and want the shape deleted, not its contents.
        end
    end
end

