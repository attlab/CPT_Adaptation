%{
EEG_TFA_Generate_ERSPs_job
Author: Tom Bullock, UCSB Attention Lab
Date: 04.06.20
%}

clear 
close all

% run in serial (0) or parallel (1)
runInParallel = 1;

% set up cluster
if runInParallel  
    cluster=parcluster();
    job = createJob(cluster);
end

% select subjects
subjects = CPT_SUBJECTS;
disp(['Processing n=' num2str(length(subjects)) ' subjects'])

% set analysis type (1 = regular baselineline sub, 2 = no baseline sub)
analysisType=2;

% create jobs for subjects
for iSub =1:length(subjects)
    sjNum = subjects(iSub);
    disp(['Processing Subject ' num2str(sjNum)])
    if runInParallel       
        createTask(job,@EEG_TFA_Generate_ERSPs,0,{sjNum,analysisType})      
    else
        EEG_TFA_Generate_ERSPs(sjNum,analysisType)
    end
end
    
% submit jobs (if running in parallel)
if runInParallel
    submit(job)
    wait(job,'finished');
    results = getAllOutputArguments(job);
end