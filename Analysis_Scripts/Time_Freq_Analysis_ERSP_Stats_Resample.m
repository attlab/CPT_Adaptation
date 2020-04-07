%{
Time_Freq_Analysis_ERSP_Stats_Resample
Author: Tom Bullock
Date: 12.26.19

%}

clear
close all

analysisType=6; % 1=1-100Hz, 3=1-30Hz

    

% set dirs
sourceDir = '/home/bullock/BOSS/CPT_Adaptation/Data_Compiled';


% load data
if analysisType==6
    load([sourceDir '/' 'GRAND_ERSP_1-30Hz_ICA_ICLabel_Dipfit_50HzLP.mat'])
    freqIdx=1:4; % loop through lower freq bands
    criticalTimepoints=79:154;
elseif analysisType==3
    load([sourceDir '/' 'GRAND_ERSP_1-30Hz_ICA_Brain_80.mat'])
    freqIdx=1:4; % loop through lower freq bands
    criticalTimepoints=79:154;
elseif analysisType==1
    load([sourceDir '/' 'GRAND_ERSP_1-100Hz.mat'])
    freqIdx=1:5;
    criticalTimepoints=80:155;
end

% do baseline correction
baselineCorrect=1;
if baselineCorrect
    
    if analysisType>1
        baselineCorrectTimepoints = 25:39;
    else
        baselineCorrectTimepoints = 26:40;
    end
    
    erspBL = mean(erspAll(:,:,:,:,:,baselineCorrectTimepoints),6); % this is a little off, fix
    ersp = erspAll - erspBL;
else
    ersp = erspAll;
end

clear erspAll
erspAll = ersp;




% main loop (null data)
for iIteration=1:1000
    iIteration
    for iExposures=1:size(erspAll,3)
        for iFreq=freqIdx
            if iFreq==1
                theseFreqs=1:3;
            elseif iFreq==2
                theseFreqs=4:7;
            elseif iFreq==3
                theseFreqs=8:14;
            elseif iFreq==4
                theseFreqs=15:30;
            elseif iFreq==5
                theseFreqs=31:100;
            end
            
            
            
            for iChannel = 1:size(erspAll,4)
                
                observedData = squeeze(mean(mean(erspAll(:,:,iExposures,iChannel,theseFreqs,criticalTimepoints),5),6));
                
                for m=1:length(observedData)
                    thisPerm = randperm(size(observedData,2));
                    nullDataMat(m,:) = observedData(m,thisPerm);
                end
                
                [H,P,CI,STATS] = ttest(nullDataMat(:,1),nullDataMat(:,2));
                tValsNull(iIteration,iExposures,iFreq,iChannel) = STATS.tstat;
                clear STATS nullDataMat observedData
                
            end
        end
    end
end


% get observed t-tests
for iExposures=1:size(erspAll,3)
   for iFreq=freqIdx;
        if iFreq==1
            theseFreqs=1:3;
        elseif iFreq==2
            theseFreqs=4:7;
        elseif iFreq==3
            theseFreqs=8:14;
        elseif iFreq==4
            theseFreqs=15:30;
        elseif iFreq==5
            theseFreqs=31:100;
        end
        
        iFreq
        
        for iChannel = 1:size(erspAll,4)
        
            observedData = squeeze(mean(mean(erspAll(:,:,iExposures,iChannel,theseFreqs,criticalTimepoints),5),6)); 
            [H,P,CI,STATS] = ttest(observedData(:,1),observedData(:,2));
            tValsObs(iExposures,iFreq,iChannel) = STATS.tstat;
            clear STATS observedData
        end
   end
end



%% compare observed t-test at each trial and timepoint with corresponding null distribution of t-values

% exposure loop
for j=1:size(tValsNull,2)
    
    % freq loop
    for k=1:size(tValsNull,3)
        
        % channel loop
        for c=1:size(tValsNull,4)
            
            thisNullDist = sort(tValsNull(:,j,k,c),1,'descend');
            [~,idx] = min(abs(thisNullDist - tValsObs(j,k,c)));
            tStatIdx(j,k,c) = idx;
            clear thisNullDist  idx
            
        end
    end
end

% convert idx value to probability
%pValuesPairwise = tStatIdx./1000;

% convert idx value to a vector of 0's and 1's (representing significance
% at p<.05)
clear sigVec
for j=1:size(tStatIdx,1)
    for k=1:size(tStatIdx,2)
        for c=1:size(tStatIdx,3)
            if tStatIdx(j,k,c)<25 || tStatIdx(j,k,c)>975
                sigVec(j,k,c) = 1;
            else
                sigVec(j,k,c)=0;
            end
        end
    end
end

% save data
if analysisType==6
    save([sourceDir '/' 'STATS_EEG_ERSP_1-30Hz_ICA_ICLabel_Dipfit_50HzLP.mat'],'sigVec','tValsObs','tValsNull','chanlocs','freqs','times')
elseif analysisType==3
    save([sourceDir '/' 'STATS_EEG_ERSP_1-30Hz_ICA_Brain_80.mat'],'sigVec','tValsObs','tValsNull','chanlocs','freqs','times')
elseif analysisType==1
    save([sourceDir '/' 'STATS_EEG_ERSP_1-100Hz_TOPOS.mat'],'sigVec','tValsObs','tValsNull','chanlocs','freqs','times')
end







