%-----------------------------------------------------------
% Evaluate the Intensity of Attraction at Every Node
%-----------------------------------------------------------

function out = StatusTracer(idx,gr,dis,st)
 
% Output is tic-toc
tic
 
% Definition and Allocation
traceStack = TraceStack(6);
for i=1:6
    traceStack(i).trace = TraceOfCarNum(idx);
end
 
% Trace the Traffic
for i=1:idx
    if mod(i,100)==0
        disp(i);
    end
    nodeAreaStackIndex = nearest(gr,i,dis);
    if not(isempty(nodeAreaStackIndex))
        trace = cell2mat(arrayfun(@(x) TrafficConditionTracer(x,nodeAreaStackIndex,i),st(1:144),'UniformOutput',false));
        traceStack(1).trace(i).CarNumRecord = trace(:,1:5);
        traceStack(2).trace(i).CarNumRecord = trace(:,6:10);
        traceStack(3).trace(i).CarNumRecord = trace(:,11:15);
        trace = cell2mat(arrayfun(@(x) TrafficConditionTracer(x,nodeAreaStackIndex,i),st(145:288),'UniformOutput',false));
        traceStack(4).trace(i).CarNumRecord = trace(:,1:5);
        traceStack(5).trace(i).CarNumRecord = trace(:,6:10);
        traceStack(6).trace(i).CarNumRecord = trace(:,11:15);
    end
end
 
