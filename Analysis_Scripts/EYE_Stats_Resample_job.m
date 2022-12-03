%{
EYE_Stats_Resample_job
Author: Tom Bullock, UCSB Attention Lab
Date: 12.21.19 (updated 12.02.22)

%}

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
        createTask(job,@EYE_Stats_Resample,0,{baselineCorrect})
    else
        EYE_Stats_Resample(baselineCorrect)
    end
end

% submit job to cluster
if processInParallel
    submit(job) 
    % wait for job to finish?
    %wait(job,'finished');
    %results = getAllOutputArguments(job);
end