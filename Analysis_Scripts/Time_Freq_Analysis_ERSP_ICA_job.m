%{
Time_Freq_Analysis_ERSP_job
Author: Tom Bullock, UCSB Attention Lab
Date: 04.06.20
%}

clear 
close all

%% run in serial (0) or parallel (1)
runInParallel = 0;

%% set up cluster
if runInParallel  
    cluster=parcluster();
    job = createJob(cluster);
end

%% select subjects
subjects = CPT_SUBJECTS;
disp(['Processing n=' num2str(length(subjects)) ' subjects'])

%% set analysis type (11 = regular baselineline sub, 12 = no baseline sub)
analysisType=11;


%% create jobs for subjects
for iSub =1:length(subjects)
    sjNum = subjects(iSub);
    disp(['Processing Subject ' num2str(sjNum)])
    if runInParallel       
        createTask(job,@Time_Freq_Analysis_ERSP_ICA,0,{sjNum,analysisType})      
    else
        Time_Freq_Analysis_ERSP_ICA(sjNum,analysisType)
    end
end
    
%% submit jobs (if running in parallel)
if runInParallel
    submit(job)
    wait(job,'finished');
    results = getAllOutputArguments(job);
end

% %% Compile ERSPS
% Time_Freq_Analysis_ERSP_Compile(analysisType)
% disp('ERSPs COMPILED')

