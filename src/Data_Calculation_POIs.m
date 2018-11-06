%-----------------------------------------------------------
% Evaluation of POI Numbers around Nodes
%-----------------------------------------------------------
 
% Initialize
clear;
mapreducer(0);
 
%% Calculation of POIs
% Load the Road Network
roadNet = csvread('roadNet.csv',1,0);
roadFeature = csvread('roadFeature.csv',1,0);
 
% Define a Digraph
G = digraph(roadNet(:,2),roadNet(:,3),roadNet(:,2));
 
% Evaluate the Maximum of the Index
indexMax =length(unique(roadNet(:,2:3)))
 
% Create a Stack to Contain the POIs Information
poisAtNodesStack=[(1:indexMax)',zeros(indexMax,11)];
 
% Substite
for i=1:length(roadFeature)
    i
    poisAtNodesStack(roadNet(roadNet(:,1)==roadFeature(i,1),2:3),2:12) = poisAtNodesStack(roadNet(roadNet(:,1)==roadFeature(i,1),2:3),2:12) + roadFeature(i,9:19)./2;
end
 
%Save
save('poisAtNodesStack.mat','poisAtNodesStack');
