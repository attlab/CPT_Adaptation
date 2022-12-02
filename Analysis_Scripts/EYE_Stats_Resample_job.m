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
for baselineCorrect=0:1
    if processInParallel
        createTask(job,@EYE_Stats_Resample_Within_ANOVA,0,{baselineCorrect})
    else
        EYE_Stats_Resample_Within_ANOVA(baselineCorrect)
    end
end


if processInParallel
    
    % new cluster
    submit(job)
    
    % wait for job to finish?
    %wait(job,'finished');
    %results = getAllOutputArguments(job);
end
