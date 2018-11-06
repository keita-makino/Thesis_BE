%-----------------------------------------------------------
% Residual Validation
%-----------------------------------------------------------

% Initialize
clear;
close all force;
 
%-----------------------------------------------------------
% Definitions
%-----------------------------------------------------------
% Load Trace Data
temp = load('traceOfCoef3.mat','traceOfCoef');
trace = squeeze(temp.traceOfCoef(:,3,:,:,:,3));
clear temp;
 
% Norm
nor = cell(144,6,6,2,2);
% Variance
varr = cell(144,6,6,2,2);
% Residual
res = cell(144,6,6,2,2);
 
%-----------------------------------------------------------
% Main
%-----------------------------------------------------------
% Evaluate Residuals, Their Norm and Their Variance foreach Conditions
for i = 1:6
    for j = 1:6
        for k= 1:2
            for l=1:2
                for m=1:144
                    vec = trace{i,j,k,l}{m};
                    nor{m,i,j,k,l} = norm(vec);
                    varr{m,i,j,k,l} = var(vec);
                    
                    % Remove Outlier Data (Std>3)
                    x = vec./std(vec);
                    x = x(abs(x-mean(x))<std(x).*3);
                    res{m,i,j,k,l}=x;
                end
            end
        end
    end
end
 
for i = 1:6
    for j = 1:6
        for k= 1:2
            for l=1:2
                for m=2:143
                    res{1,i,j,k,l} = [res{1,i,j,k,l};cell2mat(res(m,i,j,k,l))];
                end
                nor{1,i,j,k,l} = mean(cell2mat(nor(2:144,i,j,k,l)),'omitnan');
            end
        end
    end
end
 
 
% Cell Definition for Chi-Squared Test
chiValid=cell(144,6,6,2,2);
 
% Verify If the Distribution of the Residuals Follows a Normal Distribution
for i = 1:6
    for j = 1:6
        for k= 1:2
            for l=1:2
                for m=1:143
                    disp([i j k l m])
                    [h,pp] = chi2gof(res{m,i,j,k,l});
                    chiValid{m,i,j,k,l}=pp;
                end
            end
        end
    end
end
 
% Extract p-Value from the Test Result
chiValid=chiValid(1:143,:,:,:,:);
chiValidMatrix=cell2mat(chiValid);
 
% Find the Largest p in the Matrix
[m,i,j,k,l] = ind2sub([143,6,6,2,2],find(chiValidMatrix==max(max(max(max(max(chiValidMatrix)))))));
 
%-----------------------------------------------------------
% Plot and Save
%-----------------------------------------------------------
% Distribution of Residuals
figure();
fig = gcf;
ax = gca();
 
xbins=-10:0.5:10;
chiValid=histogram(res{73,2,1,1,1});
chiValid.BinEdges = xbins;
 
xlabel('Standardized Residual');
ylabel('Frequency');
 
ax.FontSize = 36;
ax.LineWidth = 3;
 
fig.PaperUnits = 'points';
fig.PaperPosition = [0 0 1800 1200];
print('images/ResFreq','-dpng','-r120');
close all force;
 
% Q-Q Plot
figure();
fig = gcf;
ax = gca();
 
% t = 73 means Time = 12:00
chiValid = qqplot(res{73,2,1,1,1});
 
t = title('');
t.FontSize=0.1;
 
ax.FontSize = 36;
ax.LineWidth = 3;
 
t.FontSize =36;
 
fig.PaperUnits = 'points';
fig.PaperPosition = [0 0 1800 1200];
print('images/ResQQ','-dpng','-r120');
close all force;
 
% Q-Q Plot of a Normal Distribution
figure();
fig = gcf;
ax = gca();
 
chiValid = qqplot(randn(10000,1));
 
t = title('');
t.FontSize=0.1;
 
ax.FontSize = 36;
ax.LineWidth = 3;
 
t.FontSize =36;
 
fig.PaperUnits = 'points';
fig.PaperPosition = [0 0 1800 1200];
print('images/ResQQN','-dpng','-r120');
close all force;
