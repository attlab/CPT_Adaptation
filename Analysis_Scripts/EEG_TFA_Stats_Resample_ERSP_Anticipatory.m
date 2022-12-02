function EEG_TFA_Stats_Resample_ERSP_Anticipatory(analysisType,iFreq)

%{
Time_Freq_Analysis_ERSP_Plot_Topos_WITHIN_ANOVA
Author: Tom Bullock
Date: 05.17.20

JUST BASELINE (i.e. run stats on ancitipatory data only)

%}

% % load eeglab
% eeglabDir = '/home/bullock/Toolboxes/eeglab2019_1'; 
% cd(eeglabDir)
% eeglab

% clear
% close all

% set dirs
parentDir = '/home/bullock/BOSS/CPT_Adaptation';
sourceDir = [parentDir '/' 'Data_Compiled'];

% load compiled ERSP dataset
%analysisType=1; % 1 = 1-100 Hz, 2 = 1-30 Hz

if analysisType==1
    %load([sourceDir '/' 'GRAND_ERSP_1-100Hz.mat' ])
    load([sourceDir '/' 'GRAND_ERSP_1-100Hz_NewBL.mat' ])

    %load([sourceDir '/' 'STATS_EEG_ERSP_1-100Hz_TOPOS.mat'])
else
    %load([sourceDir '/' 'GRAND_ERSP_1-30Hz_ICA_ICLabel_Dipfit_50HzLP.mat'])
    load([sourceDir '/' 'GRAND_ERSP_1-30Hz_ICA_ICLabel_Dipfit_50HzLP_NoBlCorr.mat'])
    %load([sourceDir '/' 'STATS_EEG_ERSP_1-30Hz_ICA_ICLabel_Dipfit_50HzLP.mat'])
end

% % analysis specific settings
% if analysisType==1
%     freqIdx=1:5;
% else
%     freqIdx=1:4;
% end

% % baseline correct
% if analysisType>1
%     erspBL = mean(erspAll(:,:,:,:,:,25:39),6);
% else
%     erspBL = mean(erspAll(:,:,:,:,:,26:40),6);
% end
% ersp = erspAll-erspBL;
ersp=erspAll;

% % loop through freqs
% for iFreq=freqIdx

iFreq

if analysisType==1
    
    if iFreq==1
        theseFreqs = 1:3;
        theseMapLimits = [-4,4];
        thisFreqName = 'Delta';
    elseif iFreq==2
        theseFreqs = 4:7;
        theseMapLimits = [-2,4];
        thisFreqName = 'Theta';
    elseif iFreq==3
        theseFreqs = 8:14;
        theseMapLimits = [-1,3];
        thisFreqName = 'Alpha';
    elseif iFreq==4
        theseFreqs = 15:30;
        theseMapLimits = [-1,5];
        thisFreqName = 'Beta';
    elseif iFreq==5
        theseFreqs=31:100;
        theseMapLimits = [-1,10];
        thisFreqName = '30-100Hz';
    end
    
else
    
    if iFreq==1
        theseFreqs = 1:3;
        theseMapLimits = [-1,4];
        thisFreqName = 'Delta';
    elseif iFreq==2
        theseFreqs = 4:7;
        theseMapLimits = [-1,2];
        thisFreqName = 'Theta';
    elseif iFreq==3
        theseFreqs = 8:14;
        theseMapLimits = [-1,3];
        thisFreqName = 'Alpha';
    elseif iFreq==4
        theseFreqs = 15:30;
        theseMapLimits = [-1,5];
        thisFreqName = 'Beta';
    end
    
end

%% START STATS


%% REAL ANOVA

addpath(genpath('/home/bullock/BOSS/CPT_Adaptation/resampling'))
% name variables
var1_name = 'cond';
var1_levels = 2;
var2_name = 'trial';
var2_levels = 5;

clear condVec trialVec intVec

% set timepoints to average over and include in analysis

for iTimes=1
    
    
    if analysisType==1 && iTimes==1
         theseTimes=1:39;
%     elseif analysisType==1 && iTimes==2
%         theseTimes=96:125;
%     elseif analysisType==1 && iTimes==3
%         theseTimes=126:155;
%     elseif analysisType==1 && iTimes==4
%         theseTimes=156:191;
    elseif analysisType==2 && iTimes==1
        theseTimes=1:39;
%     elseif analysisType==2 && iTimes==2
%         theseTimes=95:124;
%     elseif analysisType==2 && iTimes==3
%         theseTimes=125:154;
%     elseif analysisType==2 && iTimes==4
%         theseTimes=155:191;
    end
    
    
