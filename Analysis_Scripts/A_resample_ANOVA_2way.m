% Function: do a RM ANOVA with 2 vars
% Input: need to have .mat file containing the observed data in an sjs x
% conditions matrix called "observedData"

clear all
close all

%set working dir
cd = '/Users/tombullock1/Documents/Psychology/Calgary_Data/Paper/Stats/Resampled_Stats_All';

% seed rng
rng('shuffle')

% original datafile (without .mat extension)
dataFile = 'IMPEDANCE_VALUES_START_FINISH_CHAN_REJ';

% name variables
var1_name = 'startEnd';
var1_levels = 2;
var2_name = 'exerciseCond';
var2_levels = 3;

% load stuff
load([dataFile '.mat'])

% % remove any existing dir and make a new directory for the plots
% if exist([dataFile '_PLOTS'])==7
%     rmdir([dataFile '_PLOTS']);
% end
mkdir([dataFile '_PLOTS']);


% iterate 1000 times for resampling stats
for j=1:1000
    
    for i=1:size(observedData,1)    % for each row of the observed data
        
        thisPerm = randperm(size(observedData,2)); % shuffle colums for each row
        
        for k=1:length(thisPerm)
            
            nullDataMat(i,k,j) = observedData(i,thisPerm(k));
            
% 
%             nullDataMat(i,1,j) = observedData(i,thisPerm(1));
%             nullDataMat(i,2,j) = observedData(i,thisPerm(2));
%             nullDataMat(i,3,j) = observedData(i,thisPerm(3));
        
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

clear statOutput

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



% plots histogram of null F-values (VAR1, VAR2, VAR INTERACTION)
h1=figure;
[N X] = hist(var1.fValsNull,100);    % get histogram values
hist(var1.fValsNull,100);    % plot histogram
line(var1.fValObserved,0:max(N),'Color','r','LineWidth',4)  % plot observed value in RED
line(var1.fValsNull(50),0:max(N),'Color','g','LineWidth',4) % plot critical F in GREEN
text(var1.fValObserved,max(N)-5,['obs=' num2str(var1.fValObserved) '   pValue=' num2str(var1.fValueIndex) ]);
text(var1.fValsNull(50),max(N)-10,['crit=' num2str(var1.fValsNull(50)) '   pValue=.05']);
title(var1_name);

saveas(h1,[dataFile '_PLOTS' '/' 'VAR_1.fig'],'fig');

% plots histogram of null F-values (VAR1, VAR2, VAR INTERACTION)
h2=figure;
[N X] = hist(var2.fValsNull,100);    % get histogram values
hist(var2.fValsNull,100);    % plot histogram
line(var2.fValObserved,0:max(N),'Color','r','LineWidth',4)  % plot observed value in RED
line(var2.fValsNull(50),0:max(N),'Color','g','LineWidth',4) % plot critical F in GREEN
text(var2.fValObserved,max(N)-5,['obs=' num2str(var2.fValObserved) '   pValue=' num2str(var2.fValueIndex) ]);
text(var2.fValsNull(50),max(N)-10,['crit=' num2str(var2.fValsNull(50)) '   pValue=.05']);
title(var2_name);

saveas(h2,[dataFile '_PLOTS' '/' 'VAR_2.fig'],'fig');

% plots histogram of null F-values (VAR1, VAR2, VAR INTERACTION)
h3=figure;
[N X] = hist(varInt.fValsNull,100);    % get histogram values
hist(varInt.fValsNull,100);    % plot histogram
line(varInt.fValObserved,0:max(N),'Color','r','LineWidth',4)  % plot observed value in RED
line(varInt.fValsNull(50),0:max(N),'Color','g','LineWidth',4) % plot critical F in GREEN
text(varInt.fValObserved,max(N)-5,['obs=' num2str(varInt.fValObserved) '   pValue=' num2str(varInt.fValueIndex) ]);
text(varInt.fValsNull(50),max(N)-10,['crit=' num2str(varInt.fValsNull(50)) '   pValue=.05']);
title([var1_name ' BY ' var2_name]);

saveas(h3,[dataFile '_PLOTS' '/' 'VAR_INT.fig'],'fig');






% do t-tests on observed data
[H,P,CI,STATS] = ttest(observedData(:,1),observedData(:,2)); 
tValsObs(1,1) = STATS.tstat;
clear STATS

[H,P,CI,STATS] = ttest(observedData(:,1),observedData(:,3)); 
tValsObs(1,2) = STATS.tstat;
clear STATS



[H,P,CI,STATS] = ttest(observedData(:,1),observedData(:,4)); 
tValsObs(1,3) = STATS.tstat;
clear STATS

[H,P,CI,STATS] = ttest(observedData(:,2),observedData(:,3)); 
tValsObs(1,4) = STATS.tstat;
clear STATS

