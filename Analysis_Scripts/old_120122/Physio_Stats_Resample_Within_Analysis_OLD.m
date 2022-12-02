%{
Physio_Plot_Individuals
Author: Tom Bullock, UCSB Attention Lab
Date: 06.01.19

Plot individual data together for QC/outlier assessment.
Plot mean data for each measure automatically omitting subs with missing
measures (e.g. BP).

Note: if plotting shaded error bars, need to do this in stages OR matlab
crashes
%}

function Physio_Stats_Resample_Within_Analysis(plotBlCorrectedPhysio,iMeasure) % 0 or 1

% % function these...
% plotBlCorrectedPhysio=0; % 0:1
% iMeasure=1; % 1:8

% set dirs
sourceDir =  '/home/bullock/BOSS/CPT_Adaptation/Data_Compiled';
destDir = [sourceDir '/' 'Resampled_Stats'];

% load compiled data
load([sourceDir '/' 'PHYSIO_MASTER_RESP_CORR.mat' ])

% load task order (only useful to ID individual subs data file)
sourceDirTaskOrder = sourceDir;
load([sourceDirTaskOrder '/' 'Task_Order.mat'])

% remove bad subjects (120, 123) as they have short recovery periods
badSubjectsIdx=[];
badSubjectsIdx(1) = find(subjects==120);
badSubjectsIdx(2) = find(subjects==123);

all_CO(badSubjectsIdx,:,:,:) = [];
all_HR(badSubjectsIdx,:,:,:) = [];
all_LVET(badSubjectsIdx,:,:,:) = [];
all_PEP(badSubjectsIdx,:,:,:) = [];
all_SV(badSubjectsIdx,:,:,:) = [];

% remove additional bad subjects (133,157) from HF data because noise
badSubjectsIdx = [];
badSubjectsIdx(1) = find(subjects==120);
badSubjectsIdx(2) = find(subjects==123);
badSubjectsIdx(3) = find(subjects==133);
badSubjectsIdx(4) = find(subjects==157);

all_HF(badSubjectsIdx,:,:,:) = [];

% remove bad subjects from BP (if they have NaNs) and TPR
tmp = [];
tmp = isnan(all_BP);
tmp = sum(sum(sum(tmp,2),3),4);
all_BP(tmp>0,:,:,:)=[];
badSubsBP = subjects(tmp>0);
all_TPR(tmp>0,:,:,:)=[];


% do baseline correction on all measures (correcting to mean 20-40 secs
% period in baseline)
if plotBlCorrectedPhysio
    all_BP = all_BP-mean(all_BP(:,:,:,26:40),4);
    all_CO = all_CO-mean(all_CO(:,:,:,2600:4000),4);
    all_HR = all_HR-mean(all_HR(:,:,:,2600:4000),4);
    all_LVET = all_LVET-mean(all_LVET(:,:,:,2600:4000),4);
    all_PEP = all_PEP-mean(all_PEP(:,:,:,2600:4000),4);
    all_SV = all_SV-mean(all_SV(:,:,:,2600:4000),4);
    all_TPR = all_TPR-mean(all_TPR(:,:,:,2600:4000),4);
    all_HF = all_HF-nanmean(all_HF(:,:,:,3200:4000),4);% [nan for first 30 secs coz classifier training...address this?] %only 8 secs for bl
end

% downsample to reduce figure size (mbs)
all_HR = all_HR(:,:,:,1:100:19500);
all_LVET = all_LVET(:,:,:,1:100:19500);
all_PEP = all_PEP(:,:,:,1:100:19500);
all_SV = all_SV(:,:,:,1:100:19500);
all_TPR = all_TPR(:,:,:,1:100:19500);
all_CO = all_CO(:,:,:,1:100:19500);
all_HF = all_HF(:,:,:,1:100:19000); %% FIX TO 195!

% select measure for stats
disp(['Measure: ' num2str(iMeasure)])

