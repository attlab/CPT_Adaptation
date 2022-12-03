%{
EEG_Clean_For_ICA_job
Author: Tom Bullock
Date:12.02.22

%}

clear 
close all

scriptsDir = '/home/bullock/BOSS/CPT_Adaptation/Analysis_Scripts';
addpath(genpath(scriptsDir))
cd(scriptsDir)

% which subs?
subjects = CPT_SUBJECTS;

% if run on local machine(0), else if run on cluster(1)
processInParallel=1;

% downsample (for main analyses = 1) or not (for muscle noise analysis = 0)
analysisType=1;

% cluster settings
if processInParallel
    cluster=parcluster();
    %cluster.ResourceTemplate = '--ntasks-per-node=6 --mem=65536'; % max set to 12! mem not working atm
    job = createJob(cluster);
end

% create tasks
for iSub = 1:length(subjects)
    subject = subjects(iSub); 
    for session=1:2
        if processInParallel
            createTask(job,@EEG_Clean_For_ICA,0,{subject,session,analysisType})         
        else
            EEG_Clean_For_ICA(subject,session,analysisType)
        end       
    end
end

% submit job
if processInParallel
    submit(job)
    % wait for job to finish?
    wait(job,'finished');
    results = getAllOutputArguments(job);
end