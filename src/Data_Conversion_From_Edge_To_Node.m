%-----------------------------------------------------------
% Data Conversion from Edge-Oriented Format to Node-Opriented Format
%-----------------------------------------------------------
 
% Initialize
clear;
mapreducer(gcp);
 
%-----------------------------------------------------------
% Load the Road Network and Its Information of Features
%-----------------------------------------------------------
% Load
roadNet = csvread('roadNet.csv',1,0);
roadFeature = csvread('roadFeature.csv',1,0);
 
% Create Datastores
ds = datastore('speedData.csv');
ds2 = datastore('speedHistoryData.csv');
 
% Create Tall Arrays
T = tall(ds);
T2 = tall(ds2);
 
%-----------------------------------------------------------
% Create an Object to Contain the Data in Time-Series Format
%-----------------------------------------------------------
% Create an Instance of "CurrentStatus" Class with Length of 288 (=144*2)
currentStatus=CurrentStatus(288);
 
% Substitute Data Fragments into the Cell of currentStatus According to
% Their Time Slots
parfor i = 1:144
    currentStatus(i).SpeedDataDay1 = gather(T(T.TimeID==i-1,:));
    currentStatus(i).SpeedDataDay2 = gather(T(T.TimeID==i+143,:));
    currentStatus(i).SpeedHistoryData = gather(T2(T2.TimeID==i-1,:));
end
parfor i = 145:288
    currentStatus(i).SpeedDataDay1 = gather(T(T.TimeID==i+143,:));
    currentStatus(i).SpeedDataDay2 = gather(T(T.TimeID==i+287,:));
    currentStatus(i).SpeedHistoryData = gather(T2(T2.TimeID==i-1,:));
end
 
