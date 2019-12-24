%{
EYE_Plot_Pupil_Area
Author: Tom Bullock, UCSB Attention Lab
Date: 09.17.18, updated 05.25.19

Notes: normalize data

%}

clear
close all

%% set dirs
sourceDir = '/home/bullock/BOSS/CPT_Adaptation/Data_Compiled';

%% load compiled EYE Data (paMatAll = sub,session,task,eye,timepoint)
load([sourceDir '/' '/CPT_EYE_Master.mat'])

%% load resampled stats
load([sourceDir '/' 'STATS_Resampled_EYE_n25.mat'],'sigVec')

% remove bad subjects
badSubs = [103,105,108,109,115,116,117,118,128,136,138,140,146,147,148,154,157,158];
[a,b] = setdiff(subjects,badSubs);
paMatAll = paMatAll(b,:,:,:,:);


        

%% baseline correction [Note that Event times are 1,20000,32500,77500,97500]
baselineCorrect=1;
theseXlims=[0,195];
theseXticks=[0,40,65,95,125,155,195];

if baselineCorrect==1
    paMatBL= nanmean(paMatAll(:,:,:,:,round(25000/2):round(40000/2)),5);
    paMatAll = paMatAll - paMatBL;
end

%% downsample to 1Hz [average across each second (500Hz original SR)]
for i=1:195
    paMattAll_DS(:,:,:,:,i) = nanmean(paMatAll(:,:,:,:,((i*500)+1:(i+1)*500)-500),5);
end
paMatAll = paMattAll_DS;

%% plot settings
theseYlims = [-.2,1];

%% create difference waves
paMatAll_diff = squeeze(paMatAll(:,1,:,:,:) - paMatAll(:,2,:,:,:));

%% norm between 0 and 1
maxPA = squeeze(max(max(max(nanmean(paMatAll_diff,1)))));
minPA = squeeze(min(min(min(nanmean(paMatAll_diff,1)))));
paMatAll_diff = (paMatAll_diff-minPA)/(maxPA-minPA);



%% plot T1-T5 on separate plots
h=figure;
statLineYpos = 0;
for iPlot=1:5
    
    if      iPlot==1; thisColor = [255,0,0];
    elseif  iPlot==2; thisColor = [252,226,5];
    elseif  iPlot==3; thisColor = [255,102,153];
    elseif  iPlot==4; thisColor = [60,179,113];
    elseif  iPlot==5; thisColor = [255,165,0];
    end
    
    
    
    
    plot(1:195,smooth(squeeze(nanmean(nanmean(paMatAll_diff(:,iPlot,1:2,:),1),3)),5),...
        'color',thisColor./255,...
        'LineWidth',4); hold on
    
    
    % add lines
    t1=1; % start pre baseline ( 40 s)
    t2=40; % immersion period (position feet for immersion -25 s)
    t3=65; % start CPT (immerse feet - 90 s)
    t4=155; % recovery (feet out, start recovery baseline - 40 s)
    
   
    for iLine=2:4
        if iLine==1; tx=t1;thisText = 'Baseline';
        elseif iLine==2; tx=t2; thisText = 'Prep';
        elseif iLine==3; tx=t3; thisText = 'CPT';
        elseif iLine==4; tx=t4; thisText = 'Recovery';
        end
        line([tx,tx],[-.3,1],'color','k','linewidth',4,'linestyle',':');
        %text(tx,700,thisText,'fontsize',18)
    end
    
    thisEye=1:2; % average across pupils


    % use regular t-tests (0) or resampled t-tests (1) (imported)
    iOrder=iPlot;
    pairwiseCompType=1;
    if pairwiseCompType==0 % regular t-tests
        [hResults,pResults,~,theseStats] = ttest(nanmean(paMatAll(:,1,iOrder,thisEye,:),4),nanmean(paMatAll(:,2,iOrder,thisEye,:),4));
        hResults = squeeze(hResults);
    else % resampled t-tests (from another script)
        hResults = sigVec(:,iOrder);
        disp('USING RESAMPLED PAIRWISE COMPARISONS!!!!')
    end
    
    % add lines for t-test results
    statLineYpos = statLineYpos-.05;
    
    for s=1:length(hResults)
        if hResults(s)==1
            line([s,s+1],[statLineYpos,statLineYpos],'linewidth',12,'color',thisColor./255);
        end
    end
    
    
    set(gca,...
        'box','off',...
        'linewidth',1.5,...
        'fontsize',24,...
        'ylim',[-.3,1],...
        'yTick',[0,.2,.4,.6,.8,1],...
        'xlim',[0,195],...
        'xtick',theseXticks)
    
    pbaspect([3,1,1]);
    
    
    
