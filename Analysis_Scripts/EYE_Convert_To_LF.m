%{
EYE_Convert_To_LF
Author: Tom Bullock
Date: 04.18.20
%}

clear
close all

%% set dirs
sourceDir = '/home/bullock/BOSS/CPT_Adaptation/Data_Compiled';
destDir = '/home/bullock/BOSS/CPT_Adaptation/Data_Compiled/LF_DATA';

%% load compiled EYE Data (paMatAll = sub,session,task,eye,timepoint)
load([sourceDir '/' '/CPT_EYE_Master.mat'])

%% baseline correction [Note that Event times are 1,20000,32500,77500,97500]
baselineCorrect=1;

%% load resampled stats
if baselineCorrect==0
    load([sourceDir '/' 'STATS_Resampled_EYE_n21_raw.mat'],'sigVec')
    dataType = 'raw';
else
    load([sourceDir '/' 'STATS_Resampled_EYE_n21_bln.mat'],'sigVec')
    dataType = 'bln';
end

% remove bad subjects
badSubs = [103,105,108,109,115,116,117,118,126,128,135,136,138,139,140,146,147,148,154,157,158,159];
[a,b] = setdiff(subjects,badSubs);
theseSubjects = a;
paMatAll = paMatAll(b,:,:,:,:);


        
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

%% plot settings
theseYlims = [-.2,1];

%% normalize between -1 and 1
maxPA = squeeze(max(max(max(max(nanmean(paMatAll,1))))));
minPA = squeeze(min(min(min(min(nanmean(paMatAll,1))))));
theseData = (paMatAll-minPA)/(maxPA-minPA);


%% convert to LF

for i=1:size(theseData,3) % trial loop
    for j=1:size(theseData,2) % session loop
        for k=1:size(theseData,5) % time loop
            
            k
            
            thisSample = squeeze(nanmean(theseData(:,j,i,:,k),4));
            
            
            dumTrial = repmat(i,[length(theseSubjects),1]);
            dumSession = repmat(j,[length(theseSubjects),1]);
            dumTime = repmat(k,[length(theseSubjects),1]);
            
            if i==1 && j==1 && k==1
                theseDataLF(1:length(theseSubjects),1:5) = [theseSubjects',dumSession,dumTrial,dumTime,thisSample];
            else
                m = size(theseDataLF,1);
                n = size(theseData,1);
                theseDataLF(m+1:m+n,1:5) = [theseSubjects',dumSession,dumTrial,dumTime,thisSample];
            end
            
        end
    end
end

% write LF data to csv
csvwrite([destDir '/' 'EYE_' dataType '_LF.csv'],theseDataLF)

clear 