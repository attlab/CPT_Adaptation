function EEG_Clean_For_ICA(subject,session,analysisType)
%{
EEG_Clean_For_ICA
Author:Tom (borrowed some from Neil + Jordan ICA scripts, probably)
Date: 12.01.22

%}

% set dirs
Parent_dir = '/home/bullock/BOSS/CPT_Adaptation/';
scriptsDir = [Parent_dir 'Analysis_Scripts'];
%eeglabDir = '/home/bullock/matlab_2016b/TOOLBOXES/eeglab14_1_1b';
eeglabDir = '/home/bullock/Toolboxes/eeglab2019_1'; 
EEGraw_dir = [Parent_dir 'EEG_CPT_Prepro/'];

% select analysis type
if analysisType==1
    %EEG_clean = [Parent_dir 'EEG_Processed_Cleaned_For_ICA'];
    EEG_clean = '/home/bullock/BOSS/CPT_Adaptation/EEG_RERUN/EEG_Processed_Cleaned_For_ICA'; % TOM TEMP OVERRIDE CHECK EEG
else
    EEG_clean = [Parent_dir 'EEG_Processed_Cleaned_No_Downsample'];
end
taskOrder = [Parent_dir 'Data_Compiled/'];
addpath(genpath(scriptsDir))

% add eeglab to path
cd(eeglabDir)
eeglab
close all
cd(scriptsDir)


% load data for all 5 trials and merge into a single file
load([taskOrder 'Task_Order.mat']);
rowIndex = find(taskOrderStruct.sjNums==subject);
thisTemporalTaskOrder = squeeze(taskOrderStruct.allTaskOrder(rowIndex,session,:));
for iTask=1:5
    load([EEGraw_dir '/' sprintf('sj%d_se%02d_%s.mat',subject,session+1,thisTemporalTaskOrder{iTask+1}) ])
    EEG = pop_epoch(EEG,{2},[-.1,195.1]); % epoch here on single trial to get rid of any noisy data outside of CPT protocol 
    if iTask==1
        EEGO=EEG;
    else
        EEGO=pop_mergeset(EEGO,EEG);
    end
end
EEG=EEGO;
clear EEGO


% apply filter(s) + option to downsample
if analysisType==1
    EEG = my_fxtrap(EEG,1,50,.1,0,0,250); %hp,lp,transition,rectif,smooth, resample 
else
    EEG = my_fxtrap(EEG,1,0,.1,0,0,0); %hp,lp,transition,rectif,smooth, resamp
end

% edit channel location info 
EEG=pop_chanedit(EEG, 'lookup','/home/bullock/matlab_2016b/TOOLBOXES/eeglab14_1_1b/plugins/dipfit2.3/standard_BESA/standard-10-5-cap385.elp');

% remove EKG channel if present
EEG = pop_select(EEG,'nochannel',{'ECG'});

% remove line noise using notch filter
if analysisType==1
    EEG = my_fxcomb(EEG,[60],1,.3,0,0,0,0); % notch filter alternative
end

% create orig EEG variable
originalEEG = EEG;

% reject channels etc.
EEG = clean_artifacts(EEG,...
    'channelCriterion',.85,...
    'LineNoiseCriterion',4,...
    'BurstCriterion','off',...
    'FlatLineCriterion',5,...
    'WindowCriterion','off',...
    'WindowCriterionTolerances','off');

% % visualize original vs. cleaned data (reality check)
% vis_artifacts(EEG,originalEEG)

% save original channel locations for later
EEG.original_chanlocs = originalEEG.chanlocs;  

% re-reference to (clean) average reference
EEG = pop_reref(EEG,[]);

% create list of bad channels and interpolate
bad_channels = setdiff({EEG.original_chanlocs.labels},{EEG.chanlocs.labels});
bad_channel_list = {};
bad_channel_list = unique(cat(2,bad_channel_list,bad_channels));
EEG = pop_interp(EEG,EEG.original_chanlocs, 'spherical');

% save data 
save([EEG_clean '/' sprintf('sj%d_se%02d_clean.mat',subject,session+1)],'EEG','bad_channel_list')

return