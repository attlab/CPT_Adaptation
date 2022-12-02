%{
Self_Report_Plot
Author: Tom Bullock, UCSB Attention Lab
Date: 05.25.19

To do: stats to determine if different (T1 probably > T5)

%}

clear
close all

sourceDir = '/home/bullock/BOSS/CPT_Adaptation/Data_Compiled';

%% choose subjects
[~,mySubjects] = CPT_SUBJECTS;

%% remove sj102
mySubjects(1)=[];

%% load self-report data
load([sourceDir '/' 'Self_Report.mat'])

%% isolate subjects
allPain = allPain(mySubjects-100,:,:)

errorbar(squeeze(nanmean(allPain(:,1,:))),squeeze(nanstd(allPain(:,1,:),0,1))./sqrt(size(allPain,1)),'color',[51,153,255]./255,'linewidth',3); hold on
errorbar(squeeze(nanmean(allPain(:,2,:))),squeeze(nanstd(allPain(:,2,:),0,1))./sqrt(size(allPain,1)),'color',[255,51,51]./255,'linewidth',3); hold on

set(gca,'xlim',[0.5,5.5],'linewidth',1.5,'box','off','fontsize',20,'ylim',[0,100],'ytick',0:20:100, 'XTickLabel',{'T1','T2','T3','T4','T5'})
%ylabel('Pain Rating (0-100)','fontsize',24)
%xlabel('CPT Exposure','fontsize',24)
pbaspect([2,1,1])
%legend('Cold','Warm','location','east','box','off')

% test if Ice vs. Warm are different
ttest(allPain(:,1,:),allPain(:,2,:))

% test if point by point ICE is different (yes!)
for i=1:4
    [h,p,ci,stats]=ttest(allPain(:,1,i),allPain(:,1,i+1)) 
end

% test if first and last are differnet (yes!)
[h,p,ci,stats]=ttest(allPain(:,1,1),allPain(:,1,5))

% save data
save([sourceDir '/' 'SELF_REPORT_FOR_PREDICTIVE_ANALYSIS.mat'],'allPain','mySubjects')