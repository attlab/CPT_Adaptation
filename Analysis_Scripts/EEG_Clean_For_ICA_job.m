%function EEG_Clean_For_ICA_job

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
    
    % new cluster
    cluster=parcluster();
    job = createJob(cluster);
    
    % old cluster
%     s = parcluster;
%     s.ResourceTemplate='-l nodes=^N^:ppn=4,mem=16GB';
%     job=createJob(s,'Name','Tom_Job');
%     job.AttachedFiles = {'EEG_Clean_For_ICA.m'};
    
end

% create tasks
for iSub = 1:length(subjects)
    subject = subjects(iSub); 
    for session=1:2
        if processInParallel
            
            % origninal cluster
            %job.createTask(@EEG_Clean_For_ICA,0,{subject,session,processInParallel})
            
            % new cluster
            createTask(job,@EEG_Clean_For_ICA,0,{subject,session,processInParallel,analysisType})
            
        else
            EEG_Clean_For_ICA(subject,session,processInParallel,analysisType)
        end
        
    end
end

if processInParallel
    % old cluster
    %job.submit
    
    % new cluster
    submit(job)
    
    % wait for job to finish?
    %wait(job,'finished');
    %results = getAllOutputArguments(job);
end