%     
%     if analysisType==1
%         theseTimes = 81:155;
%     else
%         theseTimes = 80:154;
%     end
    
    
    
    
    % loop through all channels
    for iChan=1:63
        
        iChan
        
        % isolate data
        observedData = [squeeze(mean(mean(ersp(:,1,:,iChan,theseFreqs,theseTimes),5),6)),squeeze(mean(mean(ersp(:,2,:,iChan,theseFreqs,theseTimes),5),6))];
        
        % do posthocs
        
        
        % run ANOVA
        statOutput = teg_repeated_measures_ANOVA(observedData,[var1_levels var2_levels],{var1_name, var2_name});
        
        % create vectors of main and int F values
        var1.fValObserved = statOutput(1,1);
        var2.fValObserved = statOutput(2,1);
        varInt.fValObserved = statOutput(3,1);
        
        % do perm ANOVA
        for j=1:1000
            
            for i=1:size(observedData,1)
                thisPerm = randperm(size(observedData,2));
                for k=1:length(thisPerm)
                    nullData(i,k,j) = observedData(i,thisPerm(k));
                    
                end
            end
            
            % run ANOVA on PERM data
            clear statOutput
            statOutput = teg_repeated_measures_ANOVA(nullData(:,:,j),[var1_levels var2_levels],{var1_name, var2_name});
            var1.fValsNull(j,1) = statOutput(1,1);
            var2.fValsNull(j,1) = statOutput(2,1);
            varInt.fValsNull(j,1) = statOutput(3,1);
            
        end
        
        % sort null f-values, get index value and convert to percentile (VAR_1)
        var1.NAME = var1_name;
        var1.LEVELS = var1_levels;
        var1.fValsNull = sort(var1.fValsNull(:,1),1,'descend');
        [c var1.fValueIndex] = min(abs(var1.fValsNull - var1.fValObserved));
        var1.fValueIndex = var1.fValueIndex/1000;
        var1.pValueANOVA = var1.fValueIndex;
        
        % sort null f-values, get index value and convert to percentile (VAR_2)
        var2.NAME = var2_name;
        var2.LEVELS = var2_levels;
        var2.fValsNull = sort(var2.fValsNull(:,1),1,'descend');
        [c var2.fValueIndex] = min(abs(var2.fValsNull - var2.fValObserved));
        var2.fValueIndex = var2.fValueIndex/1000;
        var2.pValueANOVA = var2.fValueIndex;
        
        % sort null f-values, get index value and convert to percentile (VAR INTER)
        VarInt.NAME = 'INTERACTION';
        varInt.LEVELS = [num2str(var1_levels) '-by-' num2str(var2_levels)];
        varInt.fValsNull = sort(varInt.fValsNull(:,1),1,'descend');
        [c varInt.fValueIndex] = min(abs(varInt.fValsNull - varInt.fValObserved));
        varInt.fValueIndex = varInt.fValueIndex/1000;
        varInt.pValueANOVA = varInt.fValueIndex;
        
        
        % add to time struct
        allANOVA(iFreq,iChan,iTimes).var1 = var1;
        allANOVA(iFreq,iChan,iTimes).var2 = var2;
        allANOVA(iFreq,iChan,iTimes).varInt = varInt;
        
        clear nullData
        
        
        
        
        
        
    end
    
end


    %% PAIRWISE STATS?
    
%end
   
%% save results in struct
%allEEG_Stats.ANOVA = allANOVA;

% save data
if analysisType==1
%     save([sourceDir '/' 'STATS_WITHIN_Resampled_ERSP_ANOVA_100Hz_NewBL_TimeGrad.mat'],'allANOVA')
else
    save([sourceDir '/' 'STATS_WITHIN_Resampled_ERSP_ANOVA_30Hz_NewBL_BASE_ONLY_' thisFreqName '.mat'],'allANOVA')
end





    
    
    
    
    
    
    
    
    
    
    
    
    
    
