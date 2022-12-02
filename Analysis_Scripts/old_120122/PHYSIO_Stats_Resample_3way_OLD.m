%{
Physio_Plot_Individuals
Author: Tom Bullock, UCSB Attention Lab
Date: 06.01.19

Plot individual data together for QC/outlier assessment.
Plot mean data for each measure automatically omitting subs with missing
measures (e.g. BP).

Note: if plotting shaded error bars, need to do this in stages OR matlab
crashes

NEED TO RERUN FOR T-TESTS!?!
%}

function Physio_Stats_Resample_3way(plotBlCorrectedPhysio,iMeasure) % 0 or 1

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

%% RUN 5 x 2 ANOVAs

% add resample toolbox path
addpath(genpath('/home/bullock/BOSS/CPT_Adaptation/resampling'))

% name variables
var1_name = 'baseline';
var1_levels = 2;
var2_name = 'cond';
var2_levels = 2;
var3_name = 'trial';
var3_levels = 5;

% do real ANOVA
for t=1:size(allPhysio,4)-15 %--15 coz doing avg of 15 secs across both bl and CPT periods
    disp(t)
    
    % create observed data matrix
    clear observedData
    %observedData = [allPhysio(:,:,1,t),allPhysio(:,:,2,t)];
    observedData = [...
        nanmean(allPhysio(:,:,1,26:40),4),...
        nanmean(allPhysio(:,:,2,26:40),4),...
        nanmean(allPhysio(:,:,1,t:t+14),4),...
        nanmean(allPhysio(:,:,2,t:t+14),4)...
        ];
    
    
    % run ANOVA on REAL data
    clear statOutput
    statOutput = teg_repeated_measures_ANOVA(observedData,[var1_levels, var2_levels, var3_levels],{var1_name, var2_name var3_name});
    
    % create vectors of main and int F values [note names are not really
    % correct any more]
    var1.fValObserved = statOutput(1,1); 
    var2.fValObserved = statOutput(2,1); 
    var3.fValObserved = statOutput(3,1); 
    var4.fValObserved = statOutput(4,1); 
    var5.fValObserved = statOutput(5,1); 
    var6.fValObserved = statOutput(6,1); 
    var7.fValObserved = statOutput(7,1); 
    
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
        statOutput = teg_repeated_measures_ANOVA(nullData(:,:,j),[var1_levels, var2_levels, var3_levels],{var1_name, var2_name var3_name});
        
        var1.fValsNull(j,1) = statOutput(1,1);
        var2.fValsNull(j,1) = statOutput(2,1);
        var3.fValsNull(j,1) = statOutput(3,1);
        var4.fValsNull(j,1) = statOutput(4,1);
        var5.fValsNull(j,1) = statOutput(5,1);
        var6.fValsNull(j,1) = statOutput(6,1);
        var7.fValsNull(j,1) = statOutput(7,1);
        
    end
    
    
    % sort null f-values, get index value and convert to percentile (VAR_1)
    var1.NAME = 'base';
    var1.df = statOutput(1,2:3);
    var1.fValsNull = sort(var1.fValsNull(:,1),1,'descend');
    [c var1.fValueIndex] = min(abs(var1.fValsNull - var1.fValObserved));
    var1.fValueIndex = var1.fValueIndex/1000;
    var1.pValueANOVA = var1.fValueIndex;
    
    % sort null f-values, get index value and convert to percentile (VAR_2)
    var2.NAME = 'cond';
    var2.df = statOutput(2,2:3);
    var2.fValsNull = sort(var2.fValsNull(:,1),1,'descend');
    [c var2.fValueIndex] = min(abs(var2.fValsNull - var2.fValObserved));
    var2.fValueIndex = var2.fValueIndex/1000;
    var2.pValueANOVA = var2.fValueIndex;
    
    % sort null f-values, get index value and convert to percentile (VAR_2)
    var3.NAME = 'trial';
    var3.LEVELS = statOutput(3,2:3);
    var3.fValsNull = sort(var3.fValsNull(:,1),1,'descend');
    [c var3.fValueIndex] = min(abs(var3.fValsNull - var3.fValObserved));
    var3.fValueIndex = var3.fValueIndex/1000;
    var3.pValueANOVA = var3.fValueIndex;
    
    % sort null f-values, get index value and convert to percentile (VAR_2)
    var4.NAME = 'base x cond';
    var4.LEVELS = statOutput(4,2:3);
    var4.fValsNull = sort(var4.fValsNull(:,1),1,'descend');
    [c var4.fValueIndex] = min(abs(var4.fValsNull - var4.fValObserved));
    var4.fValueIndex = var4.fValueIndex/1000;
    var4.pValueANOVA = var4.fValueIndex;
    
    % sort null f-values, get index value and convert to percentile (VAR_2)
    var5.NAME = 'base x trial';
    var5.LEVELS = statOutput(5,2:3);
    var5.fValsNull = sort(var5.fValsNull(:,1),1,'descend');
    [c var5.fValueIndex] = min(abs(var5.fValsNull - var5.fValObserved));
    var5.fValueIndex = var5.fValueIndex/1000;
    var5.pValueANOVA = var5.fValueIndex;
    
    % sort null f-values, get index value and convert to percentile (VAR_2)
    var6.NAME = 'cond x trial';
    var6.LEVELS = statOutput(6,2:3);
    var6.fValsNull = sort(var6.fValsNull(:,1),1,'descend');
    [c var6.fValueIndex] = min(abs(var6.fValsNull - var6.fValObserved));
    var6.fValueIndex = var6.fValueIndex/1000;
    var6.pValueANOVA = var6.fValueIndex;
    
    % sort null f-values, get index value and convert to percentile (VAR_2)
    var7.NAME = 'base x cond x trial';
    var7.LEVELS = statOutput(7,2:3);
    var7.fValsNull = sort(var7.fValsNull(:,1),1,'descend');
    [c var7.fValueIndex] = min(abs(var7.fValsNull - var7.fValObserved));
    var7.fValueIndex = var7.fValueIndex/1000;
    var7.pValueANOVA = var7.fValueIndex;
    
   
    % add to time struct
    allANOVA(t).var1 = var1;
    allANOVA(t).var2 = var2;
    allANOVA(t).var3 = var3;
    allANOVA(t).var4 = var4;
    allANOVA(t).var5 = var5;
    allANOVA(t).var6 = var6;
    allANOVA(t).var7 = var7;
    
    clear nullData
    
end



% RUN PAIRWISE T-TESTS (T1vsT5, T1vsT3,T3vsT5)

for t=1:size(allPhysio,4) 
        
    % create observed data matrix
    clear observedData
    observedData = [allPhysio(:,:,1,t),allPhysio(:,:,2,t)];
    
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
                sigVec(iCond,iTest,t) = 1;
            else
                sigVec(iCond,iTest,t) = 0;
            end
            
        end
    end
    
end

allCardioStats.sigVec = sigVec;
allCardioStats.ANOVA = allANOVA;

clear sigVec tStatIdx tValsNull tValsObs allANOVA var1 var2 varInt

% save data
if plotBlCorrectedPhysio==1
    save([destDir '/' 'STATS_Physio_Resampled_Bl_Corrected_3way_' thisTitle1 '.mat'],'allCardioStats','subjects')
else
    save([destDir '/' 'STATS_Physio_Resampled_Uncorrected_3way_' thisTitle1 '.mat'],'allCardioStats','subjects')
end

return
