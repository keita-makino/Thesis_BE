%-----------------------------------------------------------
% Data Preprocess (Format, Removal of Unnecessary Data)
%-----------------------------------------------------------

% Initialize
clear;
close all;
mapreducer(0);
 
%% Road Network and Feature
%-----------------------------------------------------------
% Load and Modify the Road Network
%-----------------------------------------------------------
% Load the Definition of the Road Network
roadNet = load('../Road/Roadnetwork.txt','ascii');
roadNet = roadNet + 1;
 
% Create Graph
G = digraph(roadNet(:,2),roadNet(:,3));
 
% Find the Largest Bulk
subIndex = conncomp(G,'type','weak');
subIndex = find(subIndex==5);
 
% Extract the Bulk to a New Stack
j=1;
stack=zeros(200000,3);
for i=1:length(subIndex)
    i
    x = roadNet(roadNet(:,2)==subIndex(i),:);
    stack(j:j+size(x,1)-1,:)=x;
    j=j+size(x,1);
    x = roadNet(roadNet(:,3)==subIndex(i),:);
    stack(j:j+size(x,1)-1,:)=x;
    j=j+size(x,1);
end
 
% Delete the Same Rows in the Stack and the First Row
roadNet = unique(stack,'rows');
roadNet(1,:) = [];
index = unique(roadNet(:,1));
 
%-----------------------------------------------------------
% Load and Modify the Road Feature
%-----------------------------------------------------------
% Load the Definition of the Road Feature
roadFeature = load('../Road/Roadfeature.txt','ascii');
roadFeature(:,1) = roadFeature(:,1) + 1;
 
% Extract the Rows Corresponding to the Stack
roadFeature = roadFeature(index,:);
 
% Exermine if an Edge is Oneway or Not
isOneway = roadFeature(:,5);
 
%-----------------------------------------------------------
% Modify and Save the Road Network by Referring the Feature
%-----------------------------------------------------------
% Create an Annex Stack of the Roundways in the Main Stack
% Double the Indexes to Prevent them from Corriding
roadNet(:,1) = roadNet(:,1).*2;
roadAnnex = roadNet(isOneway==1,:);
temp = roadAnnex(:,2);
roadAnnex(:,2) = roadAnnex(:,3);
roadAnnex(:,3) = temp;
roadAnnex(:,1) = roadAnnex(:,1)+1;
roadNet=[roadNet;roadAnnex];
 
% Make the Correspondence
indexCorrespondence = zeros(length(roadNet),2);
indexCorrespondence(:,2) = roadNet(:,1);
indexCorrespondence = sortrows(indexCorrespondence,2);
indexCorrespondence(:,1) = 1:length(indexCorrespondence);
 
% Sort
roadNet = sortrows(roadNet,1);
 
% Renumber
roadNetstackPartial = roadNet(:,2:3);
count=1;
for i = 1:max(max(roadNet(:,2:3)))
    i
    if(length(roadNetstackPartial(roadNetstackPartial==i)~=0))
        roadNetstackPartial(roadNetstackPartial==i)=count;
        count=count+1;
    end
end
roadNet(:,2:3)=roadNetstackPartial;
 
% Save
file = fopen('roadNet.csv','w');
header = ['RoadID' ',' 'From' ',' 'To'];
fprintf(file, '%s\n', header);
fclose(file);
dlmwrite('roadNet.csv',roadNet,'precision',6,'-append');
 
%-----------------------------------------------------------
% Modify and Save the Road Feature
%-----------------------------------------------------------
% Renumbering
roadFeature(:,1) = roadFeature(:,1).*2;
roadFeatureAnnex = roadFeature(isOneway==1,:);
roadFeatureAnnex(:,1) = roadFeatureAnnex(:,1)+1;
roadFeature = [roadFeature;roadFeatureAnnex];
roadFeature = sortrows(roadFeature,1);
 
% Half the Two-ways' POIs
roadFeature(find(roadFeature(:,5)==1),9:19)=roadFeature(find(roadFeature(:,5)==1),9:19)./2;
 
