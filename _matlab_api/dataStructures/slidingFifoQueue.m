classdef slidingFifoQueue < handle
    %slidingFifoQueue A First-In-First-Out queue 
    %
    %   A quick and dirty First-In-First-Out queue based on short vectors.
    %   It is "sliding" because the data is moved to shift it rather than
    %   using pointers or wraparound indexing, which is a more common
    %   approach. Sliding is feasible only for short queues and it is done
    %   here so that you can run interp1 on the queue to interpolate it. 
    %
    %   Intended to be used for modelling delays in real-time systems. The
    %   length of the queue should be small for performance reasons.
    %   interp1 requires two arrays that it calls "x" and "y". We will use
    %   a time array  for "x" and both true "x" and true "y" arrays in two
    %   separate calls to interp1. interp1 requires that the "x" array be
    %   monotone and have unique values in it. In other words, every time
    %   put in the time queue must be strictly greater than every time put
    %   it before it. Absent bugs, that is a pretty reasonable expectation
    %   for a time.
    %
    %   That therefore means this queue has to grow from zero to some
    %   finite length by adding at the right and then eventully throwing
    %   data out on the left when it reaches maximum length. All of this is
    %   feasible in MATLAB for short vectors but this is definitely a
    %   nonstandard data structure.
    %
    %   simDiffSteer uses this structure. simDiffSteer also includes more
    %   functionality to avoid indexing off the end of the queue and it
    %   actually calls interp1 for interior points in the queue.
    %
    %   $Author: AlonzoKelly $  $Date: 2020/07/15 14:00:00 $ $Revision: 2.0 $
    %   Copyright: Alonzo Kelly 2020
    %
    
    properties(Constant)
    end
    
    properties(Access = private)
        maxElements;
    end
    
    properties(Access = public)
        que;
    end
    
    methods(Static = true)
        
    end
    
    methods(Access = private)
         
    end
            
    methods(Access = public)
        
        function obj = slidingFifoQueue(maxElements)
        %slidingFifoQueue Constructs a sliding first-in-first-out queue.
        %
        %   queue = slidingFifoQueue(num) creates a queue with num elements.
        %
        end
        
        function add(obj,element)
        %add Adds an object to the queue
        %
        %   obj.add(element) adds element to the right of the queue and 
        %   slides the remaining elements to the left.
        %
        end       
        
        function clear(obj)
        %clear Empties the queue
        %
        %   obj.clear() sets the queue to the empty list.
        end   
    end
end