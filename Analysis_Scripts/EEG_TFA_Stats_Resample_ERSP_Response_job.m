%{
EEG_TFA_Stats_Resample_ERSP_Response_job
Author: Tom Bullock
Date:12.02.22

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

% create tasks for each freq band
for iFreq = 1:4
    if processInParallel
        createTask(job,@EEG_TFA_Stats_Resample_ERSP_Response,0,{iFreq})
    else
        EEG_TFA_Stats_Resample_ERSP_Response(iFreq)
    end
end

% submit job to cluster
if processInParallel
    submit(job)
    % wait for job to finish?
    %wait(job,'finished');
    %results = getAllOutputArguments(job);
end