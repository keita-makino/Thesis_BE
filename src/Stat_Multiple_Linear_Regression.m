%-----------------------------------------------------------
% Make Traces of Traffic Conditions
%-----------------------------------------------------------
 
% Initialize
clear;
mapreducer(0);
 
%% Multiple Linear Regression
%-----------------------------------------------------------
% Definitions
%-----------------------------------------------------------
% Load Data (POIs and Traffic Conditions)
load('poisAtNodesStack.mat');
load('graph.mat','centIn','centOut');
 
% Reference of Cutoff and Distance
cutoffNumberArray = [0,1,3,5,10,20];
distArray = [200,800,1200,1600,2400,4000];
 
% Define an Object that Contains the Index where a Few POIs Locate
fewPOIsIndex=cell(length(cutoffNumberArray),1);
 
% Define an Object that Contains the Trace of Coefficients
traceOfCoef = cell(6,6,6,2,2,4);
 
% Evaluate the Index of Small POIs Size
for l=1:length(cutoffNumberArray)
    fewPOIsIndex{l} =  find(poisAtNodesStack(:,12)>cutoffNumberArray(l));
end
 
% Substitute Empty Cells for a Part of traceOfCoef
% Distance = i
% Day = j
% CutOff = k
% Centrality = l
% Turbulence = m
for i=1:6
    for j=1:6
        for k=1:6
            for l=1:2
                for m=1:2
                    for n=2:4
                        traceOfCoef{i,j,k,l,m,n} = cell(1,144);
                    end
                end
            end
        end
    end
end
 
%-----------------------------------------------------------
% Main
%-----------------------------------------------------------
% Evaluate the traceOfCoef
for i = 1:length(distArray)
    
    % Load the Trace of Traffic Information with Specified Condition
    load(['traceStack_',num2str(distArray(i)),'.mat']);
    
    for j = 1:6
        traceOfCoef{i,j,l,1,1,3} = cell(144,1);
        traceOfCoef{i,j,l,1,2,3} = cell(144,1);
        traceOfCoef{i,j,l,2,1,3} = cell(144,1);
        traceOfCoef{i,j,l,2,2,3} = cell(144,1);
        
        % Evaluate Coefficient Indexes in Accordance with Time
        for k = 2:143
            disp([i,j,k])
            stack = cell2mat(arrayfun(@(x) TrafficConditionExtractor(x,k),traceStack(j).dTrace(:),'UniformOutput',false));
            for l=1:length(cutoffNumberArray)
                temp = stack(fewPOIsIndex{l},:);
                temp(isnan(temp(:,5))==1,:) = [];
                ratioInMeanAndVar = real(temp(:,4)./sqrt(temp(:,5)));
                ratioInMeanAndVar(ratioInMeanAndVar(:)==Inf | ratioInMeanAndVar(:)==-Inf)=0;
                cIn = double(temp(:,3)>=0).*centIn(unique(temp(:,1)),1);
                cOut = -double(temp(:,3)<0).*centOut(unique(temp(:,1)),1);
                c=1./(cIn+cOut);
                cIndex = c~=Inf;
                c=c(cIndex);
                
                pois = poisAtNodesStack(unique(temp(:,1)),2:11);
                
                [traceOfCoef{i,j,l,1,1,1}(k,:),traceOfCoef{i,j,l,1,1,2}{k},traceOfCoef{i,j,l,1,1,3}{k},traceOfCoef{i,j,l,1,1,4}{k}] = regress(temp(:,3),[pois,ones(length(temp),1)]);
                [traceOfCoef{i,j,l,1,2,1}(k,:),traceOfCoef{i,j,l,1,2,2}{k},traceOfCoef{i,j,l,1,2,3}{k},traceOfCoef{i,j,l,1,2,4}{k}] = regress(temp(:,3),[pois,ratioInMeanAndVar,ones(length(temp),1)]);
                [traceOfCoef{i,j,l,2,1,1}(k,:),traceOfCoef{i,j,l,2,1,2}{k},traceOfCoef{i,j,l,2,1,3}{k},traceOfCoef{i,j,l,2,1,4}{k}] = regress(temp(cIndex,3),[pois(cIndex,:),c,ones(length(c),1)]);
                [traceOfCoef{i,j,l,2,2,1}(k,:),traceOfCoef{i,j,l,2,2,2}{k},traceOfCoef{i,j,l,2,2,3}{k},traceOfCoef{i,j,l,2,2,4}{k}] = regress(temp(cIndex,3),[pois(cIndex,:),ratioInMeanAndVar(cIndex),c,ones(length(c),1)]);
            end
        end
    end
    % Clear Temp Data
    clear traceStack;
end
 
% Save
save('traceOfCoef.mat','traceOfCoef','-v7.3')