%     
%     
%     
%     
%     % plot ANOVA results onto topos
%     
%     for iPlot=1:3
%         
%         if      iPlot==1; theseData = condVec; plotPos = 31:32;
%         elseif  iPlot==2; theseData = trialVec; plotPos = 33:34;
%         elseif  iPlot==3; theseData = intVec; plotPos = 35:36;
%         end
%         
%         % convert p-vals into a vector of 0's (ns) and 1's (sig)
%         for t=1:length(theseData)
%             
%             if theseData(t)<.05
%                 statVec(t)=1;
%             else
%                 statVec(t)=0;
%             end
%                
%         end
%         
%         subplot(6,6,plotPos);
%         
%         topoplot(statVec,chanlocs,...---
%             'maplimits',[0,1])
%         
%         clear statVec theseData
%         
%     end
%     
%     if analysisType==1
%         saveas(h,[destDir '/' 'EEG_ERSP_1-100Hz_No_ICA_Topos_' thisFreqName '.eps'],'epsc')
%     else
%         saveas(h,[destDir '/' 'EEG_ERSP_1-30Hz_Topos_Brain70_Dip15' thisFreqName '.eps'],'epsc')
%     end
%     
%     
%     
%     
%     
% end
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% %{
% EYE_Stats_Resample
% Author: Tom Bullock, UCSB Attention Lab
% Date: 12.21.19
% 
% %}
% 
% function EYE_Stats_Resample_Within_ANOVA(baselineCorrect)
% 
% %clear
% %close all
% 
% %% set dirs
% sourceDir = '/home/bullock/BOSS/CPT_Adaptation/Data_Compiled';
% 
% %% load compiled EYE Data (paMatAll = sub,session,task,eye,timepoint)
% load([sourceDir '/' '/CPT_EYE_Master.mat'])
% 
% % remove bad subjects
% %badSubs = [103,105,108,109,115,116,117,118,128,136,138,140,146,147,148,154,157,158];
% badSubs = [103,105,108,109,115,116,117,118,126,128,135,136,138,139,140,146,147,148,154,157,158,159];
% 
% [a,b] = setdiff(subjects,badSubs);
% paMatAll = paMatAll(b,:,:,:,:);
%  
% %% baseline correction [Note that Event times are 1,20000,32500,77500,97500]
% %baselineCorrect=1;
% theseXlims=[0,195];
% theseXticks=[0,40,65,155,195];
% 
% if baselineCorrect==1
%     paMatBL= nanmean(paMatAll(:,:,:,:,round(26000/2):round(40000/2)),5);
%     paMatAll = paMatAll - paMatBL;
% end
% 
% %% downsample to 1Hz [average across each second (500Hz original SR)]
% for i=1:195
%     paMattAll_DS(:,:,:,:,i) = nanmean(paMatAll(:,:,:,:,((i*500)+1:(i+1)*500)-500),5);
% end
% paMatAll = paMattAll_DS;
% 
% %% normalize between -1 and 1
% maxPA = squeeze(max(max(max(max(nanmean(paMatAll,1))))));
% minPA = squeeze(min(min(min(min(nanmean(paMatAll,1))))));
% paMatAll = (paMatAll-minPA)/(maxPA-minPA);
% 
% 
% %% DO REAL ANOVA
% 
% % add resample toolbox path
% addpath(genpath('/home/bullock/BOSS/CPT_Adaptation/resampling'))
% 
% % name variables
% var1_name = 'cond';
% var1_levels = 2;
% var2_name = 'trial';
% var2_levels = 5;
% 
% % do real ANOVA
% for t=1:size(paMatAll,5)
%     t
%     
%     % create observed data matrix
%     clear observedData    
%     observedData = [squeeze(nanmean(paMatAll(:,1,:,:,t),4)),squeeze(nanmean(paMatAll(:,2,:,:,t),4))];
%     
%     % run ANOVA on REAL data
%     clear statOutput
%     statOutput = teg_repeated_measures_ANOVA(observedData,[var1_levels var2_levels],{var1_name, var2_name});
%     
%     % create vectors of main and int F values
%     var1.fValObserved = statOutput(1,1);
%     var2.fValObserved = statOutput(2,1);
%     varInt.fValObserved = statOutput(3,1);
%     
%     
%     % do perm ANOVA
%     for j=1:1000
%         
%         for i=1:size(observedData,1)        
%             thisPerm = randperm(size(observedData,2));
%             for k=1:length(thisPerm) 
%                 nullData(i,k,j) = observedData(i,thisPerm(k));
%                 
%             end   
%         end
%         
%         % run ANOVA on PERM data
%         clear statOutput
%         statOutput = teg_repeated_measures_ANOVA(nullData(:,:,j),[var1_levels var2_levels],{var1_name, var2_name});
%         var1.fValsNull(j,1) = statOutput(1,1);
%         var2.fValsNull(j,1) = statOutput(2,1);
%         varInt.fValsNull(j,1) = statOutput(3,1);
% 
%     end
%     
%     
%     % sort null f-values, get index value and convert to percentile (VAR_1)
%     var1.NAME = var1_name;
%     var1.LEVELS = var1_levels;
%     var1.fValsNull = sort(var1.fValsNull(:,1),1,'descend');
%     [c var1.fValueIndex] = min(abs(var1.fValsNull - var1.fValObserved));
%     var1.fValueIndex = var1.fValueIndex/1000;
%     var1.pValueANOVA = var1.fValueIndex;
%     
%     % sort null f-values, get index value and convert to percentile (VAR_2)
%     var2.NAME = var2_name;
%     var2.LEVELS = var2_levels;
%     var2.fValsNull = sort(var2.fValsNull(:,1),1,'descend');
%     [c var2.fValueIndex] = min(abs(var2.fValsNull - var2.fValObserved));
%     var2.fValueIndex = var2.fValueIndex/1000;
%     var2.pValueANOVA = var2.fValueIndex;
%     
%     % sort null f-values, get index value and convert to percentile (VAR INTER)
%     VarInt.NAME = 'INTERACTION';
%     varInt.LEVELS = [num2str(var1_levels) '-by-' num2str(var2_levels)];
%     varInt.fValsNull = sort(varInt.fValsNull(:,1),1,'descend');
%     [c varInt.fValueIndex] = min(abs(varInt.fValsNull - varInt.fValObserved));
%     varInt.fValueIndex = varInt.fValueIndex/1000;
%     varInt.pValueANOVA = varInt.fValueIndex;
%     
%     
%     % add to time struct
%     allANOVA(t).var1 = var1;
%     allANOVA(t).var2 = var2;
%     allANOVA(t).varInt = varInt;
%     
%     clear nullData
%     
% end
% 
% 
% 
% %% RUN PAIRWISE T-TESTS (T1vsT5, T1vsT3,T3vsT5)
% 
% for t=1:size(paMatAll,5)
%     
%     t
%         
%     % create observed data matrix
%     clear observedData    
%     observedData = [squeeze(nanmean(paMatAll(:,1,:,:,t),4)),squeeze(nanmean(paMatAll(:,2,:,:,t),4))];
%     
%     % do real pairwise tests for each session separately
%     [~,~,~,STATS] = ttest(observedData(:,1),observedData(:,5)); % tx T1vsT5
%     tValsObs(1,1) = STATS.tstat;
%     
%     [~,~,~,STATS] = ttest(observedData(:,1),observedData(:,3)); % tx T1vsT3
%     tValsObs(1,2) = STATS.tstat;
%     
%     [~,~,~,STATS] = ttest(observedData(:,3),observedData(:,5)); % tx T3vsT5
%     tValsObs(1,3) = STATS.tstat;
%     
%     [~,~,~,STATS] = ttest(observedData(:,6),observedData(:,10)); % tx T1vsT5
%     tValsObs(2,1) = STATS.tstat;
%     
%     [~,~,~,STATS] = ttest(observedData(:,6),observedData(:,8)); % tx T1vsT3
%     tValsObs(2,2) = STATS.tstat;
%     
%     [~,~,~,STATS] = ttest(observedData(:,8),observedData(:,10)); % tx T3vsT5
%     tValsObs(2,3) = STATS.tstat; 
%    
%     
%     % create null data matrices
%     for i=1:1000
%         
%         for m=1:length(observedData)
%             thisPerm = randperm(size(observedData,2));
%             nullDataMat(m,:) = observedData(m,thisPerm);
%         end
%         
%         % do real pairwise tests for each session separately
%         [~,~,~,STATS] = ttest(nullDataMat(:,1),nullDataMat(:,5)); % tx T1vsT5
%         tValsNull(1,1,i) = STATS.tstat;
%         
%         [~,~,~,STATS] = ttest(nullDataMat(:,1),nullDataMat(:,3)); % tx T1vsT3
%         tValsNull(1,2,i) = STATS.tstat;
%         
%         [~,~,~,STATS] = ttest(nullDataMat(:,3),nullDataMat(:,5)); % tx T3vsT5
%         tValsNull(1,3,i) = STATS.tstat;
%         
%         [~,~,~,STATS] = ttest(nullDataMat(:,6),nullDataMat(:,10)); % tx T1vsT5
%         tValsNull(2,1,i) = STATS.tstat;
%         
%         [~,~,~,STATS] = ttest(nullDataMat(:,6),nullDataMat(:,8)); % tx T1vsT3
%         tValsNull(2,2,i) = STATS.tstat;
%         
%         [~,~,~,STATS] = ttest(nullDataMat(:,8),nullDataMat(:,10)); % tx T3vsT5
%         tValsNull(2,3,i) = STATS.tstat;
%         
%     end
%     
%     clear nullDataMat
%     
%     % get t-value indices for permuted stats
%     for iCond=1:2
%         for iTest=1:3
%     
%             % get observed and null t-values
%             theseNullValues  = sort(squeeze(tValsNull(iCond,iTest,:)),1,'descend');
%             thisObsValue = tValsObs(iCond,iTest);
%             
%             % compare obs to null dist
%             [~,tStatIdx] = min(abs(theseNullValues - thisObsValue)); 
%             
%             % sig or not?
%             if tStatIdx<25 || tStatIdx>975
%                 sigVec(iCond,iTest,t) = 1;
%             else
%                 sigVec(iCond,iTest,t) = 0;
%             end
%             
%         end
%     end
%     
% end
% 
% %% save results in struct
% allPupilStats.sigVec = sigVec;
% allPupilStats.ANOVA = allANOVA;
% 
% % save data
% if baselineCorrect==0
%     save([sourceDir '/' 'STATS_WITHIN_Resampled_EYE_n21_raw.mat'],'allPupilStats','subjects','badSubs')
% else
%     save([sourceDir '/' 'STATS_WITHIN_Resampled_EYE_n21_bln.mat'],'allPupilStats','subjects','badSubs')
% end
% 
% 
% return
% 
% 
% 
% 






