%-----------------------------------------------------------
% Trace Stack of the Number of Cars
%-----------------------------------------------------------
 
classdef TraceOfCarNum < handle
    properties(SetAccess=public,GetAccess=public)
        CarNumRecord;
    end
    methods
        function c = TraceOfCarNum(i)
            if nargin ~=0
                c(i,1).CarNumRecord = [];
            end
        end
    end
end
