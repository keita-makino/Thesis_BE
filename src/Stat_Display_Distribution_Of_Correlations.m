%-----------------------------------------------------------
% Plot the Distribution of Correlation Indexes
%-----------------------------------------------------------

% Initialize
clear;
close all;
 
 
%-----------------------------------------------------------
% Definitions
%-----------------------------------------------------------
% Target Feature
feat=2;
% Distance
dist=2;
% Centrality
cent=1;
% Turbulence
turb=1;
 
% Load Trace Data
temp = load('traceOfCoef.mat','traceOfCoef');
trace = temp.traceOfCoef(:,:,:,:,:,1);
 
% Correlations Container
corrCont=cell(2,6);
 
%-----------------------------------------------------------
% Main
%-----------------------------------------------------------
% Linear Filter
cont = ones(1, 6)/6;
 
% Evaluate the Hourly Average of the Traces
for i = 1:6
    for j = 1:6
        for k= 1:6
            for l=1:2
                for m=1:2
                    % Take the Real Part
                    trace{i,j,k,l,m}(:,:) = real(trace{i,j,k,l,m}(:,:));
                    % Remove Invalid and Unnecessary Rows
                    trace{i,j,k,l,m}(1,:) = [];
                    trace{i,j,k,l,m}(:,11:end) = [];
                    
                    % Standardization
                    for n=1:10
                        mn = min(trace{i,j,k,l,m}(:,n));
                        temp = trace{i,j,k,l,m}(:,n) - mn;
                        mx = max(temp);
                        
                        trace{i,j,k,l,m}(:,n) = 2.*temp./mx - 1;
                    end
                end
            end
        end
    end
end
 
% Evaluate the Correlations between the Target Facility Type and the Others
for i=1:2
    for j=1:6
        for k=3*i-2:3*i
            temp  = triu(corrcoef(filter(cont,1,trace{dist,k,j,cent,turb}(:,1:10))),1);
            corrCont{i,j} = [corrCont{i,j}(:);(temp(feat,feat+1:10))'];
        end
    end
end
 
% Plot and Save
for i = 1:2
    corrMatrix=cell2mat(corrCont(i,:));
 
    figure();
    fig = gcf;
    ax = gca();
 
    yyaxis left
 
    
    for j = -2:3
       h = histogram(corrMatrix(:,j+3)+3*j)
       if j == -2
           hold on
       end
       h.BinEdges = ([-1+3*j:0.25:1+3*j])
       h.FaceColor = [(5-(j+2))/5 1 (j+2)/5];
    end
 
    xlim([-8,11])
    ax.XTick = [-7:10];
    ax.XTickLabel = cellstr(['-1';'0 ';'1@';'-1';'0 ';'1@';'-1';'0 ';'1@';'-1';'0 ';'1@';'-1';'0 ';'1@';'-1';'0 ';'1@']);
    xlabel('Correlation');
    ylabel('Frequency');
    legend('c = 0','c = 1','c = 3','c = 5','c = 10','c = 20','Location','NorthOutSide','Orientation','horizontal');
 
    yyaxis right
 
    scatter((-6:3:9)',var(corrMatrix)',200,'filled');
    ylabel('Var');
    ax.YTick = [0:0.05:0.2];
 
    ax.FontSize = 36;
    ax.LineWidth = 3;
 
    fig.PaperUnits = 'points';
    fig.PaperPosition = [0 0 1800 1200];
    print(['hist',num2str(i)],'-dpng','-r120');
    close all;
end
