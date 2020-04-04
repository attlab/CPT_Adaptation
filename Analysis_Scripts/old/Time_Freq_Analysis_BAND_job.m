%{
Time_Freq_Analysis_BAND_job
Author: Tom Bullock, UCSB Attention Lab
Date: 05.25.19
%}

clear 
close all

%% run in serial (0) or parallel (1)
runInParallel = 1;

%% set up cluster
%% set up cluster
if runInParallel  
    cluster=parcluster();
    job = createJob(cluster);
end

% %% set up function
% if runInParallel
%     thisFunction = 'Time_Freq_Analysis_BAND.m';
%     s = parcluster;
%     %s.ResourceTemplate='-l nodes=^N^:ppn=1,mem=7GB';
%     job=createJob(s,'Name','Tom_Job');
%     job.AttachedFiles = {thisFunction};
% end

%% select subjects
subjects = CPT_SUBJECTS;
%subjects = 155;
disp(['Processing n=' num2str(length(subjects)) ' subjects'])

%% create jobs for subjects
for iSub =1:length(subjects)
    sjNum = subjects(iSub);
    disp(['Processing Subject ' num2str(sjNum)])
    if runInParallel
        %job.createTask(@Time_Freq_Analysis_BAND,0,{sjNum})
        createTask(job,@Time_Freq_Analysis_BAND,0,{sjNum})
    else
        Time_Freq_Analysis_BAND(sjNum)
    end
end
    
%% submit jobs (if running in parallel)
if runInParallel
    submit(job)
    %job.submit
    %wait(job,'finished');
    %results = getAllOutputArguments(job);
end