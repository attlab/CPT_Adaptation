%{
Physio_Get_Baseline_Data_For_Table
Author: Tom Bullock
Date: 08.05.22

%}


% % function these...
% plotBlCorrectedPhysio=0; % 0:1
% iMeasure=1; % 1:8

clear
close all

% set dirs
sourceDir =  '/home/bullock/BOSS/CPT_Adaptation/Data_Compiled';
destDir = [sourceDir '/' 'Resampled_Stats'];

% load compiled data
load([sourceDir '/' 'PHYSIO_MASTER_RESP_CORR.mat' ])

% load task order (only useful to ID individual subs data file)
sourceDirTaskOrder = sourceDir;
load([sourceDirTaskOrder '/' 'Task_Order.mat'])

% load vector coding male/female
load([sourceDir '/' 'Subjects_and_Sex_Matrix.mat'])

% % remove subs from male/female vector that are not included in any cardiac
% % measures
% [~,diff_idx] = setdiff(subjects_all_42,subjects);
% sex_vector(diff_idx) = [];
% subjects_new = subjects(diff_idx);


% remove bad subjects (120, 123) as they have short recovery periods
badSubjectsIdx=[];
badSubjectsIdx(1) = find(subjects==120);
badSubjectsIdx(2) = find(subjects==123);

all_CO(badSubjectsIdx,:,:,:) = [];
all_HR(badSubjectsIdx,:,:,:) = [];
all_LVET(badSubjectsIdx,:,:,:) = [];
all_PEP(badSubjectsIdx,:,:,:) = [];
all_SV(badSubjectsIdx,:,:,:) = [];

% create vector of subs and sex for these vars
subjects_and_sex_orig = subjects_and_sex;
subjects_and_sex(:,badSubjectsIdx) = [];
subs_sex_CO_HR_LVET_PEP_SV = subjects_and_sex;



% remove additional bad subjects (133,157) from HF data because noise
badSubjectsIdx = [];
badSubjectsIdx(1) = find(subjects==120);
badSubjectsIdx(2) = find(subjects==123);
badSubjectsIdx(3) = find(subjects==133);
badSubjectsIdx(4) = find(subjects==157);

all_HF(badSubjectsIdx,:,:,:) = [];

% create vector of subs and sex for HF
subjects_and_sex = subjects_and_sex_orig;
subjects_and_sex(:,badSubjectsIdx) = [];
subs_sex_HF = subjects_and_sex;

% remove bad subjects from BP (if they have NaNs) and TPR
tmp = [];
tmp = isnan(all_BP);
tmp = sum(sum(sum(tmp,2),3),4);
all_BP(tmp>0,:,:,:)=[];
badSubsBP = subjects(tmp>0);
all_TPR(tmp>0,:,:,:)=[];

% create vector of subs for BP and TPR
subjects_and_sex = subjects_and_sex_orig;
badSubjectsIdx = [8,10,21,28,35];
subjects_and_sex(:,badSubjectsIdx) = [];
subs_sex_BP_TPR = subjects_and_sex;

% % do baseline correction on all measures (correcting to mean 20-40 secs
% % period in baseline)
% if plotBlCorrectedPhysio
%     all_BP = all_BP-mean(all_BP(:,:,:,26:40),4);
%     all_CO = all_CO-mean(all_CO(:,:,:,2600:4000),4);
%     all_HR = all_HR-mean(all_HR(:,:,:,2600:4000),4);
%     all_LVET = all_LVET-mean(all_LVET(:,:,:,2600:4000),4);
%     all_PEP = all_PEP-mean(all_PEP(:,:,:,2600:4000),4);
%     all_SV = all_SV-mean(all_SV(:,:,:,2600:4000),4);
%     all_TPR = all_TPR-mean(all_TPR(:,:,:,2600:4000),4);
%     all_HF = all_HF-nanmean(all_HF(:,:,:,3200:4000),4);% [nan for first 30 secs coz classifier training...address this?] %only 8 secs for bl
% end

% downsample to reduce figure size (mbs)
all_HR = all_HR(:,:,:,1:100:19500);
all_LVET = all_LVET(:,:,:,1:100:19500);
all_PEP = all_PEP(:,:,:,1:100:19500);
all_SV = all_SV(:,:,:,1:100:19500);
all_TPR = all_TPR(:,:,:,1:100:19500);
all_CO = all_CO(:,:,:,1:100:19500);
all_HF = all_HF(:,:,:,1:100:19000); %% FIX TO 195!


% compute means and SDs for table
allMeans = [
    squeeze(mean(mean(all_HR(:,1,2,26:40),4),1)),...
    squeeze(mean(mean(all_HF(:,1,2,33:40),4),1)),...
    squeeze(mean(mean(all_PEP(:,1,2,26:40),4),1)),...
    squeeze(mean(mean(all_LVET(:,1,2,26:40),4),1)),...
    squeeze(mean(mean(all_CO(:,1,2,26:40),4),1)),...
    squeeze(mean(mean(all_SV(:,1,2,26:40),4),1)),...
    squeeze(mean(mean(all_BP(:,1,2,26:40),4),1)),...
    squeeze(mean(mean(all_TPR(:,1,2,26:40),4),1))
    ];


