%{
EYE_Stats_Resample
Author: Tom Bullock, UCSB Attention Lab
Date: 12.21.19

%}

clear
close all

%% set dirs
sourceDir = '/home/bullock/BOSS/CPT_Adaptation/Data_Compiled';

%% load compiled EYE Data (paMatAll = sub,session,task,eye,timepoint)
load([sourceDir '/' '/CPT_EYE_Master.mat'])

% remove bad subjects
badSubs = [103,105,108,109,115,116,117,118,128,136,138,140,146,147,148,154,157,158];
[a,b] = setdiff(subjects,badSubs);
paMatAll = paMatAll(b,:,:,:,:);
 
%% baseline correction [Note that Event times are 1,20000,32500,77500,97500]
baselineCorrect=1;
theseXlims=[0,195];
theseXticks=[0,40,65,155,195];

if baselineCorrect==1
    paMatBL= nanmean(paMatAll(:,:,:,:,round(25000/2):round(40000/2)),5);
    paMatAll = paMatAll - paMatBL;
end

%% downsample to 1Hz [average across each second (500Hz original SR)]
for i=1:195
    paMattAll_DS(:,:,:,:,i) = nanmean(paMatAll(:,:,:,:,((i*500)+1:(i+1)*500)-500),5);
end
paMatAll = paMattAll_DS;


%% create a null distribution of t-tests for every session/timepoint 

% iteration loop (null data)
for i=1:1000
    
    disp(['Null Iteration ' num2str(i)])
    
    % sample (timepoint) loop
    for j=1:size(paMatAll,5)
        
        % trial (CPT/WPT exposure) loop
        for k=1:size(paMatAll,3)
            
            observedData = squeeze(mean(paMatAll(:,:,k,:,j),4)); % subs x conds (average across R/L eyes)
            
            for m=1:length(observedData)              
                thisPerm = randperm(size(observedData,2));              
                nullDataMat(m,:) = observedData(m,thisPerm);       
            end
            
            [H,P,CI,STATS] = ttest(nullDataMat(:,1),nullDataMat(:,2));
            tValsNull(i,j,k) = STATS.tstat;
            clear STATS nullDataMat observedData
            
        end
    end
end

%% generate matrix of real t-test results

% sample (timepoint) loop
for j=1:size(paMatAll,5)
    % trial (CPT/WPT loop) 
    for k=1:size(paMatAll,3)
        
        observedData = squeeze(mean(paMatAll(:,:,k,:,j),4)); % subs x conds (average across R/L eyes)
        [H,P,CI,STATS] = ttest(observedData(:,1),observedData(:,2));
        tValsObs(j,k) = STATS.tstat;
        clear STATS observedData 
 
    end
end

    
%% compare observed t-test at each trial and timepoint with corresponding null distribution of t-values

% sample (timepoint) loop
for j=1:size(tValsNull,2)
    
    % trial (exposure) loop
    for k=1:size(tValsNull,3)

        thisNullDist = sort(tValsNull(:,j,k),1,'descend');
        [~,idx] = min(abs(thisNullDist - tValsObs(j,k)));
        tStatIdx(j,k) = idx;
        clear thisNullDist  idx
        
    end
end

% convert idx value to probability
%pValuesPairwise = tStatIdx./1000;

% convert idx value to a vector of 0's and 1's (representing significance
% at p<.05)
clear sigVec
for j=1:size(tStatIdx,1)
    for k=1:size(tStatIdx,2)
        if tStatIdx(j,k)<25 || tStatIdx(j,k)>975
            sigVec(j,k) = 1;
        else
            sigVec(j,k)=0;
        end
    end
end

% save data
save([sourceDir '/' 'STATS_Resampled_EYE_n25.mat'],'sigVec','tValsObs','tValsNull','subjects','badSubs')










