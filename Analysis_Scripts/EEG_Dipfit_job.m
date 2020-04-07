%{
EEG_Dipfit_Job
Author: Tom Bullock, UCSB Attention Lab
Date: 04.05.20

Run Dipfit script
%}

clear 
close all

% which subs?
subjects = CPT_SUBJECTS;

% if run on local machine(0), else if run on cluster(1)
processInParallel=1;

% cluster settings
if processInParallel
    cluster=parcluster();
    job = createJob(cluster);
end

% set dirs 
parentDir = '/home/bullock/BOSS/CPT_Adaptation';
sourceDir = [parentDir '/' 'EEG_ICA_50Hz_LP'];
scriptsDir = [parentDir '/' 'Analysis_Scripts'];

% get files
d=dir([sourceDir '/' '*.mat']);

% create tasks
for iLoop=1:length(d)
    filename = d(iLoop).name;
    if processInParallel
        createTask(job,@EEG_Dipfit,0,{filename})
    else
        EEG_Dipfit(filename)
    end
end

if processInParallel
    submit(job)
end