allSDs = [
    squeeze(std(mean(all_HR(:,1,2,26:40),4),0,1)),...
    squeeze(std(mean(all_HF(:,1,2,33:40),4),0,1)),...
    squeeze(std(mean(all_PEP(:,1,2,26:40),4),0,1)),...
    squeeze(std(mean(all_LVET(:,1,2,26:40),4),0,1)),...
    squeeze(std(mean(all_CO(:,1,2,26:40),4),0,1)),...
    squeeze(std(mean(all_SV(:,1,2,26:40),4),0,1)),...
    squeeze(std(mean(all_BP(:,1,2,26:40),4),0,1)),...
    squeeze(std(mean(all_TPR(:,1,2,26:40),4),0,1))
    ];


% compute means and SDs for males/females separately
allMeans_males = [
    squeeze(mean(mean(all_HR(find(subs_sex_CO_HR_LVET_PEP_SV(2,:)==1),1,2,26:40),4),1)),...
    squeeze(mean(mean(all_HF(find(subs_sex_HF(2,:)==1),1,2,33:40),4),1)),...
    squeeze(mean(mean(all_PEP(find(subs_sex_CO_HR_LVET_PEP_SV(2,:)==1),1,2,26:40),4),1)),...
    squeeze(mean(mean(all_LVET(find(subs_sex_CO_HR_LVET_PEP_SV(2,:)==1),1,2,26:40),4),1)),...
    squeeze(mean(mean(all_CO(find(subs_sex_CO_HR_LVET_PEP_SV(2,:)==1),1,2,26:40),4),1)),...
    squeeze(mean(mean(all_SV(find(subs_sex_CO_HR_LVET_PEP_SV(2,:)==1),1,2,26:40),4),1)),...
    squeeze(mean(mean(all_BP(find(subs_sex_BP_TPR(2,:)==1),1,2,26:40),4),1)),...
    squeeze(mean(mean(all_TPR(find(subs_sex_BP_TPR(2,:)==1),1,2,26:40),4),1))
    ];

allSDs_males = [
    squeeze(std(mean(all_HR(find(subs_sex_CO_HR_LVET_PEP_SV(2,:)==1),1,2,26:40),4),0,1)),...
    squeeze(std(mean(all_HF(find(subs_sex_HF(2,:)==1),1,2,33:40),4),0,1)),...
    squeeze(std(mean(all_PEP(find(subs_sex_CO_HR_LVET_PEP_SV(2,:)==1),1,2,26:40),4),0,1)),...
    squeeze(std(mean(all_LVET(find(subs_sex_CO_HR_LVET_PEP_SV(2,:)==1),1,2,26:40),4),0,1)),...
    squeeze(std(mean(all_CO(find(subs_sex_CO_HR_LVET_PEP_SV(2,:)==1),1,2,26:40),4),0,1)),...
    squeeze(std(mean(all_SV(find(subs_sex_CO_HR_LVET_PEP_SV(2,:)==1),1,2,26:40),4),0,1)),...
    squeeze(std(mean(all_BP(find(subs_sex_BP_TPR(2,:)==1),1,2,26:40),4),0,1)),...
    squeeze(std(mean(all_TPR(find(subs_sex_BP_TPR(2,:)==1),1,2,26:40),4),0,1))
    ];

allMeans_females = [
    squeeze(mean(mean(all_HR(find(subs_sex_CO_HR_LVET_PEP_SV(2,:)==0),1,2,26:40),4),1)),...
    squeeze(mean(mean(all_HF(find(subs_sex_HF(2,:)==0),1,2,33:40),4),1)),...
    squeeze(mean(mean(all_PEP(find(subs_sex_CO_HR_LVET_PEP_SV(2,:)==0),1,2,26:40),4),1)),...
    squeeze(mean(mean(all_LVET(find(subs_sex_CO_HR_LVET_PEP_SV(2,:)==0),1,2,26:40),4),1)),...
    squeeze(mean(mean(all_CO(find(subs_sex_CO_HR_LVET_PEP_SV(2,:)==0),1,2,26:40),4),1)),...
    squeeze(mean(mean(all_SV(find(subs_sex_CO_HR_LVET_PEP_SV(2,:)==0),1,2,26:40),4),1)),...
    squeeze(mean(mean(all_BP(find(subs_sex_BP_TPR(2,:)==0),1,2,26:40),4),1)),...
    squeeze(mean(mean(all_TPR(find(subs_sex_BP_TPR(2,:)==0),1,2,26:40),4),1))
    ];

allSDs_females = [
    squeeze(std(mean(all_HR(find(subs_sex_CO_HR_LVET_PEP_SV(2,:)==0),1,2,26:40),4),0,1)),...
    squeeze(std(mean(all_HF(find(subs_sex_HF(2,:)==0),1,2,33:40),4),0,1)),...
    squeeze(std(mean(all_PEP(find(subs_sex_CO_HR_LVET_PEP_SV(2,:)==0),1,2,26:40),4),0,1)),...
    squeeze(std(mean(all_LVET(find(subs_sex_CO_HR_LVET_PEP_SV(2,:)==0),1,2,26:40),4),0,1)),...
    squeeze(std(mean(all_CO(find(subs_sex_CO_HR_LVET_PEP_SV(2,:)==0),1,2,26:40),4),0,1)),...
    squeeze(std(mean(all_SV(find(subs_sex_CO_HR_LVET_PEP_SV(2,:)==0),1,2,26:40),4),0,1)),...
    squeeze(std(mean(all_BP(find(subs_sex_BP_TPR(2,:)==0),1,2,26:40),4),0,1)),...
    squeeze(std(mean(all_TPR(find(subs_sex_BP_TPR(2,:)==0),1,2,26:40),4),0,1))
    ];