% Store Unique Index to Extract a Set Later
indexerArrayBase = [(1:length(roadNet(:,1)))',roadNet(:,1:2)];
indexerArray = zeros(max(indexerArrayBase(:,2)),3);
for i=1:length(indexerArrayBase)
    indexerArray(indexerArrayBase(i,2),:)=indexerArrayBase(i,:);
end
 
%-----------------------------------------------------------
% Merge All Rows Which Share the Same Node Index 
%-----------------------------------------------------------
parfor i = 92:288
    i
    tempSpeedData1 = currentStatus(i).SpeedDataDay1{:,:};
    tempSpeedData2 = currentStatus(i).SpeedDataDay2{:,:};
    tempSpeedHistoryData = currentStatus(i).SpeedHistoryData{:,:};
    
    % Day1
    for j=1:length(tempSpeedData1)
        ratio = roadFeature(indexerArray(tempSpeedData1(j,1),1),2) ./ (tempSpeedData1(j,3)*600);
        tempSpeedData1(j,4:5) = tempSpeedData1(j,4:5).*ratio;
        tempSpeedData1(j,1)=indexerArray(tempSpeedData1(j,1),3);
    end
    
    % Day2
    for j=1:length(tempSpeedData2)
        ratio = roadFeature(indexerArray(tempSpeedData2(j,1),1),2) ./ (tempSpeedData2(j,3)*600);
        tempSpeedData2(j,4:5) = tempSpeedData2(j,4:5).*ratio;
        tempSpeedData2(j,1)=indexerArray(tempSpeedData2(j,1),3);
    end
    
    % Historical
    for j=1:length(tempSpeedHistoryData)
        ratio = roadFeature(indexerArray(tempSpeedHistoryData(j,1),1),2) / (tempSpeedHistoryData(j,3)*600);
        tempSpeedHistoryData(j,4:5) = tempSpeedHistoryData(j,4:5).*ratio;
        tempSpeedHistoryData(j,1)=indexerArray(tempSpeedHistoryData(j,1),3);
    end
    currentStatus(i).SpeedDataDay1 = tempSpeedData1;
    currentStatus(i).SpeedDataDay2 = tempSpeedData2;
    currentStatus(i).SpeedHistoryData = tempSpeedHistoryData;
end
 
%-----------------------------------------------------------
% Merge All Rows Which Share the Same Node Index 
%-----------------------------------------------------------
parfor i = 1:576
    % Day1
    tempSpeedData1 = currentStatus(i).SpeedDataDay1{:,:};
    tempSpeedData1 = sortrows(tempSpeedData1);
    index = unique(tempSpeedData1(:,1));
    
    for j=1:length(index)
       if nnz(tempSpeedData1(:,1) == index(j)) >1
          tempStatusStack = zeros(1,5);
          tempStatusStack(1) = index(j);
          tempStatusStack(2) = i-1;
          tempStatusStack(3) = dot(tempSpeedData1(tempSpeedData1(:,1)==index(j),3),tempSpeedData1(tempSpeedData1(:,1)==index(j),5))/sum(tempSpeedData1(tempSpeedData1(:,1)==index(j),5));
          tempStatusStack(4) = dot(tempSpeedData1(tempSpeedData1(:,1)==index(j),4)+(tempSpeedData1(tempSpeedData1(:,1)==index(j),3)).^2,tempSpeedData1(tempSpeedData1(:,1)==index(j),5))/sum(tempSpeedData1(tempSpeedData1(:,1)==index(j),5))-tempStatusStack(3).^2;
          tempStatusStack(5) = sum(tempSpeedData1(tempSpeedData1(:,1)==index(j),5));
          tempSpeedData1(tempSpeedData1(:,1)==index(j),:)=[];
          tempSpeedData1 = [tempSpeedData1;tempStatusStack];
       end
    end
    
    % Day2
    tempSpeedData2 = currentStatus(i).SpeedDataDay2{:,:};
    tempSpeedData2 = sortrows(tempSpeedData2);
    index = unique(tempSpeedData2(:,1));
    
    for j=1:length(index)
       if nnz(tempSpeedData2(:,1) == index(j)) >1
          tempStatusStack = zeros(1,5);
          tempStatusStack(1) = index(j);
          tempStatusStack(2) = i-1;
          tempStatusStack(3) = dot(tempSpeedData2(tempSpeedData2(:,1)==index(j),3),tempSpeedData2(tempSpeedData2(:,1)==index(j),5))/sum(tempSpeedData2(tempSpeedData2(:,1)==index(j),5));
          tempStatusStack(4) = dot(tempSpeedData2(tempSpeedData2(:,1)==index(j),4)+(tempSpeedData2(tempSpeedData2(:,1)==index(j),3)).^2,tempSpeedData2(tempSpeedData2(:,1)==index(j),5))/sum(tempSpeedData2(tempSpeedData2(:,1)==index(j),5))-tempStatusStack(3).^2;
          tempStatusStack(5) = sum(tempSpeedData2(tempSpeedData2(:,1)==index(j),5));
          tempSpeedData2(tempSpeedData2(:,1)==index(j),:)=[];
          tempSpeedData2 = [tempSpeedData2;tempStatusStack];
       end
    end
    
    % Historical
    tempSpeedHistoryData = currentStatus(i).SpeedHistoryData{:,:};
    tempSpeedHistoryData = sortrows(tempSpeedHistoryData);
    index = unique(tempSpeedHistoryData(:,1));
    for j=1:length(index)
       if nnz(tempSpeedHistoryData(:,1) == index(j)) >1
          tempStatusStack = zeros(1,5);
          tempStatusStack(1) = index(j);
          tempStatusStack(2) = i-1;
          tempStatusStack(3) = dot(tempSpeedHistoryData(tempSpeedHistoryData(:,1)==index(j),3),tempSpeedHistoryData(tempSpeedHistoryData(:,1)==index(j),5))/sum(tempSpeedHistoryData(tempSpeedHistoryData(:,1)==index(j),5));
          tempStatusStack(4) = dot(tempSpeedHistoryData(tempSpeedHistoryData(:,1)==index(j),4)+(tempSpeedHistoryData(tempSpeedHistoryData(:,1)==index(j),3)).^2,tempSpeedHistoryData(tempSpeedHistoryData(:,1)==index(j),5))/sum(tempSpeedHistoryData(tempSpeedHistoryData(:,1)==index(j),5))-tempStatusStack(3).^2;
          tempStatusStack(5) = sum(tempSpeedHistoryData(tempSpeedHistoryData(:,1)==index(j),5));
          tempSpeedHistoryData(tempSpeedHistoryData(:,1)==index(j),:)=[];
          tempSpeedHistoryData = [tempSpeedHistoryData;tempStatusStack];
       end
    end
    
    currentStatus(i).SpeedDataDay1 = tempSpeedData1;
    currentStatus(i).SpeedDataDay2 = tempSpeedData2;
    currentStatus(i).SpeedHistoryData = tempSpeedHistoryData;
end
 
%-----------------------------------------------------------
% Divide CarNums and Variances by 34 or 20 to Project the Data into a Day
%-----------------------------------------------------------
parfor i=1:144
    currentStatus(i).SpeedHistoryData(:,4:5) = currentStatus(i).SpeedHistoryData(:,4:5)./34;
end
 
parfor i=145:288
    currentStatus(i).SpeedHistoryData(:,4:5) = currentStatus(i).SpeedHistoryData(:,4:5)./20;
end
 
% Delete Invalid Rows
for i=1:288
   currentStatus(i).SpeedDataDay1(currentStatus(i).SpeedData(:,5)==Inf,:)=[];
   currentStatus(i).SpeedDataDay2(currentStatus(i).SpeedData(:,5)==Inf,:)=[];
   currentStatus(i).SpeedHistoryData(currentStatus(i).SpeedHistoryData(:,5)==Inf,:)=[];
end
 
% Save
save('currentStatus100.mat','currentStatus');