end
    
    
    
    
%     ;
%     if plotWithErrorBars==0
%         % plot ICE data
%         plot(1:195,squeeze(nanmean(paMatAll(:,1,iOrder,2,:))),...
%             'color',[51,153,255]./255,...
%             'linewidth',2.5); hold on % plot indices (500 Hz,to divide by 2)
%         
%         % plot WARM data
%         plot(1:195,squeeze(nanmean(paMatAll(:,2,iOrder,2,:))),...
%             'color',[255,51,51]./255,...
%             'linewidth',2.5); hold on % plot indices (500 Hz,to divide by 2)
%     else
%         
%         xAxisLength=195;
%         thisEye=1:2; %1=left,2=right
%         for iPlot=[2,1]
%             if iPlot==1; thisColor=[51,153,255]./255;
%             elseif iPlot==2; thisColor=[255,51,51]./255;
%             end
%             shadedErrorBar(1:195,squeeze(nanmean(nanmean(paMatAll(:,iPlot,iOrder,thisEye,:),4))),...
%                 squeeze(nanstd(nanmean(paMatAll(:,iPlot,iOrder,thisEye,:),4)))./sqrt(size(paMatAll,1)),...
%                 {'color',thisColor,...
%                 'linewidth',2.5}); hold on % plot indices (500 Hz,to divide by 2
%         end
%         
%     end
%     
%     % do t-test to determine if lines are different (CHECK WHAT IS
%     % HAPPENING WITH NAN DATAPOINTS)
%     [hResults,pResults,~,theseStats] = ttest(nanmean(paMatAll(:,1,iOrder,thisEye,:),4),nanmean(paMatAll(:,2,iOrder,thisEye,:),4));
%     hResults = squeeze(hResults);
%     
%     % add line for t-test results to base of plots
%     for s = 1:length(hResults)
%         if hResults(s)==1
%             if baselineCorrect
%                thisYpos=[-250,-250];
%             else
%                 thisYpos=[250,250];
%             end
%             thisYpos = [-.1,-.1];
%              line([s,s+1],thisYpos,'linewidth',4,'color',[9,112,84]./255);
%         end
%     end
%     
%     % add lines
%     t1=1; % start pre baseline ( 40 s)
%     t2=40; % immersion period (position feet for immersion -25 s)
%     t3=65; % start CPT (immerse feet - 90 s)
%     t4=155; % recovery (feet out, start recovery baseline - 40 s)
%     
%     for iLine=1:4
%         if iLine==1; tx=t1;thisText = 'Baseline';
%         elseif iLine==2; tx=t2; thisText = 'Prep';
%         elseif iLine==3; tx=t3; thisText = 'CPT';
%         elseif iLine==4; tx=t4; thisText = 'Recovery';
%         end
%         line([tx,tx],[-300,600],'color','k','linewidth',4,'linestyle',':');
%         text(tx,700,thisText,'fontsize',18)
%     end
%     
%     % add T1, T2 etc labels on left
%     thisTime = ['T' num2str(iOrder)];
%     text(-25,0, thisTime,'fontsize',34)
%     
%     xlabel('Time (s)','fontsize',18)
%     ylabel('P.Area (norm.)')
%     set(gca,...
%         'xlim',theseXlims,...
%         'XTick',theseXticks,...
%         'ylim',theseYlims,...
%         'box','off',...
%         'fontsize',18,...
%         'linewidth',1.5)
%     
%     %legend('ICE','WARM')
%     
% end