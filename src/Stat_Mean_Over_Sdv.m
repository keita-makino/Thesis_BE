%-----------------------------------------------------------
% Evaluate and Plot the Distribution of Mean Speed over Sdv of the Speeds
%-----------------------------------------------------------
 
% Initialize
clear;
close all force;
 
%-----------------------------------------------------------
% Definitions
%-----------------------------------------------------------
% Load Trace Data
% Choose the Data to be Used by Comment Out
load('traceStack_200.mat');
load('traceStack_800.mat');
load('traceStack_1200.mat');
load('traceStack_1600.mat');
load('traceStack_2400.mat');
load('traceStack_4000.mat');
 
% Container
meanOverSdvContainer = cell(59000,2);
meanOfMeanContainer = zeros(144,2);
meanOverSdvOneTime = zeros(59000,1);
 
%-----------------------------------------------------------
% Main
%-----------------------------------------------------------
% Extract Mean and Variance from Trace
for i=1:59000
    if not(isempty(traceStack(3).trace(i).CarNumRecord))
        temp = traceStack(3).trace(i).CarNumRecord(:,:);
        meanOverSdvContainer{i,1} = temp(:,4);
        meanOverSdvContainer{i,2} = temp(:,4)./sqrt(temp(:,5));
    end
end
 
% Take Mean of the Mean and Mean over Sdv
for i=1:144
    i
    temp1 = 0;
    temp2 = 0;
    count = 0;
    for j=1:59000
        if not(isempty(meanOverSdvContainer{j,1}))
            if not(isnan(meanOverSdvContainer{j,1}(i)))
                temp1 = temp1 + meanOverSdvContainer{j,1}(i);
                temp2 = temp2 + meanOverSdvContainer{j,2}(i);
                count = count + 1;
            end
        end
    end
    meanOfMeanContainer(i,1) =  temp1/count;
    meanOfMeanContainer(i,2) =  temp2/count;
end
 
% Snap the Condition at t = 73 (Time = 12:00)
for i=1:59000
    if not(isempty(meanOverSdvContainer{i,1}))
        if not(isnan(meanOverSdvContainer{i,1}(73)))
            meanOverSdvOneTime(i) = meanOverSdvContainer{i,1}(73);
        end
    end
end
% Remove Invalid Rows
meanOverSdvOneTime(meanOverSdvOneTime==0)=NaN;
 
 
%-----------------------------------------------------------
% Plot and Save
%-----------------------------------------------------------
% Time-Series Function of Mean over Sdv
figure('Visible', 'off');
fig = gcf;
ax = gca();
 
p = plot(meanOfMeanContainer(:,2),'LineWidth',2);
 
xlim([1 145])
ylim([0 24])
ax.XTick = [1:36:145];
ax.XTickLabel = cellstr(['00:00';'06:00';'12:00';'18:00';'24:00']);
 
t = xlabel('Time of the Day');
y = ylabel('Mean Over Standard Deviation');
 
ax.FontSize = 36;
ax.LineWidth = 3;
 
t.FontSize =36;
 
fig.PaperUnits = 'points';
fig.PaperPosition = [0 0 1800 1200];
print('images/MeanOverSdv','-dpng','-r120');
close all force;
 
% Mean over Sdv at t = 73 (Time = 12:00)
figure('Visible', 'off');
fig = gcf;
ax = gca();
 
p = histogram(meanOverSdvOneTime);
 
hold on
 
d = fitdist(meanOverSdvOneTime,'Normal');
p.BinWidth = 1;
x_values = 0:1:30;
y = pdf(d,x_values);
plot(x_values,y.*sum(p.BinCounts)/sum(y),'LineWidth',2)
 
legend('Frequency','Normal Distribution Fitting');
t = xlabel('Mean Over Standard Deviation');
y = ylabel('Frequency');
 
ax.FontSize = 36;
ax.LineWidth = 3;
 
t.FontSize =36;
 
fig.PaperUnits = 'points';
fig.PaperPosition = [0 0 1800 1200];
print('images/MeanOverSdvFreq','-dpng','-r120');
close all force;