allPhysio=[];
if plotBlCorrectedPhysio
    if      iMeasure==1; allPhysio = all_CO; thisTitle1 = 'CO'; thisYlim = [-1.5,1];
    elseif  iMeasure==2; allPhysio = all_HR; thisTitle1 = 'HR'; thisYlim = [-15,30];
    elseif  iMeasure==3; allPhysio = all_LVET; thisTitle1  = 'LVET'; thisYlim=[-30,15];
    elseif  iMeasure==4; allPhysio = all_PEP; thisTitle1= 'PEP'; thisYlim = [-15,10];
    elseif  iMeasure==5; allPhysio = all_SV; thisTitle1 = 'SV'; thisYlim = [-15,10];
    elseif  iMeasure==6; allPhysio = all_TPR; thisTitle1 = 'TPR'; thisYlim = [-800,200];
    elseif  iMeasure==7; allPhysio = all_BP; thisTitle1 = 'BP';thisYlim = [-20,25];
    elseif  iMeasure==8; allPhysio = all_HF; thisTitle1 = 'HF';thisYlim = [-5,5];
    end
else
    if      iMeasure==1; allPhysio = all_CO; thisTitle1 = 'CO'; thisYlim = [-1.5,1];
    elseif  iMeasure==2; allPhysio = all_HR; thisTitle1 = 'HR'; thisYlim = [50,90];
    elseif  iMeasure==3; allPhysio = all_LVET; thisTitle1  = 'LVET'; thisYlim=[260,320];
    elseif  iMeasure==4; allPhysio = all_PEP; thisTitle1= 'PEP'; thisYlim = [60,90];
    elseif  iMeasure==5; allPhysio = all_SV; thisTitle1 = 'SV'; thisYlim = [20,50];
    elseif  iMeasure==6; allPhysio = all_TPR; thisTitle1 = 'TPR'; thisYlim = [-800,200];
    elseif  iMeasure==7; allPhysio = all_BP; thisTitle1 = 'BP';thisYlim = [50,120];
    elseif  iMeasure==8; allPhysio = all_HF; thisTitle1 = 'HF'; thisYlim = [4,10];
    end
end

%% RUN 5 x 2 x 2 ANOVAs

% add resample toolbox path
addpath(genpath('/home/bullock/BOSS/CPT_Adaptation/resampling'))

% name variables
var1_name = 'cond';
var1_levels = 2;
var2_name = 'trial';
var2_levels = 5;

% get delta values for baseline vs peak on each trial
all_physio_deltas = squeeze(nanmean(allPhysio(:,:,:,141:155),4) - nanmean(allPhysio(:,:,:,26:40),4));


%this is another way to potentially calculate deltas
% if ismember(iMeasure,[1,2,7]) % find max value for HR, CO and MAP
%     max(allPhysio(:,:,:,65:end))
% else
%     min(allPhysio(:,:,:,65:end))
% end


% do real ANOVA

% create observed data matrix
clear observedData
observedData = [all_physio_deltas(:,:,1),all_physio_deltas(:,:,2)];

% run ANOVA on REAL data
clear statOutput
statOutput = teg_repeated_measures_ANOVA(observedData,[var1_levels var2_levels],{var1_name, var2_name});

% create vectors of main and int F values
var1.fValObserved = statOutput(1,1);
var2.fValObserved = statOutput(2,1);
varInt.fValObserved = statOutput(3,1);


% do perm ANOVA
for j=1:1000
    
    for i=1:size(observedData,1)
        thisPerm = randperm(size(observedData,2));
        for k=1:length(thisPerm)
            nullData(i,k,j) = observedData(i,thisPerm(k));
            
        end
    end
    
    % run ANOVA on PERM data
    clear statOutput
    statOutput = teg_repeated_measures_ANOVA(nullData(:,:,j),[var1_levels var2_levels],{var1_name, var2_name});
    var1.fValsNull(j,1) = statOutput(1,1);
    var2.fValsNull(j,1) = statOutput(2,1);
    varInt.fValsNull(j,1) = statOutput(3,1);
    
end


% sort null f-values, get index value and convert to percentile (VAR_1)
var1.NAME = var1_name;
var1.LEVELS = var1_levels;
var1.fValsNull = sort(var1.fValsNull(:,1),1,'descend');
[c var1.fValueIndex] = min(abs(var1.fValsNull - var1.fValObserved));
var1.fValueIndex = var1.fValueIndex/1000;
var1.pValueANOVA = var1.fValueIndex;

% sort null f-values, get index value and convert to percentile (VAR_2)
var2.NAME = var2_name;
var2.LEVELS = var2_levels;
var2.fValsNull = sort(var2.fValsNull(:,1),1,'descend');
[c var2.fValueIndex] = min(abs(var2.fValsNull - var2.fValObserved));
var2.fValueIndex = var2.fValueIndex/1000;
var2.pValueANOVA = var2.fValueIndex;

