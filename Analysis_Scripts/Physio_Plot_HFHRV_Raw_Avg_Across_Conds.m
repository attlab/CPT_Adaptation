%{

Author: Tom Bullock
Date: 07.21.20

Notes:
load raw HFHRV data using Physio_Plot_Compare_Within_Session_With_Stats_ANOVA_PLOT.m

%}



plot(squeeze(nanmean(nanmean(all_HF(:,:,1,:),1),2)),'color','b','linewidth',3); hold on
plot(squeeze(nanmean(nanmean(all_HF(:,:,2,:),1),2)),'color','r','linewidth',3);

%theseYlims = [0,1];
theseYlims = [5.5,7.5];

set(gca,...
    'xlim',[0,190],...
    'ylim',theseYlims,...
    'box','off');

xlabel('Time (s)','fontsize',24)
ylabel('ms^2/Hz','fontsize',24)

line([40,40],[5.5,7.5],'linewidth',1.5,'linestyle','--')
line([65,65],[5.5,7.5],'linewidth',1.5,'linestyle','--')
line([155,155],[5.5,7.5],'linewidth',1.5,'linestyle','--')


pbaspect([2,1,1])


legend('CPT','WPT')

title('HFHRV (Bln, Avg. Across Trials)','FontSize',24)
%title('HFHRV (Raw, Avg. Across Trials)','FontSize',24)


%% try correlating HFHRV with PEP

cptAvgTrialsHF = squeeze(nanmean(all_HF(:,:,1,:),2));
wptAvgTrialsHF = squeeze(nanmean(all_HF(:,:,2,:),2));

cptAvgTrialsPEP = squeeze(nanmean(all_PEP(:,:,1,:),2));
wptAvgTrialsPEP = squeeze(nanmean(all_PEP(:,:,2,:),2));

for i=1:190
    
    [RHO,PVAL] = corr(cptAvgTrialsHF(:,i),cptAvgTrialsPEP(:,i));
    allPvals(i) = PVAL;
    
end

plot(allPvals)
