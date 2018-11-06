% Traffic Information Container
%-----------------------------------------------------------

classdef CurrentStatus < handle
    properties(SetAccess=public,GetAccess=public)
        SpeedDataDay1;
        SpeedDataDay2;
        SpeedHistoryData;
    end
    methods
        function c = CurrentStatus(i)
            if nargin ~=0
                    c(i,1).SpeedDataDay1 = [];
                    c(i,1).SpeedDataDay2 = [];
                    c(i,1).SpeedHistoryData = [];
            end
        end
    end
end
