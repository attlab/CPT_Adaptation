%{
EYE_Stats_Resample
Author: Tom Bullock, UCSB Attention Lab
Date: 12.21.19
Date updated:12.01.22

%}

clear
close all

% set dirs
sourceDir = '/home/bullock/BOSS/CPT_Adaptation/Data_Compiled';

% load compiled EYE Data (paMatAll = sub,session,task,eye,timepoint)
load([sourceDir '/' '/CPT_EYE_Master.mat'])


% remove bad subjects (unfortunately lots of bad subs in this dataset)
badSubs = [103,105,108,109,115,116,117,118,126,128,135,136,138,139,140,146,147,148,154,157,158,159];
[a,b] = setdiff(subjects,badSubs);
paMatAll = paMatAll(b,:,:,:,:);


% apply baseline correction [note, 500 Hz SR so event times are 1,20000,32500,77500,97500]
baselineCorrect=1;
theseXlims=[0,195];
theseXticks=[0,40,65,155,195];
if baselineCorrect==1
    paMatBL= nanmean(paMatAll(:,:,:,:,round(26000/2):round(40000/2)),5);
    paMatAll = paMatAll - paMatBL;
end

% downsample to 1Hz [average across each second; 500Hz original SR]
for i=1:195
    paMattAll_DS(:,:,:,:,i) = nanmean(paMatAll(:,:,:,:,((i*500)+1:(i+1)*500)-500),5);
end
paMatAll = [];
paMatAll = paMattAll_DS;

% create a null distribution of t-tests for every session/timepoint 
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


% generate matrix of real t-test results
for j=1:size(paMatAll,5) % sample (timepoint) loop
    for k=1:size(paMatAll,3)
        observedData = squeeze(mean(paMatAll(:,:,k,:,j),4)); % subs x conds (average across R/L eyes)
        [H,P,CI,STATS] = ttest(observedData(:,1),observedData(:,2));
        tValsObs(j,k) = STATS.tstat;
        clear STATS observedData 
    end
end

    
% compare observed t-test at each trial and timepoint with corresponding null distribution of t-values

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


% convert idx value to a vector of 0's and 1's (representing sig at p<.05)
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
if baselineCorrect==0
    save([sourceDir '/' 'STATS_Resampled_EYE_n21_raw.mat'],'sigVec','tValsObs','tValsNull','subjects','badSubs')
else
    save([sourceDir '/' 'STATS_Resampled_EYE_n21_bln.mat'],'sigVec','tValsObs','tValsNull','subjects','badSubs')
end