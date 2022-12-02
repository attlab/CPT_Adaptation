%function EEG_Clean_For_ICA_job

clear 
close all

scriptsDir = '/home/bullock/BOSS/CPT_Adaptation/Analysis_Scripts';
addpath(genpath(scriptsDir))
cd(scriptsDir)

% if run on local machine(0), else if run on cluster(1)
processInParallel=0;

% cluster settings
if processInParallel
    cluster=parcluster();
    %cluster.ResourceTemplate = '--ntasks-per-node=6 --mem=65536'; % max set to 12! mem not working atm
    job = createJob(cluster);
end


% create tasks
for plotBlCorrectedPhysio=0
    for iMeasure=1:8
        if processInParallel
            createTask(job,@Physio_Stats_Resample_Within_Analysis,0,{plotBlCorrectedPhysio,iMeasure})   
        else
            Physio_Stats_Resample_Within_Analysis(plotBlCorrectedPhysio,iMeasure)
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
