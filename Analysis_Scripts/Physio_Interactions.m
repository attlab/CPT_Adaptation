%{
Physio_Interactions
Author: Tom Bullock, UCSB Attention Lab
Date: 04.21.20

Look at relationships between changes in baseline activity (anticipatory
stress) and reactive changes to see if any relationship.

Check what's going on at the start of this script wrt bad subjects?

%}

clear
close all

% set dirs
sourceDir =  '/home/bullock/BOSS/CPT_Adaptation/Data_Compiled';
destDir = '/home/bullock/BOSS/CPT_Adaptation/Plots';

% load compiled data
load([sourceDir '/' 'PHYSIO_MASTER_RESP_CORR.mat' ])

% load task order (only useful to ID individual subs data file)
sourceDirTaskOrder = sourceDir;
load([sourceDirTaskOrder '/' 'Task_Order.mat'])

% remove bad subjects (120, 123) as they have short recovery periods
badSubjectsIdx = [];
badSubjectsIdx(1) = find(subjects==120);
badSubjectsIdx(2) = find(subjects==123);

all_BP(badSubjectsIdx,:,:,:) = [];
all_CO(badSubjectsIdx,:,:,:) = [];
all_HR(badSubjectsIdx,:,:,:) = [];
all_LVET(badSubjectsIdx,:,:,:) = [];
all_PEP(badSubjectsIdx,:,:,:) = [];
all_SV(badSubjectsIdx,:,:,:) = [];
all_TPR(badSubjectsIdx,:,:,:) = [];


% % remove additional bad subjects (133,157) from HF data because noise
% badSubjectsIdx(1) = find(subjects==120);
% badSubjectsIdx(2) = find(subjects==123);
% badSubjectsIdx(3) = find(subjects==133);
% badSubjectsIdx(4) = find(subjects==157);
% 
% all_HF(badSubjectsIdx,:,:,:) = [];

% remove bad subjects from BP (also remove from PEP and HR for the purpose
% of looking at cross measure relationships)
tmp = [];
tmp = isnan(all_BP);
tmp = sum(sum(sum(tmp,2),3),4);
all_BP(tmp>0,:,:,:)=[];
all_PEP(tmp>0,:,:,:)=[];
all_HR(tmp>0,:,:,:)=[];
all_TPR(tmp>0,:,:,:)=[];

badSubsBP = subjects(tmp>0);


% arrange the raw data in a structure and downsample to 1 Hz
raw.all_BP = all_BP;
%raw.all_CO = all_CO(:,:,:,1:100:19500);
%raw.all_HF = all_HF(:,:,:,1:100:19000);
raw.all_HR = all_HR(:,:,:,1:100:19500);
%raw.all_LVET = all_LVET(:,:,:,1:100:19500);
raw.all_PEP = all_PEP(:,:,:,1:100:19500);
%raw.all_SV = all_SV(:,:,:,1:100:19500);
%raw.all_TPR = all_TPR(:,:,:,1:100:19500);

% do baseline correction on all measures (correcting to mean 26-40 secs
% period in baseline)
all_BP = all_BP-mean(all_BP(:,:,:,26:40),4);
%all_CO = all_CO-mean(all_CO(:,:,:,2600:4000),4);
all_HR = all_HR-mean(all_HR(:,:,:,2600:4000),4);
%all_LVET = all_LVET-mean(all_LVET(:,:,:,2600:4000),4);
all_PEP = all_PEP-mean(all_PEP(:,:,:,2600:4000),4);
%all_SV = all_SV-mean(all_SV(:,:,:,2600:4000),4);
%all_TPR = all_TPR-mean(all_TPR(:,:,:,2600:4000),4);
%all_HF = all_HF-nanmean(all_HF(:,:,:,3200:4000),4);% [nan for first 30 secs coz classifier training...address this?] %only 9 secs for bl


% arrange the bln corrected data in a structure and downsample to 1 Hz
bln.all_BP = all_BP;
%bln.all_CO = all_CO(:,:,:,1:100:19500);
%bln.all_HF = all_HF(:,:,:,1:100:19000);
bln.all_HR = all_HR(:,:,:,1:100:19500);
%bln.all_LVET = all_LVET(:,:,:,1:100:19500);
bln.all_PEP = all_PEP(:,:,:,1:100:19500);
%bln.all_SV = all_SV(:,:,:,1:100:19500);
%bln.all_TPR = all_TPR(:,:,:,1:100:19500);

clear all_BP all_CO all_HF all_HR all_LVET all_PEP all_SV all_TPR

% correlate change in evoked BP with change in induced PEP (T1 vs T5,
% within the CPT condition only)
clear bp_delta pep_delta
bp_delta = mean(bln.all_BP(:,1,1,141:155),4) - mean(bln.all_BP(:,5,1,141:155),4);
pep_delta = mean(raw.all_PEP(:,1,1,26:40),4) - mean(raw.all_BP(:,5,1,26:40),4);