% Formatting
for i=1:6
    for j=1:idx
        j
        if size(traceStack(i).trace(j).CarNumRecord) == [0, 0]
            traceStack(i).dTrace(j).CarNumRecord =[];
        else
            traceStack(i).dTrace(j).CarNumRecord(2:143,1:5) =[traceStack(i).trace(j).CarNumRecord(2:143,1), (1:142)', (traceStack(i).trace(j).CarNumRecord(3:144,3:5) - traceStack(i).trace(j).CarNumRecord(1:142,3:5))/2];
        end
    end
end
 
out = toc;
 
% Save
save(['traceStack_',num2str(dis),'.mat'],'traceStack','-v7.3')
return
 
 
 
%% Previous Codes
%-----------------------------------------------------------
% Calculation of traceOfCarNum
%-----------------------------------------------------------
% Canceled Due to Low Performance
% Only the Half of the original Code
            index1=ismember(tempSpeedDataDay1(:,1),nodeAreaStackIndex{:,:});
            index2=ismember(tempSpeedDataDay2(:,1),nodeAreaStackIndex{:,:});
            indexHis=ismember(tempSpeedHistoryData(:,1),nodeAreaStackIndex{:,:});
 
            traceOfCarNum_Holiday1(j).CarNumRecord(i,1)=sum(tempSpeedDataDay1(index1,5));
            traceOfCarNum_Holiday2(j).CarNumRecord(i,1)=sum(tempSpeedDataDay2(index2,5));
            traceOfCarNum_HolidayHis(j).CarNumRecord(i,1)=sum(tempSpeedHistoryData(indexHis,5));
 
            traceOfCarNum_Holiday1(j).CarMeanRecord(i,1)=dot(tempSpeedDataDay1(index1,3),tempSpeedDataDay1(index1,5))/traceOfCarNum_Holiday1(j).CarNumRecord(i,1);
            traceOfCarNum_Holiday2(j).CarMeanRecord(i,1)=dot(tempSpeedDataDay2(index2,3),tempSpeedDataDay2(index2,5))/traceOfCarNum_Holiday2(j).CarNumRecord(i,1);
            traceOfCarNum_HolidayHis(j).CarMeanRecord(i,1)=dot(tempSpeedHistoryData(indexHis,3),tempSpeedHistoryData(indexHis,5))/traceOfCarNum_HolidayHis(j).CarNumRecord(i,1);
 
            traceOfCarNum_Holiday1(j).CarVarRecord(i,1)=(dot(tempSpeedDataDay1(index1,3).^2+tempSpeedDataDay1(index1,4),tempSpeedDataDay1(index1,5))/traceOfCarNum_Holiday1(j).CarNumRecord(i,1))-traceOfCarNum_Holiday1(j).CarMeanRecord(i,1).^2;
            traceOfCarNum_Holiday2(j).CarVarRecord(i,1)=(dot(tempSpeedDataDay2(index2,3).^2+tempSpeedDataDay2(index2,4),tempSpeedDataDay2(index2,5))/traceOfCarNum_Holiday2(j).CarNumRecord(i,1))-traceOfCarNum_Holiday2(j).CarMeanRecord(i,1).^2;
            traceOfCarNum_HolidayHis(j).CarVarRecord(i,1)=(dot(tempSpeedHistoryData(indexHis,3).^2+tempSpeedHistoryData(indexHis,4),tempSpeedHistoryData(indexHis,5))/traceOfCarNum_HolidayHis(j).CarNumRecord(i,1))-traceOfCarNum_HolidayHis(j).CarMeanRecord(i,1).^2;
 
%-----------------------------------------------------------
% Calculation of traceOfCarNum
%-----------------------------------------------------------
% Create a File to Store distanceTable Data
file = fopen('distanceData_1600.csv','w');
header = ['FromID' ',' 'ToID' ',' 'Distance_Graph' ',' 'Distance_Real'];
fprintf(file, '%s\n', header);
fclose(file);
 
% Determine the Max Index for Loops
indexMax = length(unique(roadNet(:,2:3)));
 
% Calculate Distances and Sequencially Save Them
parfor i=1:indexMax
    disp(i);
    tempDist = [ones(1,indexMax)*i;1:indexMax;distances(G,i);distances(G2,i)]';
    tempDist(tempDist(:,3)>1600,:)=[];
    dlmwrite('distanceData_1600.csv',tempDist,'precision', 6, '-append');
end
 
% Read the distanceTable Data and Convert it to a Tall Array
ds = datastore('distanceData_Inf.csv');
T = tall(ds);
 
% Eliminate Unnecessary Data
distanceTable = gather(T);
distanceTable(isnan(distanceTable{:,4}),:)=[];
distanceTable(distanceTable{:,1}<1,:)=[];
distanceTable(distanceTable{:,1}>indexMax,:)=[];
 
% Evaluate Weighed-Mean of the Traffic Conditions and Store it as Static
% Values of Nodes
for i=1:indexMax
    disp(i);
    nodeAreaStackIndex = distanceTable(distanceTable{:,2} == i,1);
    if not(isempty(nodeAreaStackIndex))
        for j=1:144
            %Weekday
            temp = currentStatus2(j);
            
            index1=temp.SpeedDataDay1(ismember(temp.SpeedDataDay1(:,1),nodeAreaStackIndex{:,:}),:);
            index2=temp.SpeedDataDay2(ismember(temp.SpeedDataDay2(:,1),nodeAreaStackIndex{:,:}),:);
            indexHis=temp.SpeedHistoryData(ismember(temp.SpeedHistoryData(:,1),nodeAreaStackIndex{:,:}),:);
            
            traceOfCarNum_Weekday1(i).CarNumRecord(j,1:3)=[sum(index1(:,5)), dot(index1(:,3),index1(:,5))/sum(index1(:,5)), (dot(index1(:,3).^2+index1(:,4),index1(:,5))/sum(index1(:,5)))-(dot(index1(:,3),index1(:,5))/sum(index1(:,5))).^2];
            traceOfCarNum_Weekday2(i).CarNumRecord(j,1:3)=[sum(index2(:,5)), dot(index2(:,3),index2(:,5))/sum(index2(:,5)), (dot(index2(:,3).^2+index2(:,4),index2(:,5))/sum(index2(:,5)))-(dot(index2(:,3),index2(:,5))/sum(index2(:,5))).^2];
            traceOfCarNum_WeekdayHis(i).CarNumRecord(j,1:3)=[sum(indexHis(:,5)), dot(indexHis(:,3),indexHis(:,5))/sum(indexHis(:,5)), (dot(indexHis(:,3).^2+indexHis(:,4),indexHis(:,5))/sum(indexHis(:,5)))-(dot(indexHis(:,3),indexHis(:,5))/sum(indexHis(:,5))).^2];
           
            %Holiday
            temp = currentStatus2(j+144);
  
            index1=temp.SpeedDataDay1(ismember(temp.SpeedDataDay1(:,1),nodeAreaStackIndex{:,:}),:);
            index2=temp.SpeedDataDay2(ismember(temp.SpeedDataDay2(:,1),nodeAreaStackIndex{:,:}),:);
            indexHis=temp.SpeedHistoryData(ismember(temp.SpeedHistoryData(:,1),nodeAreaStackIndex{:,:}),:);
            
            traceOfCarNum_Holiday1(i).CarNumRecord(j,1:3)=[sum(index1(:,5)), dot(index1(:,3),index1(:,5))/sum(index1(:,5)), (dot(index1(:,3).^2+index1(:,4),index1(:,5))/sum(index1(:,5)))-(dot(index1(:,3),index1(:,5))/sum(index1(:,5))).^2];
            traceOfCarNum_Holiday2(i).CarNumRecord(j,1:3)=[sum(index2(:,5)), dot(index2(:,3),index2(:,5))/sum(index2(:,5)), (dot(index2(:,3).^2+index2(:,4),index2(:,5))/sum(index2(:,5)))-(dot(index2(:,3),index2(:,5))/sum(index2(:,5))).^2];
            traceOfCarNum_HolidayHis(i).CarNumRecord(j,1:3)=[sum(indexHis(:,5)), dot(indexHis(:,3),indexHis(:,5))/sum(indexHis(:,5)), (dot(indexHis(:,3).^2+indexHis(:,4),indexHis(:,5))/sum(indexHis(:,5)))-(dot(indexHis(:,3),indexHis(:,5))/sum(indexHis(:,5))).^2];
        end
    end
end
