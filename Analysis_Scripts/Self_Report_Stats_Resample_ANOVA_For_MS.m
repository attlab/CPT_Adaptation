%{
Self_Report_Stats_Resample_ANOVA_For_MS
Author: Tom Bullock
Date: 05.31.20

%}

clear
close all

%% set dirs
sourceDir = '/home/bullock/BOSS/CPT_Adaptation/Data_Compiled';

addpath(genpath('/home/bullock/BOSS/CPT_Adaptation/resampling'))

%% choose subjects
[~,mySubjects] = CPT_SUBJECTS;

%% remove sj102
mySubjects(1)=[];

%% load self-report data
load([sourceDir '/' 'Self_Report.mat'])

%% isolate subjects
allPain = allPain(mySubjects-100,:,:);

%% rearrange data mat for ANOVA
observedData = [squeeze(allPain(:,1,:)),squeeze(allPain(:,2,:))];

observedData([2,4,5,8,37],:) = [];



% name variables
var1_name = 'tx/ct';
var1_levels = 2;
var2_name = 'trial';
var2_levels = 5;

% run ANOVA (iterate 1000 times)
for j=1:1000
    j
    for i=1:size(observedData,1)    % for each row of the observed data
       
        thisPerm = randperm(size(observedData,2)); % shuffle colums for each row
        
        for k=1:length(thisPerm)
            
            nullDataMat(i,k,j) = observedData(i,thisPerm(k));
  
        end
        
    end
    
    % do ANOVA on permuted data for each new iteration
    statOutput = teg_repeated_measures_ANOVA(nullDataMat(:,:,j),[var1_levels var2_levels],{var1_name, var2_name});  % do ANOVA
    var1.fValsNull(j,1) = statOutput(1,1);   % create column vector of null F-values
    var2.fValsNull(j,1) = statOutput(2,1);
    varInt.fValsNull(j,1) = statOutput(3,1);
    
    clear statOutput
    
    % get post-hoc null t value distribution (only makes sense to create
    % one null distribution for all combinations of tests, given within
    % subjects column shuffling method)
    [H,P,CI,STATS] = ttest(nullDataMat(:,1,j),nullDataMat(:,2,j)); 
    tValsNull(j,1) = STATS.tstat;
    clear STATS
    
end


%%DO THIS FOR BOTH MAIN EFFECTS AND INTERACTION (JUST CHANGE THE VALUE FROM
%%STAT OUTPUT>

% do ANOVA on observed data
statOutput = teg_repeated_measures_ANOVA(observedData,[var1_levels var2_levels],{var1_name, var2_name});
var1.fValObserved = statOutput(1,1);   % exercise
var2.fValObserved = statOutput(2,1);
varInt.fValObserved = statOutput(3,1);

%clear statOutput

% sort null f-values, get index value and convert to percentile (VAR_1)
var1.NAME = var1_name;
var1.LEVELS = var1_levels;
var1.fValsNull = sort(var1.fValsNull(:,1),1,'descend');
[c var1.fValueIndex] = min(abs(var1.fValsNull - var1.fValObserved)); 
var1.fValueIndex = var1.fValueIndex/1000;
var1.pValueANOVA = var1.fValueIndex;
var1.eta_p2 = statOutput(1,6);
var1.df = statOutput(1,[2,3]);

% sort null f-values, get index value and convert to percentile (VAR_2)
var2.NAME = var2_name;
var2.LEVELS = var2_levels;
var2.fValsNull = sort(var2.fValsNull(:,1),1,'descend');
[c var2.fValueIndex] = min(abs(var2.fValsNull - var2.fValObserved)); 
var2.fValueIndex = var2.fValueIndex/1000;
var2.pValueANOVA = var2.fValueIndex;
var2.eta_p2 = statOutput(2,6);
var2.df = statOutput(2,[2,3]);


% sort null f-values, get index value and convert to percentile (VAR INTER)
varInt.NAME = 'INTERACTION';
varInt.LEVELS = [num2str(var1_levels) '-by-' num2str(var2_levels)];
varInt.fValsNull = sort(varInt.fValsNull(:,1),1,'descend');
[c varInt.fValueIndex] = min(abs(varInt.fValsNull - varInt.fValObserved)); 
varInt.fValueIndex = varInt.fValueIndex/1000;
varInt.pValueANOVA = varInt.fValueIndex;
varInt.eta_p2 = statOutput(3,6);
varInt.df = statOutput(3,[2,3]);


%% do t-tests (do same combos as per physio)
clear nullDataMat 
for iTest=1:3
    
    clear tValsNull

   if       iTest==1; thisPair = observedData(:,[1,5]);
   elseif   iTest==2; thisPair = observedData(:,[1,3]);
   elseif   iTest==3; thisPair = observedData(:,[3,5]);
%    elseif   iTest==4; thisPair = observedData(:,[6,10]);
%    elseif   iTest==5; thisPair = observedData(:,[6,8]);
%    elseif   iTest==6; thisPair = observedData(:,[8,10]);
   end
    
   [~,p,~,stats] = ttest(thisPair(:,1),thisPair(:,2)); 
   tValsObs = stats.tstat;
   
%    all_p(iTest) = p;
%    all_stats(iTest) = stats;
   
   
   for i=1:1000
       for m=1:length(thisPair)
           thisPerm = randperm(size(thisPair,2));
           nullDataMat(m,:) = thisPair(m,thisPerm);
       end
       
       [H,P,CI,STATS] = ttest(nullDataMat(:,1),nullDataMat(:,2));
       tValsNull(i) = STATS.tstat;
       clear STATS nullDataMat 
   end
   
   thisNullDist = sort(tValsNull,2,'descend');
   [~,idx] = min(abs(thisNullDist - tValsObs));
   tStatIdx(iTest) = idx;
   clear thisNullDist  idx
   
   
end
    
    

% save important stats info
save([sourceDir '/' 'STATS_Self_Report_Resample_ANOVA.mat'],'var1', 'var2','varInt','observedData','nullDataMat','statOutput','tStatIdx');

