%-----------------------------------------------------------
% Trace Stack of Traffic Conditions and Their Derivatives
%-----------------------------------------------------------
 
classdef TraceStack < handle
    properties(SetAccess=public,GetAccess=public)
        trace = TraceOfCarNum;
        dTrace = TraceOfCarNum;
    end
    methods
        function c = TraceStack(i)
            if nargin ~=0
                c(i,1).trace = [];
                c(i,1).dTrace = [];
            end
        end
    end
end
