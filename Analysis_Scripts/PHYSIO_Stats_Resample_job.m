%{
PHYSIO_Stats_Resample_job
Author: Tom Bullock
Date:12.01.22

Run resampled stats job for all eight physio data measures

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

% create tasks
for plotBlCorrectedPhysio=0:1
    for iMeasure=1:8
        if processInParallel
            createTask(job,@PHYSIO_Stats_Resample,0,{plotBlCorrectedPhysio,iMeasure})   
        else
            PHYSIO_Stats_Resample(plotBlCorrectedPhysio,iMeasure)
        end
    end
end

% submit job to cluster
if processInParallel
    submit(job)
    % wait for job to finish?
    %wait(job,'finished');
    %results = getAllOutputArguments(job);
end
