%{
Self_Report_Stats_Resample_Within_Cond

Author: Tom Bullock, UCSB Attention Lab
Date: 12.21.19

Does comparisions between T1/T2, T2/T3 etc.

%}

clear
close all

%% set dirs
sourceDir = '/home/bullock/BOSS/CPT_Adaptation/Data_Compiled';

%% choose subjects
[~,mySubjects] = CPT_SUBJECTS;

%% remove sj102
mySubjects(1)=[];

%% load self-report data
load([sourceDir '/' 'Self_Report.mat'])

%% isolate subjects
allPain = allPain(mySubjects-100,:,:)

%% null loop (compare Tx and Ct)
for i=1:1000 % iteration loop
    
    for j=1:2 % cpt/wpt loop (becuase comparing within conditions)
        for k=1:5 % exposure loop
            
            if      k==1; a=1;b=2;
            elseif  k==2; a=2;b=3;
            elseif  k==3; a=3;b=4;
            elseif  k==4; a=4;b=5;
            elseif  k==5; a=1;b=5;
            end
            
            observedData = squeeze(allPain(:,j,[a,b]));
            
            for m=1:length(observedData)
                thisPerm = randperm(size(observedData,2));
                nullDataMat(m,:) = observedData(m,thisPerm);
            end
            
            [H,P,CI,STATS] = ttest(nullDataMat(:,1),nullDataMat(:,2));
            tValsNull(i,j,k) = STATS.tstat;
            clear STATS nullDataMat observedData
            
        end
    end
end

%% null loop (compare Tx and Ct)
for j=1:2 % cpt/wpt loop (becuase comparing within conditions)
    for k=1:5 % exposure loop
        
        if      k==1; a=1;b=2;
        elseif  k==2; a=2;b=3;
        elseif  k==3; a=3;b=4;
        elseif  k==4; a=4;b=5;
        elseif  k==5; a=1;b=5;
        end
        
        observedData = squeeze(allPain(:,j,[a,b]));
        
        [H,P,CI,STATS] = ttest(observedData(:,1),observedData(:,2));
        tValsObs(j,k) = STATS.tstat;
        clear STATS nullDataMat observedData
        
    end
end


%% compare observed t-test at each trial and timepoint with corresponding null distribution of t-values

for j=1:2 % cpt/wpt
    % trial (exposure) loop
    for k=1:size(tValsNull,3)
        
        thisNullDist = sort(tValsNull(:,j,k),1,'descend');
        [~,idx] = min(abs(thisNullDist - tValsObs(j,k)));
        tStatIdx(j,k) = idx;
        clear thisNullDist  idx
        
    end
end


% convert idx value to probability
%pValuesPairwise = tStatIdx./1000;

% convert idx value to a vector of 0's and 1's (representing significance
% at p<.05)
clear sigVec
for j=1:2 % cpt/wpt
    for k=1:size(tStatIdx,2)
        if tStatIdx(j,k)<25 || tStatIdx(j,k)>975
            sigVec(j,k) = 1;
        else
            sigVec(j,k)=0;
        end
    end
end

% save data
save([sourceDir '/' 'STATS_Resampled_Self_Report_Within_Cond.mat'],'sigVec','tValsObs','tValsNull','mySubjects')