% sort null f-values, get index value and convert to percentile (VAR INTER)
VarInt.NAME = 'INTERACTION';
varInt.LEVELS = [num2str(var1_levels) '-by-' num2str(var2_levels)];
varInt.fValsNull = sort(varInt.fValsNull(:,1),1,'descend');
[c varInt.fValueIndex] = min(abs(varInt.fValsNull - varInt.fValObserved));
varInt.fValueIndex = varInt.fValueIndex/1000;
varInt.pValueANOVA = varInt.fValueIndex;


% add to time struct
allANOVA.var1 = var1;
allANOVA.var2 = var2;
allANOVA.varInt = varInt;

clear nullData
    



%% RUN PAIRWISE T-TESTS (T1vsT5, T1vsT3,T3vsT5)


% create observed data matrix
clear observedData
observedData = [all_physio_deltas(:,:,1),all_physio_deltas(:,:,2)];

% do real pairwise tests for each session separately
[~,~,~,STATS] = ttest(observedData(:,1),observedData(:,5)); % tx T1vsT5
tValsObs(1,1) = STATS.tstat;

[~,~,~,STATS] = ttest(observedData(:,1),observedData(:,3)); % tx T1vsT3
tValsObs(1,2) = STATS.tstat;

[~,~,~,STATS] = ttest(observedData(:,3),observedData(:,5)); % tx T3vsT5
tValsObs(1,3) = STATS.tstat;

[~,~,~,STATS] = ttest(observedData(:,6),observedData(:,10)); % tx T1vsT5
tValsObs(2,1) = STATS.tstat;

[~,~,~,STATS] = ttest(observedData(:,6),observedData(:,8)); % tx T1vsT3
tValsObs(2,2) = STATS.tstat;

[~,~,~,STATS] = ttest(observedData(:,8),observedData(:,10)); % tx T3vsT5
tValsObs(2,3) = STATS.tstat;


% create null data matrices
for i=1:1000
    
    for m=1:length(observedData)
        thisPerm = randperm(size(observedData,2));
        nullDataMat(m,:) = observedData(m,thisPerm);
    end
    
    
    
    % do real pairwise tests for each session separately
    [~,~,~,STATS] = ttest(nullDataMat(:,1),nullDataMat(:,5)); % tx T1vsT5
    tValsNull(1,1,i) = STATS.tstat;
    
    [~,~,~,STATS] = ttest(nullDataMat(:,1),nullDataMat(:,3)); % tx T1vsT3
    tValsNull(1,2,i) = STATS.tstat;
    
    [~,~,~,STATS] = ttest(nullDataMat(:,3),nullDataMat(:,5)); % tx T3vsT5
    tValsNull(1,3,i) = STATS.tstat;
    
    [~,~,~,STATS] = ttest(nullDataMat(:,6),nullDataMat(:,10)); % tx T1vsT5
    tValsNull(2,1,i) = STATS.tstat;
    
    [~,~,~,STATS] = ttest(nullDataMat(:,6),nullDataMat(:,8)); % tx T1vsT3
    tValsNull(2,2,i) = STATS.tstat;
    
    [~,~,~,STATS] = ttest(nullDataMat(:,8),nullDataMat(:,10)); % tx T3vsT5
    tValsNull(2,3,i) = STATS.tstat;
    
end

clear nullDataMat

% get t-value indices for permuted stats
for iCond=1:2
    for iTest=1:3
        
        % get observed and null t-values
        theseNullValues  = sort(squeeze(tValsNull(iCond,iTest,:)),1,'descend');
        thisObsValue = tValsObs(iCond,iTest);
        
        % compare obs to null dist
        [~,tStatIdx] = min(abs(theseNullValues - thisObsValue));
        
        % sig or not?
        if tStatIdx<25 || tStatIdx>975
            sigVec(iCond,iTest) = 1;
        else
            sigVec(iCond,iTest) = 0;
        end
        
    end
end




allCardioStats.sigVec = sigVec;
allCardioStats.ANOVA = allANOVA;


clear sigVec tStatIdx tValsNull tValsObs allANOVA var1 var2 varInt


% save data
if plotBlCorrectedPhysio==1
    save([destDir '/' 'STATS_Physio_Resampled_Within_Analysis' thisTitle1 '.mat'],'allCardioStats','subjects','all_physio_deltas')
else
    save([destDir '/' 'STATS_Physio_Resampled_Within_Analysis_' thisTitle1 '.mat'],'allCardioStats','subjects','all_physio_deltas')
end

return
