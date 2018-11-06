%-----------------------------------------------------------
% Comparison between Oneday Data
%-----------------------------------------------------------
 
% Initialize
clear;
close all force;
%-----------------------------------------------------------
% Definitions
%-----------------------------------------------------------
% Load Trace Data
temp = load('traceOfCoef.mat','traceOfCoef');
trace = temp.traceOfCoef(:,:,:,:,:,1);
 
% Correlations Container
corr = zeros(10,2,7,7);
 
%-----------------------------------------------------------
% Main
%-----------------------------------------------------------
% Linear Filter
cont = ones(1, 6)/6;
 
% Compare the Trace of Coefficients with Different Conditions
for f = 1:10
    for i = 1:2
        for j = 1:6
            for k = 1:6
                day1Trace = filter(cont,1,trace{j,i*3-2,k,1,1}(:,f));
                day2Trace = filter(cont,1,trace{j,i*3-1,k,1,1}(:,f));
                temp = corrcoef(day1Trace,day2Trace);
                corr(f,i,j,k) = temp(1,2);
            end
        end
        
        % Plot and Save
        figure('Visible', 'off');
        fig = gcf;
        ax = gca();
 
        p = surface(corr(f,i,:,:));
 
        ax.XTick = [1.5:1:6.5];
        ax.YTick = [1.5:1:6.5];
        
        caxis([-1 1]);
        colorbar;
        
        ax.XTickLabel = cellstr(['0 ';'1 ';'3 ';'5 ';'10';'20']);
        ax.YTickLabel = cellstr(['200 ';'800 ';'1200';'1600';'2400';'4000']);
        
        t = xlabel('c');
        y = ylabel('r');
 
        ax.FontSize = 36;
        ax.LineWidth = 3;
 
        t.FontSize =44;
        y.FontSize =44;
 
        fig.PaperUnits = 'points';
        fig.PaperPosition = [0 0 1800 1200];
        print(['images/CorrOneDays_',num2str(i),'_',num2str(f)],'-dpng','-r120');
        close all force;
        
    end
end
 
% Plot and Save the Distribution of Corrlations between the Traces in
% Different Day Type (Weekday or Holiday)
figure('Visible', 'off');
fig = gcf;
ax = gca();
 
corrW = reshape(corr(:,1,:,:),7*7*10,1);
corrW(corrW==0)=[];
corrH = reshape(corr(:,2,:,:),7*7*10,1);
corrH(corrH==0)=[];
 
p1 = histogram(corrW);
p1.BinWidth = 0.1;
 
hold on
 
p2 = histogram(corrH);
p2.BinWidth = 0.1;
legend('Weekday','Holiday');
t = xlabel('Correlation Indexes');
y = ylabel('Frequency');
 
ax.FontSize = 36;
ax.LineWidth = 3;
 
t.FontSize =36;
 
fig.PaperUnits = 'points';
fig.PaperPosition = [0 0 1800 1200];
print('images/CorrOneDaysFreq','-dpng','-r120');
close all force;
