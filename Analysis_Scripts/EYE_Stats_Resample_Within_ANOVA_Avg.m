%{
EYE_Stats_Resample_Within_ANOVA_Avg
Author: Tom Bullock, UCSB Attention Lab
Date: 06.06.20

Run resampled ANOVA on average response period.

%}

baselineCorrect=1;

%clear
%close all

%% set dirs
sourceDir = '/home/bullock/BOSS/CPT_Adaptation/Data_Compiled';

%% load compiled EYE Data (paMatAll = sub,session,task,eye,timepoint)
load([sourceDir '/' '/CPT_EYE_Master.mat'])

% remove bad subjects
%badSubs = [103,105,108,109,115,116,117,118,128,136,138,140,146,147,148,154,157,158];
badSubs = [103,105,108,109,115,116,117,118,126,128,135,136,138,139,140,146,147,148,154,157,158,159];

[a,b] = setdiff(subjects,badSubs);
paMatAll = paMatAll(b,:,:,:,:);
 
%% baseline correction [Note that Event times are 1,20000,32500,77500,97500]
%baselineCorrect=1;
theseXlims=[0,195];
theseXticks=[0,40,65,155,195];

if baselineCorrect==1
    paMatBL= nanmean(paMatAll(:,:,:,:,round(26000/2):round(40000/2)),5);
    paMatAll = paMatAll - paMatBL;
end

%% downsample to 1Hz [average across each second (500Hz original SR)]
for i=1:195
    paMattAll_DS(:,:,:,:,i) = nanmean(paMatAll(:,:,:,:,((i*500)+1:(i+1)*500)-500),5);
end
paMatAll = paMattAll_DS;

%% normalize between -1 and 1
maxPA = squeeze(max(max(max(max(nanmean(paMatAll,1))))));
minPA = squeeze(min(min(min(min(nanmean(paMatAll,1))))));
paMatAll = (paMatAll-minPA)/(maxPA-minPA);


%% DO REAL ANOVA

% add resample toolbox path
addpath(genpath('/home/bullock/BOSS/CPT_Adaptation/resampling'))

% name variables
var1_name = 'cond';
var1_levels = 2;
var2_name = 'trial';
var2_levels = 5;

% do real ANOVA

% create observed data matrix
clear observedData
observedData = [squeeze(nanmean(nanmean(paMatAll(:,1,:,:,66:155),4),5)),squeeze(nanmean(nanmean(paMatAll(:,2,:,:,6:155),4),5))];

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
%observedData = [squeeze(nanmean(paMatAll(:,1,:,:,t),4)),squeeze(nanmean(paMatAll(:,2,:,:,t),4))];
observedData = [squeeze(nanmean(nanmean(paMatAll(:,1,:,:,66:155),4),5)),squeeze(nanmean(nanmean(paMatAll(:,2,:,:,6:155),4),5))];


% do real pairwise tests for each session separately
[~,pVal,~,STATS] = ttest(observedData(:,1),observedData(:,5)); % tx T1vsT5
tValsObs(1,1) = STATS.tstat;
pValsObsParametric(1,1) = pVal;

[~,pVal,~,STATS] = ttest(observedData(:,1),observedData(:,3)); % tx T1vsT3
tValsObs(1,2) = STATS.tstat;
pValsObsParametric(1,2) = pVal;

[~,pVal,~,STATS] = ttest(observedData(:,3),observedData(:,5)); % tx T3vsT5
tValsObs(1,3) = STATS.tstat;
pValsObsParametric(1,3) = pVal;

[~,pVal,~,STATS] = ttest(observedData(:,6),observedData(:,10)); % tx T1vsT5
tValsObs(2,1) = STATS.tstat;
pValsObsParametric(2,1) = pVal;

[~,pVal,~,STATS] = ttest(observedData(:,6),observedData(:,8)); % tx T1vsT3
tValsObs(2,2) = STATS.tstat;
pValsObsParametric(2,2) = pVal;

[~,pVal,~,STATS] = ttest(observedData(:,8),observedData(:,10)); % tx T3vsT5
tValsObs(2,3) = STATS.tstat;
pValsObsParametric(2,3) = pVal;


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
        
        %%all_tStats(iCond,iTest) = tStatIdx;
        
        % sig or not?
        if tStatIdx<25 || tStatIdx>975
            sigMat(iCond,iTest) = 1;
            tStatIdx_all(iCond,iTest) = tStatIdx;
        else
            sigMat(iCond,iTest) = 0;
            tStatIdx_all(iCond,iTest) = tStatIdx;
        end
        
    end
end


%% save results in struct
allPupilStats.tStatIdx = tStatIdx_all;
allPupilStats.tValsSigMat = sigMat;
allPupilStats.tValsObs = tValsObs;
allPupilStats.ANOVA = allANOVA;
allPupilStats.pValsObsParametric = pValsObsParametric;

% save data
if baselineCorrect==0
    %save([sourceDir '/' 'STATS_WITHIN_Resampled_EYE_n21_raw_.mat'],'allPupilStats','subjects','badSubs')
else
    save([sourceDir '/' 'STATS_WITHIN_Resampled_EYE_n21_bln_Avg_Immersion.mat'],'allPupilStats','subjects','badSubs')
end

