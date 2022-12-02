function EEG_TFA_Stats_Resample_ERSP_Anticipatory(iFreq)

%{
EEG_TFA_Stats_Resample_ERSP_Anticipatory
Author: Tom Bullock
Date: 05.17.20 (updated 12.02.22)

Note:run stats on baseline uncorrected data only (anticipatory data
analysis)

%}

% set dirs
parentDir = '/home/bullock/BOSS/CPT_Adaptation';
sourceDir = [parentDir '/' 'Data_Compiled'];

% load data
load([sourceDir '/' 'GRAND_ERSP_1-30Hz_ICA_ICLabel_Dipfit_50HzLP_NoBlCorr.mat'])

% rename var
ersp=erspAll;

% seelct frequency band for processing
disp(['Processing Freq Band Idx: ' num2str(iFreq)]) 
if iFreq==1
    theseFreqs = 1:3;
    thisFreqName = 'Delta';
elseif iFreq==2
    theseFreqs = 4:7;
    thisFreqName = 'Theta';
elseif iFreq==3
    theseFreqs = 8:14;
    thisFreqName = 'Alpha';
elseif iFreq==4
    theseFreqs = 15:30;
    thisFreqName = 'Beta';
end

% compute resampled stats

% ANOVA

% add resample toolbox
addpath(genpath('/home/bullock/BOSS/CPT_Adaptation/resampling'))

% name variables
var1_name = 'cond';
var1_levels = 2;
var2_name = 'trial';
var2_levels = 5;

clear condVec trialVec intVec

% set timepoints to average over and include in analysis
iTimes=1;
theseTimes=1:39; % times (s) to average over

% loop through all channels
for iChan=1:63
    
    iChan
    
    % isolate data
    observedData = [squeeze(mean(mean(ersp(:,1,:,iChan,theseFreqs,theseTimes),5),6)),squeeze(mean(mean(ersp(:,2,:,iChan,theseFreqs,theseTimes),5),6))];
    
    % run ANOVA
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
    allANOVA(iFreq,iChan,iTimes).var1 = var1;
    allANOVA(iFreq,iChan,iTimes).var2 = var2;
    allANOVA(iFreq,iChan,iTimes).varInt = varInt;
    
    clear nullData
    
end

% save data
save([sourceDir '/' 'STATS_WITHIN_Resampled_ERSP_ANOVA_30Hz_NewBL_BASE_ONLY_' thisFreqName '.mat'],'allANOVA')

end