[H,P,CI,STATS] = ttest(observedData(:,2),observedData(:,4)); 
tValsObs(1,5) = STATS.tstat;
clear STATS

[H,P,CI,STATS] = ttest(observedData(:,3),observedData(:,4)); 
tValsObs(1,6) = STATS.tstat;
clear STATS

[H,P,CI,STATS] = ttest(observedData(:,5),observedData(:,6)); 
tValsObs(1,7) = STATS.tstat;
clear STATS

[H,P,CI,STATS] = ttest(observedData(:,5),observedData(:,7)); 
tValsObs(1,8) = STATS.tstat;
clear STATS

[H,P,CI,STATS] = ttest(observedData(:,5),observedData(:,8)); 
tValsObs(1,9) = STATS.tstat;
clear STATS

[H,P,CI,STATS] = ttest(observedData(:,6),observedData(:,7)); 
tValsObs(1,10) = STATS.tstat;
clear STATS

[H,P,CI,STATS] = ttest(observedData(:,6),observedData(:,8)); 
tValsObs(1,11) = STATS.tstat;
clear STATS

[H,P,CI,STATS] = ttest(observedData(:,7),observedData(:,8)); 
tValsObs(1,12) = STATS.tstat;
clear STATS




% sort null f-values, get index value and convert to percentile
tValsNull = sort(tValsNull(:,1),1,'descend');

% compare observed t values with the distribution of null t values
[c tValueIndex(1)] = min(abs(tValsNull - tValsObs(1,1))); 
[c tValueIndex(2)] = min(abs(tValsNull - tValsObs(1,2)));
[c tValueIndex(3)] = min(abs(tValsNull - tValsObs(1,3)));
[c tValueIndex(4)] = min(abs(tValsNull - tValsObs(1,4))); 
[c tValueIndex(5)] = min(abs(tValsNull - tValsObs(1,5)));
[c tValueIndex(6)] = min(abs(tValsNull - tValsObs(1,6)));
[c tValueIndex(7)] = min(abs(tValsNull - tValsObs(1,7))); 
[c tValueIndex(8)] = min(abs(tValsNull - tValsObs(1,8)));
[c tValueIndex(9)] = min(abs(tValsNull - tValsObs(1,9)));
[c tValueIndex(10)] = min(abs(tValsNull - tValsObs(1,10))); 
[c tValueIndex(11)] = min(abs(tValsNull - tValsObs(1,11)));
[c tValueIndex(12)] = min(abs(tValsNull - tValsObs(1,12)));

% convert to percentiles
tValueIndex = tValueIndex./1000;
pValuesPairwise = tValueIndex;

% add pnull values to tValsObs for easy viewing
tValsObs(2,:) = pValuesPairwise;

% critical t score
tCriticalNeg = tValsNull(25);
tCriticalPos = tValsNull(975);



% save important stats info
save([dataFile '_STATS.mat'],'var1', 'var2','varInt','observedData','nullDataMat','pValuesPairwise','tValsObs');


% plots histogram of null t-values (JUST THE CRITICAL VALUES, NOT THE REAL
% ONES - TOO MANY)
h4=figure;
[N X] = hist(tValsNull,100);    % get histogram values
hist(tValsNull,100);    % plot histogram
line(tValsNull(25),0:max(N),'Color','g','LineWidth',4) % plot negative critical t values in GREEN
line(tValsNull(975),0:max(N),'Color','g','LineWidth',4) % plot positive critical t values in GREEN

text(tValsNull(25),max(N)+5,['crit=' num2str(tValsNull(25)) '   pValue=.025']);
text(tValsNull(975),max(N)+5,['crit=' num2str(tValsNull(975)) '   pValue=.025']);

saveas(h4,[dataFile '_PLOTS' '/' 'CRITICAL_T_NULL_DIST.fig'],'fig');

% line(tValsObs(1),0:max(N),'Color','r','LineWidth',4)  % plot first pairwise comparison observed t-value in RED
% line(tValsObs(2),0:max(N),'Color','m','LineWidth',4)  % plot second pairwise comparison observed t-value in MAGENTA
% line(tValsObs(3),0:max(N),'Color','c','LineWidth',4)  % plot third pairwise comparison observed t-value in CYAN
% 
% % text(tValsObs(1),max(N)+1,['obs=' num2str(tValsObs(1)) '   pValue=' num2str(tValueIndex(1)) ]);
% % text(tValsObs(2),max(N)+2,['obs=' num2str(tValsObs(2)) '   pValue=' num2str(tValueIndex(2)) ]);
% % text(tValsObs(3),max(N)+3,['obs=' num2str(tValsObs(3)) '   pValue=' num2str(tValueIndex(3)) ]);
% % 
% 








