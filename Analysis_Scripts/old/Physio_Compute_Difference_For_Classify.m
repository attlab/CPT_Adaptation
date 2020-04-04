%{
Physio_Compute_Difference_Scores
Author: Tom Bullock
Date: 01.02.20

Load each measure, get the final xx (30 secs?) of the CPT/WPT exposure and calculate a delta, adaptation score etc. 

Do a measure over time as well as final xx secs...

%}

clear
close all

sourceDir = '/home/bullock/BOSS/CPT_Adaptation/Data_Compiled';

%% all subjects
allSubjects = 101:161;

%% create NaN grandMat (expand this if i add more features )
grandMat(1:61,1:5,1:190,1:8) = nan;

%% load PHYSIO data
physioStruct = load([sourceDir '/' 'PHYSIO_FOR_PREDICTIVE_ANALYSIS.mat']);
for i=1:6
   
    
    if      i==1; theseData=physioStruct.all_BP; theseSubs = setdiff(physioStruct.subjects,physioStruct.badSubjects_BP); % bad subs already removed
    elseif  i==2; theseData=physioStruct.all_HF; [theseSubs,theseSubsIdx] = setdiff(physioStruct.subjects,physioStruct.badSubjects_HF);
    elseif  i==3; theseData=physioStruct.all_HR; [theseSubs,theseSubsIdx]  = setdiff(physioStruct.subjects,physioStruct.badSubjects_HR_LVET_PEP_SV);
    elseif  i==4; theseData=physioStruct.all_LVET; [theseSubs,theseSubsIdx]  = setdiff(physioStruct.subjects,physioStruct.badSubjects_HR_LVET_PEP_SV);
    elseif  i==5; theseData=physioStruct.all_PEP; [theseSubs,theseSubsIdx]  = setdiff(physioStruct.subjects,physioStruct.badSubjects_HR_LVET_PEP_SV);
    elseif  i==6; theseData=physioStruct.all_SV; [theseSubs,theseSubsIdx]  = setdiff(physioStruct.subjects,physioStruct.badSubjects_HR_LVET_PEP_SV);
    end
    
    % remove bad subs
    if i==1
        theseDataDiff = squeeze(theseData(:,:,1,:) - theseData(:,:,2,:));
    else
        theseData = theseData(theseSubsIdx,:,:,:); % remove bad subs
        theseDataDiff =  squeeze(theseData(:,:,1,:) - theseData(:,:,2,:));
    end
    
    % create a grand mat of all data
    for j=1:length(theseSubs) 
        grandMat(theseSubs(j)-100,:,:,i) = theseDataDiff(j,:,1:190);
    end
    
    clear theseSubs theseData theseSubsIdx theseDataDiff
    
end

clear physioStruct 


%% load PUPIL data
pupilStruct = load([sourceDir '/' 'EYE_FOR_PREDICTIVE_ANALYSIS.mat']);

% remove bad subjects
[theseSubs,b] = setdiff(pupilStruct.subjects,pupilStruct.badSubs);

% create difference mat and average over eyes
theseDataDiff = pupilStruct.paMatAll(:,1,:,:,:) - pupilStruct.paMatAll(:,2,:,:,:);
theseDataDiff = squeeze(mean(theseDataDiff,4));

% add pupil to grand mat
for j=1:length(theseSubs)
    grandMat(theseSubs(j)-100,:,:,7) = theseDataDiff(j,:,1:190); 
end

clear pupilStruct theseDataDiff theseSubs a b 


%% load EEG Data (no ICA, just use 1-100 Hz?...try different stuff)
eegStruct = load([sourceDir '/' 'GRAND_ERSP_1-100Hz.mat']);
theseSubs = CPT_SUBJECTS;

theseDataDiff = eegStruct.erspAll(:,1,:,:,:,:) - eegStruct.erspAll(:,2,:,:,:,:);
theseDataDiff = squeeze(mean(mean(theseDataDiff,4),5));

for j=1:size(eegStruct.erspAll,1)
    grandMat(theseSubs(j)-100,:,:,8) = theseDataDiff(j,:,1:190);
end

clear eegStruct theseDataDiff theseSubs



%% create a single value for each measure per CPTvsWPT difference score based on the final 30 secs (?) of the exposure
clear grandMatSingle
grandMatSingle(1:61,1:5,1:10) = nan;
grandMatSingle(1:61,1:5,1:8) = squeeze(nanmean(grandMat(:,:,126:155,:),3));


%% load SELF-REPORT data
painStruct = load([sourceDir '/' 'SELF_REPORT_FOR_PREDICTIVE_ANALYSIS.mat']);
theseSubs=painStruct.mySubjects;

theseDataDiff = squeeze(painStruct.allPain(:,1,:)-painStruct.allPain(:,2,:));

for j=1:length(theseDataDiff)
   grandMatSingle(theseSubs(j)-100,:,9) = theseDataDiff(j,:);  
end

clear theseDataDiff painStruct theseSubs

%% create headers list (covers both mats)
grandMatHeaders = {'BP','HF','HR','LVET','PEP','SV','PUPIL','EEG','PAIN','VO2'};
   
% %% load CORTISOL data (leave this for now - only a 2xpost stress
% measures)
% cortStruct = load([sourceDir '/' 'Cortisol_CPT_Master.mat']);

%% load VO2 data and intergrate into grandMatSingle
cpetMAT =load([sourceDir '/' 'CPET_MASTER.mat']);
theseData = cpetMAT.allCPET(1:58);
%theseVO2s(1:61)=nan;

for i=1:length(theseData)
   theseSubs(i)=theseData(i).sjNum;
   theseVO2s(i) = theseData(i).vo2max_orig;
end

% vo2max added (replicated 5 times across sessions)
for j=1:length(theseVO2s)
    grandMatSingle(theseSubs(j)-100,:,10) = theseVO2s(j);
end


%% save grand mats
save([sourceDir '/'  'GRAND_MATS_ALL_DATA_DIFFERENCE_SCORES.mat'],'grandMat','grandMatSingle','grandMatHeaders','allSubjects')





