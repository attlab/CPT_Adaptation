%function EEG_Clean_For_ICA_job

clear 
close all

scriptsDir = '/home/bullock/BOSS/CPT_Adaptation/Analysis_Scripts';
addpath(genpath(scriptsDir))
cd(scriptsDir)

% which subs?
subjects = CPT_SUBJECTS;

% if run on local machine(0), else if run on cluster(1)
processInParallel=1;

% cluster settings
if processInParallel
    cluster=parcluster();
    job = createJob(cluster);   
end

% create tasks
for iterationIdx =1:100
   if processInParallel
       createTask(job,@Time_Freq_Analysis_ERSP_Stats_Resample_1_100Hz,0,{iterationIdx})
   else
       Time_Freq_Analysis_ERSP_Stats_Resample_1_100Hz(iterationIdx)
   end
end


if processInParallel

    % new cluster
    submit(job)
    
    % wait for job to finish?
    wait(job,'finished');
    results = getAllOutputArguments(job);
end


if processInParallel

%% load and compile all tValsNull data
for i=1:100
   load(['/home/bullock/BOSS/CPT_Adaptation/Time_Freq_Resample_Results_1_100Hz' '/' sprintf('timeFreq_100Hz_resample_%d.mat',i)]) 
    i
   if i==1
       tValsNullAll = tValsNull;
   else
       tValsNullAll = cat(1,tValsNullAll,tValsNull);
   end
   
end

clear tValsNull
tValsNull=tValsNullAll;

%% get observerved tVals 
% set dirs
sourceDir = '/home/bullock/BOSS/CPT_Adaptation/Data_Compiled';


% load data
load([sourceDir '/' 'GRAND_ERSP_1-100Hz.mat'])

%% baseline correct?
analysisType=1;
baselineCorrect=1;
if baselineCorrect
    
    if analysisType>1
        baselineCorrectTimepoints = 24:39;
    else
        baselineCorrectTimepoints = 25:40;
    end
    
    erspBL = mean(erspAll(:,:,:,:,:,baselineCorrectTimepoints),6); % this is a little off, fix
    ersp = erspAll - erspBL;
    
    clear erspAll
    erspAll=ersp;
else
    ersp = erspAll;
end


for iExposures=1:size(erspAll,3)
    for iFreq=1:size(erspAll,5)
        for iTimepoint=1:size(erspAll,6)
            
            observedData = squeeze(mean(erspAll(:,:,iExposures,:,iFreq,iTimepoint),4));
            
            [H,P,CI,STATS] = ttest(observedData(:,1),observedData(:,2));
            tValsObs(iExposures,iFreq,iTimepoint) = STATS.tstat;
            clear STATS nullDataMat observedData
            
        end
    end
end

%% compare observed t-test at each trial and timepoint with corresponding null distribution of t-values

% exposure loop
for j=1:size(tValsNull,2)
    
    % freq loop
    for k=1:size(tValsNull,3)
        
        % channel loop
        for t=1:size(tValsNull,4)
            
            thisNullDist = sort(tValsNull(:,j,k,t),1,'descend');
            [~,idx] = min(abs(thisNullDist - tValsObs(j,k,t)));
            tStatIdx(j,k,t) = idx;
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
        for t=1:size(tStatIdx,3)
            if tStatIdx(j,k,t)<25 || tStatIdx(j,k,t)>975
                sigVec(j,k,t) = 1;
            else
                sigVec(j,k,t)=0;
            end
        end
    end
end

% save data
save([sourceDir '/' 'STATS_EEG_ERSP_1-100Hz.mat'],'sigVec','tValsObs','tValsNull','chanlocs','freqs','times')

end