% 
% % critical t score
% tCriticalNeg = tValsNull(25);
% tCriticalPos = tValsNull(975);
% 
% 
% % 
% %     
% %     for i=1:size(observedData,1)    % for each row of the observed data
% %         
% %         thisPerm = randperm(size(observedData,2)); % shuffle colums for each row
% %         
% %         for k=1:length(thisPerm)
% %             
% %             nullDataMat(i,k,j) = observedData(i,thisPerm(k));
% %             
% % % 
% % %             nullDataMat(i,1,j) = observedData(i,thisPerm(1));
% % %             nullDataMat(i,2,j) = observedData(i,thisPerm(2));
% % %             nullDataMat(i,3,j) = observedData(i,thisPerm(3));
% %         
% %         end
% %         
% %     end
% %     
% %     
% %     
% %     
% % end
% % 
% % 
% % 
% % 
% % 
% % 
% % 
% % %% plot settings
% % theseYlims = [-.2,1];
% % 
% % %% normalize between -1 and 1
% % maxPA = squeeze(max(max(max(max(nanmean(paMatAll,1))))));
% % minPA = squeeze(min(min(min(min(nanmean(paMatAll,1))))));
% % paMatAll = (paMatAll-minPA)/(maxPA-minPA);
% % 
% % %% plot T1-T5 on separate plots
% % h=figure;
% % plotCnt=0;
% % for iOrder=1:5
% %     
% %     plotCnt=plotCnt+1;
% %     subplot(5,1,plotCnt)
% %     
% %     plotWithErrorBars=1;
% %     if plotWithErrorBars==0
% %         % plot ICE data
% %         plot(1:195,squeeze(nanmean(paMatAll(:,1,iOrder,2,:))),...
% %             'color',[51,153,255]./255,...
% %             'linewidth',2.5); hold on % plot indices (500 Hz,to divide by 2)
% %         
% %         % plot WARM data
% %         plot(1:195,squeeze(nanmean(paMatAll(:,2,iOrder,2,:))),...
% %             'color',[255,51,51]./255,...
% %             'linewidth',2.5); hold on % plot indices (500 Hz,to divide by 2)
% %     else
% %         
% %         xAxisLength=195;
% %         thisEye=1:2; %1=left,2=right
% %         for iPlot=[2,1]
% %             if iPlot==1; thisColor=[51,153,255]./255;
% %             elseif iPlot==2; thisColor=[255,51,51]./255;
% %             end
% %             shadedErrorBar(1:195,squeeze(nanmean(nanmean(paMatAll(:,iPlot,iOrder,thisEye,:),4))),...
% %                 squeeze(nanstd(nanmean(paMatAll(:,iPlot,iOrder,thisEye,:),4)))./sqrt(size(paMatAll,1)),...
% %                 {'color',thisColor,...
% %                 'linewidth',2.5}); hold on % plot indices (500 Hz,to divide by 2
% %         end
% %         
% %     end
% %     
% %     % do t-test to determine if lines are different (CHECK WHAT IS
% %     % HAPPENING WITH NAN DATAPOINTS)
% %     [hResults,pResults,~,theseStats] = ttest(nanmean(paMatAll(:,1,iOrder,thisEye,:),4),nanmean(paMatAll(:,2,iOrder,thisEye,:),4));
% %     hResults = squeeze(hResults);
% %     
% %     % add line for t-test results to base of plots
% %     for s = 1:length(hResults)
% %         if hResults(s)==1
% %             if baselineCorrect
% %                thisYpos=[-250,-250];
% %             else
% %                 thisYpos=[250,250];
% %             end
% %             thisYpos = [-.1,-.1];
% %              line([s,s+1],thisYpos,'linewidth',4,'color',[9,112,84]./255);
% %         end
% %     end
% %     
% %     % add lines
% %     t1=1; % start pre baseline ( 40 s)
% %     t2=40; % immersion period (position feet for immersion -25 s)
% %     t3=65; % start CPT (immerse feet - 90 s)
% %     t4=155; % recovery (feet out, start recovery baseline - 40 s)
% %     
% %     for iLine=1:4
% %         if iLine==1; tx=t1;thisText = 'Baseline';
% %         elseif iLine==2; tx=t2; thisText = 'Prep';
% %         elseif iLine==3; tx=t3; thisText = 'CPT';
% %         elseif iLine==4; tx=t4; thisText = 'Recovery';
% %         end
% %         line([tx,tx],[-300,600],'color','k','linewidth',4,'linestyle',':');
% %         text(tx,700,thisText,'fontsize',18)
% %     end
% %     
% %     % add T1, T2 etc labels on left
% %     thisTime = ['T' num2str(iOrder)];
% %     text(-25,0, thisTime,'fontsize',34)
% %     
% %     xlabel('Time (s)','fontsize',18)
% %     ylabel('P.Area (norm.)')
% %     set(gca,...
% %         'xlim',theseXlims,...
% %         'XTick',theseXticks,...
% %         'ylim',theseYlims,...
% %         'box','off',...
% %         'fontsize',18,...
% %         'linewidth',1.5)
% %     
% %     %legend('ICE','WARM')
% %     
% % end