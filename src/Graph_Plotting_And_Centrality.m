%-----------------------------------------------------------
% Plot the Graph and Evaluate the Centrality of the Nodes
%-----------------------------------------------------------
 
% Initialize
clear;
mapreducer(0);
 
%-----------------------------------------------------------
% Create Network Map
%-----------------------------------------------------------
% Load the Road Network Definition
roadNet = csvread('roadNet.csv',1,0);
roadFeature = csvread('roadFeature.csv',1,0);
 
% Plotting
G = digraph(roadNet(:,2),roadNet(:,3),roadFeature(:,2));
P = plot(G);
 
% Evaluate Centrality of Each Nodes
centIn = centrality(G,'incloseness','Cost',G.Edges.Weight);
centOut = centrality(G,'outcloseness','Cost',G.Edges.Weight);
 
% Save
save graph.mat