% %% create a null distribution of t-tests for every session/timepoint 
% 
% % iteration loop (null data)
% for i=1:1000
%     
%     disp(['Null Iteration ' num2str(i)])
%     
%     % sample (timepoint) loop
%     for j=1:size(paMatAll,5)
%         
%         % trial (CPT/WPT exposure) loop
%         for k=1:size(paMatAll,3)
%             
%             observedData = squeeze(mean(paMatAll(:,:,k,:,j),4)); % subs x conds (average across R/L eyes)
%             
%             for m=1:length(observedData)              
%                 thisPerm = randperm(size(observedData,2));              
%                 nullDataMat(m,:) = observedData(m,thisPerm);       
%             end
%             
%             [H,P,CI,STATS] = ttest(nullDataMat(:,1),nullDataMat(:,2));
%             tValsNull(i,j,k) = STATS.tstat;
%             clear STATS nullDataMat observedData
%             
%         end
%     end
% end
% 
% %% generate matrix of real t-test results
% 
% % sample (timepoint) loop
% for j=1:size(paMatAll,5)
%     % trial (CPT/WPT loop) 
%     for k=1:size(paMatAll,3)
%         
%         observedData = squeeze(mean(paMatAll(:,:,k,:,j),4)); % subs x conds (average across R/L eyes)
%         [H,P,CI,STATS] = ttest(observedData(:,1),observedData(:,2));
%         tValsObs(j,k) = STATS.tstat;
%         clear STATS observedData 
%  
%     end
% end
% 
%     
% %% compare observed t-test at each trial and timepoint with corresponding null distribution of t-values
% 
% % sample (timepoint) loop
% for j=1:size(tValsNull,2)
%     
%     % trial (exposure) loop
%     for k=1:size(tValsNull,3)
% 
%         thisNullDist = sort(tValsNull(:,j,k),1,'descend');
%         [~,idx] = min(abs(thisNullDist - tValsObs(j,k)));
%         tStatIdx(j,k) = idx;
%         clear thisNullDist  idx
%         
%     end
% end
% 
% % convert idx value to probability
% %pValuesPairwise = tStatIdx./1000;
% 
% % convert idx value to a vector of 0's and 1's (representing significance
% % at p<.05)
% clear sigVec
% for j=1:size(tStatIdx,1)
%     for k=1:size(tStatIdx,2)
%         if tStatIdx(j,k)<25 || tStatIdx(j,k)>975
%             sigVec(j,k) = 1;
%         else
%             sigVec(j,k)=0;
%         end
%     end
% end
% 
% % save data
% if baselineCorrect==0
%     save([sourceDir '/' 'STATS_Resampled_EYE_n21_raw.mat'],'sigVec','tValsObs','tValsNull','subjects','badSubs')
% else
%     save([sourceDir '/' 'STATS_Resampled_EYE_n21_bln.mat'],'sigVec','tValsObs','tValsNull','subjects','badSubs')
% end
% 
% 
% 
% 
% 




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