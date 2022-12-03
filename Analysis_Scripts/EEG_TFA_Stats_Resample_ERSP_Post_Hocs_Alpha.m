%{
EEG_TFA_Stats_Resample_ERSP_Post_Hocs_ALpha
Author: Tom Bullock, UCSB Attention Lab
Date: 10.11.20 (updated 12.02.22)

Run post-hocs on alpha only (early, mid, late). I'm pretty sure this is the
correct script for ms...

%}

clear
close all

% %load eeglab
% eeglabDir = '/home/bullock/Toolboxes/eeglab2019_1'; 
% cd(eeglabDir)
% eeglab

% set dirs
parentDir = '/home/bullock/BOSS/CPT_Adaptation';
sourceDir = [parentDir '/' 'Data_Compiled'];
destDir = sourceDir;

% baseline correction in plotting script?
blCorrectInPlotScript=0;

% import permuted stats?
usePermStats=1;
if usePermStats==0
    disp('NOT USING PERM STATS!!! CAUTION!')
end

% load compiled ERSP dataset 
load([sourceDir '/' 'GRAND_ERSP_1-30Hz_ICA_ICLabel_Dipfit_50HzLP_NewBL.mat'])


% baseline correct [irrelevant]
if blCorrectInPlotScript==1
    erspBL = mean(erspAll(:,:,:,:,:,25:39),6);
    ersp = erspAll-erspBL;
else
    ersp = erspAll;
    disp('BL CORRECTION IN PLOTTING SCRIPT DISABLED!!!!')
    pause(1)
end


