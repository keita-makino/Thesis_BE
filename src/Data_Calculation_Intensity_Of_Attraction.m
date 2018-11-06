%-----------------------------------------------------------
% Evaluate the Intensity of Attraction at Every Node
%-----------------------------------------------------------
 
% Initialize
clear;
 
% Load the Road Network Definition
roadNet = csvread('roadNet.csv',1,0);
roadFeature = csvread('roadFeature.csv',1,0);
 
% Evaluate the Maximum of the Index
indexMax = length(unique(roadNet(:,2:3)));
 
% Define a Digraph
G = digraph(roadNet(:,2),roadNet(:,3),roadFeature(:,2));
 
% Load the Trace of Traffic Conditions
load('currentStatus.mat');
 
% Reference of Distnace
distArray = [200,800,1200,1600,2400,4000];
 
% Create an Array which Stores tic-toc Record of the Following Function
timeArray=zeros(6,1);
 
% Main
parfor i=1:6
   timeArray(i)= StatusTracer(indexMax,G,distArray(i),currentStatus2);
end
 
return
