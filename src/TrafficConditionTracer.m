%-----------------------------------------------------------
% Make Traces of Traffic Conditions
% Using TrafficConditionCombinator
%-----------------------------------------------------------
 
function out = TrafficConditionTracer(obj,index,nodeID)
    element1 = obj.SpeedDataDay1(ismember(obj.SpeedDataDay1(:,1),index),:);
    element2 = obj.SpeedDataDay2(ismember(obj.SpeedDataDay2(:,1),index),:);
    element3 = obj.SpeedHistoryData(ismember(obj.SpeedHistoryData(:,1),index),:);
    
    out = [TrafficConditionCombinator(element1,nodeID),TrafficConditionCombinator(element2,nodeID),TrafficConditionCombinator(element3,nodeID)];
end
