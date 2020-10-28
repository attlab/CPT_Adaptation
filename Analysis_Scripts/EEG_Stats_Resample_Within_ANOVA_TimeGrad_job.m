%function EEG_Clean_For_ICA_job

clear 
close all

scriptsDir = '/home/bullock/BOSS/CPT_Adaptation/Analysis_Scripts';
addpath(genpath(scriptsDir))
cd(scriptsDir)

% if run on local machine(0), else if run on cluster(1)
processInParallel=1;

% cluster settings
if processInParallel
    cluster=parcluster();
    %cluster.ResourceTemplate = '--ntasks-per-node=6 --mem=65536'; % max set to 12! mem not working atm
    job = createJob(cluster);
end

% send to cluster (only a single job)
for analysisType=2 % leave 1 for now
    
    % analysis specific settings
    if analysisType==1
        freqIdx=1:5;
    else
        freqIdx=1:4;
    end

    
    for iFreq = freqIdx
        
        
        if processInParallel
            createTask(job,@EEG_Stats_Resample_Within_ANOVA_TimeGrad,0,{analysisType,iFreq})
        else
            EEG_Stats_Resample_Within_ANOVA_TimeGrad(analysisType,iFreq)
        end
        
    end
end


if processInParallel
    
    % new cluster
    submit(job)
    
    % wait for job to finish?
    %wait(job,'finished');
    %results = getAllOutputArguments(job);
end