% loop through freqs [actually only alpha(3) here]
for iFreq=3 
    
    % create fig [redundant?]
    h=figure;
    set(gcf, 'Units', 'Normalized', 'OuterPosition',[0 0.2947 0.6902 0.6781]); % replace 1 with .8 to get back to normal
    
    % select freq [only alpha here]
    if iFreq==1
        theseFreqs = 1:3;
        theseMapLimits = [-4,0];
        thisFreqName = 'Delta';
    elseif iFreq==2
        theseFreqs = 4:7;
        theseMapLimits = [-4,0];
        thisFreqName = 'Theta';
    elseif iFreq==3
        theseFreqs = 8:14;
        theseMapLimits = [-4,0];
        thisFreqName = 'Alpha';
    elseif iFreq==4
        theseFreqs = 15:30;
        theseMapLimits = [-4,0];
        thisFreqName = 'Beta';
    end
    
    % generate topo plots
    cnt=0;
    for iExposures=1:5
        for iTimes=2:5
            for iCond=1:2
                
                if      iTimes==1; theseTimes = 10:24; % baseline   
                elseif  iTimes==2; theseTimes = 65:94; % early immersion
                elseif  iTimes==3; theseTimes = 95:124; % mid immersion
                elseif  iTimes==4; theseTimes = 125:154; % late immersion
                elseif  iTimes==5; theseTimes = 155:191; %    182:197;
                end
                
                % if doing 1-30 Hz analysis, shift times to compensate for
                % cut off at start of ERSP
                theseTimes=theseTimes-1;
             
                
                if      iCond==1 && iTimes==1; thisTitle='CPT B';
                elseif  iCond==1 && iTimes==2; thisTitle='CPT E';
                elseif  iCond==1 && iTimes==3; thisTitle='CPT M';
                elseif  iCond==1 && iTimes==4; thisTitle='CPT L';
                elseif  iCond==1 && iTimes==5; thisTitle='CPT R';
                elseif  iCond==2 && iTimes==1; thisTitle='WPT B';
                elseif  iCond==2 && iTimes==2; thisTitle='WPT E';
                elseif  iCond==2 && iTimes==3; thisTitle='WPT M';
                elseif  iCond==2 && iTimes==4; thisTitle='WPT L';
                elseif  iCond==2 && iTimes==5; thisTitle='WPT R';
                end
                
                % counter and positioning stuff
                cnt=cnt+1;
                
                cntVec = [
                    1,2,4,5,7,8,10,11,...
                    13,14,16,17,19,20,22,23,...
                    25,26,28,29,31,32,34,35,...
                    37,38,40,41,43,44,46,47,...
                    49,50,52,53,55,56,58,59,...
                    ]+.5;
                    
                % create subplots
                subplot(6,12,cntVec(cnt));
                
                % select data for plotting
                theseData = squeeze(mean(mean(mean(ersp(:,iCond,iExposures,:,theseFreqs,theseTimes),1),5),6));
                
                %theseMapLimits = 'maxmin';
                
                %h=figure;
                
                topoplot(theseData,chanlocs,...
                    'maplimits',theseMapLimits,...
                    'electrodes','on')
                
                %title(thisTitle)
                %cbar
                
                %end
            end
        end
    end
    
    
    %compute ANOVAs
    clear condVec trialVec intVec
 
    for iTimes=2:5
        
        if      iTimes==1; theseTimes = 10:24; % baseline
        elseif  iTimes==2; theseTimes = 65:94; % early immersion
        elseif  iTimes==3; theseTimes = 95:124; % mid immersion
        elseif  iTimes==4; theseTimes = 125:154; % late immersion
        elseif  iTimes==5; theseTimes = 155:191; %    182:197;
        end
        
        if usePermStats==1
            
            % load resampled stats for this freq band
            load([sourceDir '/' 'STATS_WITHIN_Resampled_ERSP_ANOVA_30Hz_NewBL_TimeGrad' thisFreqName '.mat'])
            
            for iChan=1:63
                condVec(iChan,iTimes) =  allANOVA(iFreq,iChan,iTimes-1).var1.pValueANOVA;
                trialVec(iChan,iTimes) = allANOVA(iFreq,iChan,iTimes-1).var2.pValueANOVA;
                intVec(iChan,iTimes) = allANOVA(iFreq,iChan,iTimes-1).varInt.pValueANOVA;
            end
            
            % run post-hoc stats
                        
            % get vector of ANOVA interactions p-values
            theseData= intVec(:,iTimes);
            
            clear statVec clear statVecIdx observedData
            
            % convert p-vals into a vector of 0's (ns) and 1's (sig)
            for t=1:length(theseData)
                if theseData(t)<.05
                    statVec(t)=1;
                else
                    statVec(t)=0;
                end
            end
            
            % get indices of sig diff channels
            cnt=0;
            for iChan=1:63
                if statVec(iChan)==1
                    cnt=cnt+1;
                    statVecIdx(cnt) = iChan;
                end
            end
            
            % pull out chans where there's a cond * trial interaction and
            % run follow-up post-hoc tests
            observedData = [squeeze(mean(mean(mean(ersp(:,1,:,statVecIdx,theseFreqs,theseTimes),5),6),4)),squeeze(mean(mean(mean(ersp(:,2,:,statVecIdx,theseFreqs,theseTimes),5),6),4))];
            
            % do real pairwise tests for each session separately
            [~,pVal,~,STATS] = ttest(observedData(:,1),observedData(:,5)); % tx T1vsT5
            tValsObs(1,1) = STATS.tstat;
            pValsObsParametric(1,1) = pVal;
            
            [~,pVal,~,STATS] = ttest(observedData(:,1),observedData(:,3)); % tx T1vsT3
            tValsObs(1,2) = STATS.tstat;
            pValsObsParametric(1,2) = pVal;
            
            [~,pVal,~,STATS] = ttest(observedData(:,3),observedData(:,5)); % tx T3vsT5
            tValsObs(1,3) = STATS.tstat;
            pValsObsParametric(1,3) = pVal;
            
            [~,pVal,~,STATS] = ttest(observedData(:,6),observedData(:,10)); % ct T1vsT5
            tValsObs(2,1) = STATS.tstat;
            pValsObsParametric(2,1) = pVal;
            
            [~,pVal,~,STATS] = ttest(observedData(:,6),observedData(:,8)); % ct T1vsT3
            tValsObs(2,2) = STATS.tstat;
            pValsObsParametric(2,2) = pVal;
            
            [~,pVal,~,STATS] = ttest(observedData(:,8),observedData(:,10)); % ct T3vsT5
            tValsObs(2,3) = STATS.tstat;
            pValsObsParametric(2,3) = pVal;
            
            %             % add stats to a matrix
            %             postHocStats(iTimes).tValsObs = tValsObs;
            %             postHocStats(iTimes).pValsObs = pValsObsParametric;
            
            
            % create null data matrices
            for i=1:1000
                
                for m=1:length(observedData)
                    thisPerm = randperm(size(observedData,2));
                    nullDataMat(m,:) = observedData(m,thisPerm);
                end
                
                % do real pairwise tests for each session separately
                [~,~,~,STATS] = ttest(nullDataMat(:,1),nullDataMat(:,5)); % tx T1vsT5
                tValsNull(1,1,i) = STATS.tstat;
                
                [~,~,~,STATS] = ttest(nullDataMat(:,1),nullDataMat(:,3)); % tx T1vsT3
                tValsNull(1,2,i) = STATS.tstat;
                
                [~,~,~,STATS] = ttest(nullDataMat(:,3),nullDataMat(:,5)); % tx T3vsT5
                tValsNull(1,3,i) = STATS.tstat;
                
                [~,~,~,STATS] = ttest(nullDataMat(:,6),nullDataMat(:,10)); % tx T1vsT5
                tValsNull(2,1,i) = STATS.tstat;
                
                [~,~,~,STATS] = ttest(nullDataMat(:,6),nullDataMat(:,8)); % tx T1vsT3
                tValsNull(2,2,i) = STATS.tstat;
                
                [~,~,~,STATS] = ttest(nullDataMat(:,8),nullDataMat(:,10)); % tx T3vsT5
                tValsNull(2,3,i) = STATS.tstat;
                
            end
            
            clear nullDataMat
            
            % get t-value indices for permuted stats
            for iCond=1:2
                for iTest=1:3
                    
                    % get observed and null t-values
                    theseNullValues  = sort(squeeze(tValsNull(iCond,iTest,:)),1,'descend');
                    thisObsValue = tValsObs(iCond,iTest);
                    
                    % compare obs to null dist
                    [~,tStatIdx] = min(abs(theseNullValues - thisObsValue));
                    
                    %%all_tStats(iCond,iTest) = tStatIdx;
                    
                    % sig or not?
                    if tStatIdx<25 || tStatIdx>975
                        sigMat(iCond,iTest) = 1;
                        tStatIdx_all(iCond,iTest) = tStatIdx;
                    else
                        sigMat(iCond,iTest) = 0;
                        tStatIdx_all(iCond,iTest) = tStatIdx;
                    end
                    
                end
            end
            
            %% save results in struct
            allAlphaIntStats(iTimes).tStatIdx = tStatIdx_all;
            allAlphaIntStats(iTimes).tValsSigMat = sigMat;
            allAlphaIntStats(iTimes).tValsObs = tValsObs;
            allAlphaIntStats(iTimes).pValsObsParametric = pValsObsParametric;
            allAlphaIntStats(iTimes).nChans=length(statVecIdx);
       
        end
        
    end
    
    clear cntVec
    
    % SAVE POSTHOC TEST RESULTS [new 12.02.22]
    save([destDir '/' 'ERSP_Alpha_Posthocs.mat'],'allAlphaIntStats')
    
end