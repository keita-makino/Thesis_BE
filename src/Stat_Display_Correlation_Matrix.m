%-----------------------------------------------------------
% Evaluate the Intensity of Attraction at Every Node
%-----------------------------------------------------------
 
% Initialize
clear;
close all force;
 
% Load Trace Data
traceData = load('traceOfCoef.mat','traceOfCoef');
 
%-----------------------------------------------------------
% Definitions
%-----------------------------------------------------------
% Container Definition
trace = cell(6,6,6,2,2);
 
% Substitution of Raw Data
for i = 1:6
    for j = 1:6
        for k= 1:6
            for l=1:2
                for m=1:2
                    trace{i,j,k,l,m}(:,:) = traceData.traceOfCoef{i,j,k,l,m,1}(:,:);
                end
            end
        end
    end
end
 
% Reference of Distance
distArray = [200,800,1200,1600,2400,4000];
 
%-----------------------------------------------------------
% Strings to Show Legends in a Graph
% Currently Not Used
%-----------------------------------------------------------
% Day
dayArray = cell(6,1);
dayArray{1} = 'Weekday\_1';
dayArray{2} = 'Weekday\_2';
dayArray{3} = 'Weekday\_History';
dayArray{4} = 'Holiday\_1';
dayArray{5} = 'Holiday\_2';
dayArray{6} = 'Holiday\_History';
 
% Cutoff
cutoffNumberArray = [0,1,3,5,10,20];
% Centrality
centArray = ['Off';'On '];
% Turbulence
turbArray = ['Off';'On '];
 
%-----------------------------------------------------------
% Main
%-----------------------------------------------------------
% Linear Filter
cont = ones(1, 6)/6;
 
% Evaluate the Correlation Matrices between the Facility Types, Display
% them and Save Individual Figures
for i = 1:6
    for j = 1:6
        for k= 1:6
            for l=1:1
                for m=1:1
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
                    
                    % Make the Matrix
                    c = filter(cont,1,trace{i,j,k,l,m}(:,:));
                    correlationMatrix = zeros(11,11);
                    correlationMatrix(1:10,1:10) = corrcoef(c); 
 
                    % Plot and Save
                    figure('Visible', 'off');
                    fig = gcf;
                    ax = gca();
 
                    surface(correlationMatrix);
                    
                    colorbar;
 
                    ax.XTick = [1.5:1:10.5];
                    ax.YTick = [1.5:1:10.5];
                    caxis([-1 1])
                    ax.YTickLabel = cellstr(['Sc.';'Of.';'Bk.';'Ml.';'Rs.';'GS ';'SS ';'Ht.';'Tr.';'Et.']);
                    ax.XTickLabel = cellstr(['Sc.';'Of.';'Bk.';'Ml.';'Rs.';'GS ';'SS ';'Ht.';'Tr.';'Et.']);
                    
                    ax.FontSize = 36;
 
                    fig.PaperUnits = 'points';
                    fig.PaperPosition = [0 0 1800 1200];
                    print(['Matrix/CorrMatrix_',num2str(i),'_',num2str(j),'_',num2str(k),'_',num2str(l),'_',num2str(m)],'-dpng','-r120');
                    close all force;
                end
            end
        end
    end
end
