%-----------------------------------------------------------
% Plot Time-Series Record of Correlation Indexes
%-----------------------------------------------------------
% clear;
close all force;
 
%-----------------------------------------------------------
% Definitions
%-----------------------------------------------------------
% Load Trace Data
trace = load('traceOfCoef.mat','traceOfCoef');
 
 
%-----------------------------------------------------------
% Strings to Show Legends in a Graph
% Currently Not Used
%-----------------------------------------------------------
% Reference of Distance
distArray = [200,800,1200,1600,2400,4000];
 
% Day
dayArray = cell(6,1);
dayArray{1} = 'Weekday\_1';
dayArray{2} = 'Weekday\_2';
dayArray{3} = 'Weekday\_History';
dayArray{4} = 'Holiday\_1';
dayArray{5} = 'Holiday\_2';
dayArray{6} = 'Holiday\_History';
 
% Feature
featureArray = cell(10,1);
featureArray{1} = 'Schools';
featureArray{2} = 'Offices';
featureArray{3} = 'Banks';
featureArray{4} = 'Shoppings';
featureArray{5} = 'Restaurants';
featureArray{6} = 'Gas Stations';
featureArray{7} = 'Scenic Spot';
featureArray{8} = 'Hotels';
featureArray{9} = 'Transportations';
featureArray{10} = 'Entertainments';
 
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
 
% Plot and Save
for f = 1:10
    for j = 1:6
        for i = 1:6
            figure('Visible', 'off');
            fig = gcf;
            ax = gca();
            
            temp = [];
            for k= 1:6
                temp = [temp,filter(cont,1,trace.traceOfCoef{i,j,k,1,1,1}(:,f))];
            end
            
            p = plot(temp,'LineWidth',4);
            
            xlim([1 145])
            ax.XTick = [1:18:145];
            ax.XTickLabel = cellstr(['00:00';'     ';'06:00';'     ';'12:00';'     ';'18:00';'     ';'24:00']);
            legend('integrated','hourly average','Location','Northoutside','Orientation','horizontal');
            xl = 'Time of the Day';
            
 
            t = xlabel(xl);
            y = ylabel('Coefficient Index');
 
            ax.FontSize = 72;
            ax.LineWidth = 3;
            
            t.FontSize =72;
            
            fig.PaperUnits = 'points';
            fig.PaperPosition = [0 0 1800 1400];
            print(['images/CoefTrace_',num2str(i),'_',num2str(j),'_',num2str(1),'_',num2str(1),'_',num2str(f)],'-dpng','-r120');
 
            close all force;
 
        end
    end
end
