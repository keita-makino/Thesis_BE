%-----------------------------------------------------------
% Conbine the Traffic Information That Has Several Rows to One Datum
%-----------------------------------------------------------
 
function out = TrafficConditionCombinator(element,nodeID)    
    if isempty(element)
        out=[nodeID,NaN,NaN,NaN,NaN];
    else
        numTotal=sum(element(:,5));
        out = [nodeID,element(1,2),numTotal,dot(element(:,3),element(:,5))/numTotal];
        out = [out, (dot(element(:,3).^2+element(:,4),element(:,5))/numTotal)-out(4).^2];
    end
end