% Save
file = fopen('roadFeature.csv','w');
header = ['RoadID' ',' 'Length' ',' 'Lanes' ',' 'Limit' ',' 'Direction' ','...
    'Level' ',' 'Tortuosity' ',' 'Connections' ',' 'Schools' ',' 'Offices' ',' 'Banks' ','...
    'Malls' ',' 'Restaurants' ',' 'Gas stations' ',' 'Scenic Spot' ',' 'Hotels' ',' 'Transportations' ',' 'Entertainments' ',' 'Sum of POIs'];
fprintf(file, '%s\n', header);
fclose(file);
dlmwrite('roadFeature.csv',roadFeature,'precision',6, '-append');
 
%% Speed and Volume
%-----------------------------------------------------------
% Load and Modify the Data of the Speed Records
%-----------------------------------------------------------
% Load the Data of Speed Records
speedData0912 = load('../Speed/20130912.txt','ascii');
speedData0913 = load('../Speed/20130913.txt','ascii');
speedData0914 = load('../Speed/20130914.txt','ascii');
speedData0915 = load('../Speed/20130915.txt','ascii');
 
% Load the Historical Data of Speed Records
speedHistoryDataWeekday = load('../Speed History/history.workday.speed','ascii');
speedHistoryDataHoliday = load('../Speed History/history.holiday.speed','ascii');
 
% Renumbering of the Time Periods
speedData0913(:,2) = speedData0913(:,2)+144;
speedData0914(:,2) = speedData0914(:,2)+288;
speedData0915(:,2) = speedData0915(:,2)+432;
speedHistoryDataHoliday(:,2) = speedHistoryDataHoliday(:,2)+144;
 
% Merge the Files into One File
speedData = [speedData0912;speedData0913;speedData0914;speedData0915];
speedHistoryData = [speedHistoryDataWeekday;speedHistoryDataHoliday];
 
% Delete Unnecessary Rows (Correspond to the Road-Network Stack)
speedData = speedData(ismember(speedData(:,1),index),:);
speedHistoryData = speedHistoryData(ismember(speedHistoryData(:,1),index),:);
 
% Square the Standard Deviations to Evaluate Variance
speedData(:,4) = speedData(:,4).^2;
speedHistoryData(:,4) = speedHistoryData(:,4).^2;
 
% Half the Car Numbers and Variances on each Roundway Road
onewayIndex = index(isOneway==1);
speedData(ismember(speedData(:,1),onewayIndex)==1,4:5) = speedData(ismember(speedData(:,1),onewayIndex)==1,4:5)/2;
speedHistoryData(ismember(speedHistoryData(:,1),onewayIndex)==1,4:5) = speedHistoryData(ismember(speedHistoryData(:,1),onewayIndex)==1,4:5)/2;
 
% Create Annex
speedDataAnnex = speedData(ismember(speedData(:,1),onewayIndex)==1,:);
speedHistoryDataAnnex = speedHistoryData(ismember(speedHistoryData(:,1),onewayIndex)==1,:);
 
% Merge Annex to the Main Stack
speedData(:,1)=speedData(:,1)*2;
speedHistoryData(:,1)=speedHistoryData(:,1)*2;
speedDataAnnex(:,1)=speedDataAnnex(:,1)*2+1;
speedHistoryDataAnnex(:,1)=speedHistoryDataAnnex(:,1)*2+1;
 
% Sort
speedData = sortrows([speedData;speedDataAnnex],1);
speedHistoryData = sortrows([speedHistoryData;speedHistoryDataAnnex],1);
 
%-----------------------------------------------------------
% Save the Data
%-----------------------------------------------------------
% Save
file = fopen('speedData.csv','w');
header = ['RoadID' ',' 'TimeID' ',' 'Speed' ',' 'SpeedDev' ',' 'Car Amount'];
fprintf(file, '%s\n', header);
fclose(file);
dlmwrite('speedData.csv',speedData,'precision',6, '-append');
file = fopen('speedHistoryData.csv','w');
header = ['RoadID' ',' 'TimeID' ',' 'Speed' ',' 'SpeedDev' ',' 'Car Amount'];
fprintf(file, '%s\n', header);
fclose(file);
dlmwrite('speedHistoryData.csv',speedHistoryData,'precision',6, '-append');
