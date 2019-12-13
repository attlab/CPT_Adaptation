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
sourceDir = [parentDir '/' 'EEG_ICA_COMPS_LABELLED'];
scriptsDir = [parentDir '/' 'Analysis_Scripts'];

% get files
d=dir([sourceDir '/' '*.mat']);

% create tasks
for iLoop=1:length(d)
    filename = d(iLoop).name;
    if processInParallel
        createTask(job,@EEG_IC_Label,0,{filename})
    else
        EEG_IC_Label(filename)
    end
end

if processInParallel
    submit(job)
end