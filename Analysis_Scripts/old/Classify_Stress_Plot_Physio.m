%{
Classify_Stress_Plot_Physio
Author: Tom Bullock
Date: 03.20.20

%}

clear
close all

sourceDir = '/home/bullock/BOSS/CPT_Adaptation/Data_Compiled';

load([sourceDir '/' 'Classification_Results_Leave_Sub_Out.mat'])

for iPlot=1:length(classResults)
    
    figure('units','normalized','outerposition',[0 0 1 1])
    
    
    meanReal = mean(classResults(iPlot).real,1);
    meanPerm = mean(mean(classResults(iPlot).perm,1),3);
    
    semReal = std(classResults(iPlot).real,0,1)/sqrt(size(classResults(iPlot).real,1));
    semPerm = std(mean(classResults(iPlot).perm,3),0,1)/sqrt(size(classResults(iPlot).perm,1));
    
    
    % plot real and perm data
    errorbar(meanReal,semReal,'linestyle','-','Marker','o','linewidth',4); hold on
    errorbar(meanPerm,semPerm,'linestyle','-','Marker','o','linewidth',4);
    
    labels = {'BP','CO','HR','LVET','PEP','SV','TPR','ALL'};
    
    xlabel('Measure Removed as Classifier Feature')
    ylabel('Classifier Accuracy (p)')
    title('CPT vs. WPT classification [1 min exp, 81-140 s]')
    
    set(gca,...
        'xLim',[.5,8.5],...
        'xTickLabels',labels,...
        'ylim',[.45,.6],...
        'fontsize',24,...
        'box','off')
    
    pbaspect([3,1,1])
    
    [h,p,ci,stats] = ttest(classResults(iPlot).real,mean(classResults(iPlot).perm,3))
    
end