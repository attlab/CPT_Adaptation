%{
EEG_Classify_Hit_Miss_job
Author: Tom Bullock
Date: 03.05.20

%}

% select subjects
subjects =[11:14,16:39,51:56];

% run in serial (0) or parallel (1)
runInParallel=1;

if runInParallel
    s = parcluster();
    job = createJob(s);
end

for iSub = 1:length(subjects)
    sjNum = subjects(iSub);
    for timeLock=1:2 % 1=init,2=release
        for permuteLabels=0:1 %0=real, 1=permute
            if runInParallel
                createTask(job,@EEG_Classify_Hit_Miss,0,{sjNum,permuteLabels,timeLock});
            else
                EEG_Classify_Hit_Miss(sjNum,permuteLabels,timeLock)
            end
        end
    end
end

if runInParallel
    submit(job)
end