scatter(bp_delta,pep_delta)
lsline
[r,p] = corr(bp_delta,pep_delta);

% correlate change in evoked BP (difference in the difference between T1 CPT and WPT and T5
% CPT and WPT) and induced PEP (difference between T1 CPT and WPT and T5
% CPT and WPT)
clear bp_delta pep_delta
bp_delta = (mean(bln.all_BP(:,1,1,141:155),4) - mean(bln.all_BP(:,1,2,141:155),4)) - (mean(bln.all_BP(:,5,1,141:155),4) - mean(bln.all_BP(:,5,2,141:155),4));
pep_delta = (mean(raw.all_PEP(:,1,1,26:40),4) - mean(raw.all_PEP(:,1,2,26:40),4)) - (mean(raw.all_PEP(:,5,1,26:40),4) - mean(raw.all_PEP(:,5,2,26:40),4));

scatter(bp_delta,pep_delta)
lsline
[r,p] = corr(bp_delta,pep_delta);

% correlate change in evoked HR with change in induced PEP (T1 vs T5,
% within the CPT condition only)
clear bp_delta pep_delta
bp_delta = mean(bln.all_BP(:,1,1,141:155),4) - mean(bln.all_BP(:,5,1,141:155),4);
hr_delta = mean(raw.all_HR(:,1,1,26:40),4) - mean(raw.all_HR(:,5,1,26:40),4);

scatter(bp_delta,hr_delta)
lsline
[r,p] = corr(bp_delta,hr_delta);


% correlate change in evoked BP (difference in the difference between T1 CPT and WPT and T5
% CPT and WPT) and induced HR (difference between T1 CPT and WPT and T5
% CPT and WPT) ***DID NOT INTEND TO DO THIS ANALYSIS BUT IT DOES COME OUT
% SIG???
clear bp_delta pep_delta
bp_delta = (mean(bln.all_BP(:,1,1,141:155),4) - mean(bln.all_BP(:,1,2,141:155),4)) - (mean(bln.all_BP(:,5,1,141:155),4) - mean(bln.all_BP(:,5,2,141:155),4));
hr_delta = (mean(raw.all_HR(:,1,1,26:40),4) - mean(raw.all_HR(:,1,2,26:40),4)) - (mean(raw.all_HR(:,5,1,26:40),4) - mean(raw.all_HR(:,5,2,26:40),4));

scatter(bp_delta,hr_delta)
lsline
[r,p] = corr(bp_delta,hr_delta);



% correlate change in evoked HR (difference in the difference between T1 CPT and WPT and T5
% CPT and WPT) and induced PEP (difference between T1 CPT and WPT and T5
% CPT and WPT)
clear bp_delta pep_delta
hr_delta = (mean(bln.all_HR(:,1,1,141:155),4) - mean(bln.all_HR(:,1,2,141:155),4)) - (mean(bln.all_HR(:,5,1,141:155),4) - mean(bln.all_HR(:,5,2,141:155),4));
pep_delta = (mean(raw.all_PEP(:,1,1,26:40),4) - mean(raw.all_PEP(:,1,2,26:40),4)) - (mean(raw.all_PEP(:,5,1,26:40),4) - mean(raw.all_PEP(:,5,2,26:40),4));

scatter(hr_delta,pep_delta)
lsline
[r,p] = corr(hr_delta,pep_delta);


% correlate the difference in induced PEP (CPTvsWPT) with difference in
% evoked BP (CPT vs WPT) on each trial pair
for i=1:5
    subplot(1,5,i)
    clear bp_delta pep_delta
    bp_delta = mean(bln.all_BP(:,i,1,141:155),4) - mean(bln.all_BP(:,i,2,141:155),4);
    pep_delta = mean(raw.all_PEP(:,i,1,26:40),4) - mean(raw.all_PEP(:,i,2,26:40),4);
    scatter(bp_delta,pep_delta)
    lsline
    [r,p] = corr(bp_delta,pep_delta);
    all_r(i) = r;
    all_p(i) = p;
end


% correlate the difference in induced PEP (CPTvsWPT) with difference in
% evoked HR (CPT vs WPT) on each trial pair
for i=1:5
    subplot(1,5,i)
    clear bp_delta pep_delta
    hr_delta = mean(bln.all_HR(:,i,1,141:155),4) - mean(bln.all_HR(:,i,2,141:155),4);
    pep_delta = mean(raw.all_PEP(:,i,1,26:40),4) - mean(raw.all_PEP(:,i,2,26:40),4);
    scatter(hr_delta,pep_delta)
    lsline
    pbaspect([1,1,1])
    [r,p] = corr(hr_delta,pep_delta);
    all_r(i) = r;
    all_p(i) = p;
end




