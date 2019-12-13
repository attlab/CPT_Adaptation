%function EEG_AMICA_job

clear
close all

% select subjects
subjects = CPT_SUBJECTS;

% run in serial (0) or parallel (1)
runInParallel=1;

if runInParallel
    
    cluster=parcluster();
    job = createJob(cluster);

    %s = parcluster;
    %s.ResourceTemplate='-l nodes=^N^:ppn=1,mem=24GB';
    %job=createJob(s,'Name','Jordan_Job');
    %job.AttachedFiles = {'EEG_AMICA.m','sendEmailToMe.m'};
end

%% Task 
tic
try
    
    for iSub = 1:length(subjects)
        sjNum = subjects(iSub);
        for session=1:2
            if runInParallel
                %job.createTask(@EEG_AMICA, 0, {sjNum,session})            
                createTask(job,@EEG_AMICA,0,{sjNum,session});
            else
                EEG_AMICA(sjNum,session)
            end
        end
    end
    
    if runInParallel
        
        %job.submit
        submit(job)

        wait(job,'finished')
        results = getAllOutputArguments(job)
        
        header = 'AMICA COMPLETE!';
        seconds = toc;
        hours = seconds/120;
        message = sprintf('AMICA took %02f hours to complete.',hours);
        %sendEmailToMe(header,message);
    end
    
catch e
    
    header = sprintf('Error running ICA PREPROCESSING for SJ %02d. FUCK MY LIFE.',sjNum);
    message = sprintf('The identifier was:\n%s.\nThe message was:\n%s', e.identifier, e.message);
    %sendEmailToMe(header,message)
    error(message)
    
end


%return