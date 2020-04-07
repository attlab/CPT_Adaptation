function EEG_Clean_For_ICA(subject,session,analysisType)

%{
========================================================================
Neil+Jordan ICA preprocessing pipeline (adapted by Tom Bullock for CPT)

Step 1: High pass filter
Step 2: Clean Data
Step 3: Interpolate, Epoch, & Merge
	
subject = Subject #
filtering = 0 - no, 1 - yes
cleaning = run clean line and clean raw data 0 - no, 1 - yes
epoch = 0 - no, 1 - yes
jobRAM = clean raw data requires that you specifiy the amount of available RAM.
	If running this function on the cluster, takes the RAM specified in job settings.

Notes: currently just running on local machine

=========================================================================
%}

%% set dirs
Parent_dir = '/home/bullock/BOSS/CPT_Adaptation/';
scriptsDir = [Parent_dir 'Analysis_Scripts'];

%eeglabDir = '/home/bullock/matlab_2016b/TOOLBOXES/eeglab14_1_1b';
eeglabDir = '/home/bullock/Toolboxes/eeglab2019_1' 

EEGraw_dir = [Parent_dir 'EEG_CPT_Prepro/'];
if analysisType==1
    EEG_clean = [Parent_dir 'EEG_Processed_Cleaned_For_ICA'];
else
    EEG_clean = [Parent_dir 'EEG_Processed_Cleaned_No_Downsample'];
end
taskOrder = [Parent_dir 'Data_Compiled/'];
addpath(genpath(scriptsDir))

cd(eeglabDir)
eeglab
close all
cd(scriptsDir)

%% load data for all 5 trials and merge into a single file
load([taskOrder 'Task_Order.mat']);
rowIndex = find(taskOrderStruct.sjNums==subject);
thisTemporalTaskOrder = squeeze(taskOrderStruct.allTaskOrder(rowIndex,session,:));
for iTask=1:5
    load([EEGraw_dir '/' sprintf('sj%d_se%02d_%s.mat',subject,session+1,thisTemporalTaskOrder{iTask+1}) ])
    EEG = pop_epoch(EEG,{2},[-.1,195.1]); % epoch here on single trial to get rid of any noisy data outside of CPT protocol (slightly expand)
    if iTask==1
        EEGO=EEG;
    else
        EEGO=pop_mergeset(EEGO,EEG);
    end
end
EEG=EEGO;
clear EEGO

%% high-pass filter + downsample (for main analysis only because don't want to downsample if trying to display 1-500 Hz)
if analysisType==1
    EEG = my_fxtrap(EEG,1,50,.1,0,0,250); %hp,lp,transition,rectif,smooth, resamp 50 HZ LP!!! 
else
    EEG = my_fxtrap(EEG,1,0,.1,0,0,0); %hp,lp,transition,rectif,smooth, resamp
end
%EEG = pop_eegfilt(EEG,1,0); % eeglab filter alternative
%EEG = pop_resample(EEG,250); % eeglab downsample alternative

%% edit channel location info 
EEG=pop_chanedit(EEG, 'lookup','/home/bullock/matlab_2016b/TOOLBOXES/eeglab14_1_1b/plugins/dipfit2.3/standard_BESA/standard-10-5-cap385.elp');

%% remove EKG channel
EEG = pop_select(EEG,'nochannel',{'ECG'});

%% remove line noise using notch filter
if analysisType==1
    EEG = my_fxcomb(EEG,[60],1,.3,0,0,0,0); % notch filter alternative
end

originalEEG = EEG;


% % Apply clean_rawdata() to reject bad channels (turn off highpass, ASR, bad "window" rejection)
% if processInParallel 
%     %EEG = clean_rawdata(EEG,5,-1,.80,4,-1,-1,'WindowCriterionTolerances','off','availableRAM_GB',jobRAM);
%     EEG = clean_rawdata(EEG,5,-1,.80,4,-1,-1,'WindowCriterionTolerances','off');
% else
%     EEG = clean_rawdata(EEG,5,-1,.80,4,-1,-1,'WindowCriterionTolerances','off'); % note corr was orig set to .80
% end

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







% % remove some additional channels that were not detected by the channel rej
% % algorithm (visual inspection)
% if subject==103
%     badChansManual={'P5','P6','TP10'};
% elseif subject== 108
%     badChansManual={'T8'};
% elseif subject==118
%     badChansManual={'T7','TP7','CP5','TP9','FT9'};
% elseif subject==119
%     badChansManual={'P1','AF8','TP10'};
% elseif subject==124
%     badChansManual={'TP7','TP8','FC2'};
% elseif subject==126
%     badChansManual={'FP2','AF8'};
% elseif subject==128
%     badChansManual={'C1','P2'};
% elseif subject==132
%     badChansManual={'F6'};
% elseif subject==133
%     badChansManual={'TP9'};
% elseif subject==136
%     badChansManual={'C1'};
% elseif subject==139
%     badChansManual={'Cz','C1'};
% elseif subject==144
%     badChansManual={'TP9','FT9'};
% elseif subject==147
%     badChansManual={'Fpz','Fp2'};
% elseif subject==154
%     badChansManual={'C1'};
% elseif subject==160
%     badChansManual={'FC1'};
% else
%     badChansManual=[];
% end
% 
% EEG=pop_select(EEG,'nochannel',badChansManual);
% 
% 
% % re-reference to (clean) average reference
% EEG = pop_reref(EEG,[]);
% 
% % create list of bad channels and interpolate
% bad_channels = setdiff({EEG.original_chanlocs.labels},{EEG.chanlocs.labels});
% bad_channel_list = {};
% bad_channel_list = unique(cat(2,bad_channel_list,bad_channels));
% EEG = pop_interp(EEG,EEG.original_chanlocs, 'spherical');
% 
% 
% 
% % % interp  some additional bad channels that were missed by the chan
% % % rejection algorithm
% % if subNum==103
% %     badChans={'P5','P6','TP10'};
% % elseif subNum== 108
% %     badChans={'T8'};
% % elseif subNum==118
% %     badChans={'T7','TP7','CP5','TP9','FT9'};
% % elseif subNum==119
% %     badChans={'P1','AF8','TP10'};
% % elseif subNum==124
% %     badChans={'TP7','TP8','FC2'};
% % elseif subNum==126
% %     badChans={'FP2','AF8'};
% % elseif subNum==128
% %     badChans={'C1','P2'};
% % elseif subNum==132
% %     badChans={'F6'};
% % elseif subNum==133
% %     badChans={'TP9'};
% % elseif subNum==136
% %     badChans={'C1'};
% % elseif subNum==139
% %     badChans={'Cz','C1'};
% % elseif subNum==144
% %     badChans={'TP9','FT9'};
% % elseif subNum==147
% %     badChans={'Fpz','Fp2'};
% % elseif subNum==154
% %     badChans={'C1'};
% % elseif subNum==160
% %     badChans={'FC1'};
% % else
% %     badChans=[];
% % end
% % 
% % cnt=0;
% % for iChan=1:length(EEG.chanlocs)
% %     if ismember(EEG.chanlocs(iChan).labels,badChans)
% %         cnt=cnt+1;
% %         badChansIdx(cnt)=iChan;
% %     end
% % end
% % 
% % EEG = pop_interp(EEG,badChansIdx,'spherical');
% 
% 
% 
% 
% 
% 
% 
% 
% % epoch around start and end points [puts data in time x chans x epochs
% % format which is easier to work with moving forwards I think...]
% %EEG = pop_epoch(EEG,{2},[0,195]); % DO THIS LATER AFTER ICA
% %nTrials = size(EEG.epoch,2);
% 
% 
% % save data 
% save([EEG_clean '/' sprintf('sj%d_se%02d_clean.mat',subject,session+1)],'EEG','bad_channel_list')
%     
% return
% 
% 
% 
% 
% 
% 
% 
% 
% % 
% % save([EEG_clean sprintf('sj%02d_bl%02d_con%02d_ft_clean.mat',subject,iBlock,iCon)],'EEG');
% % 
% % % save bad channel list for each sj
% % if iFile == length(file_list)
% %     save([EEG_clean sprintf('sj%02d_bad_channels.mat',subject)],'bad_channel_list')
% % end
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% % %% Load Data, High Pass Filter
% % 
% % cd ([Parent_dir '/EEG_Raw']) %have to be in directory with raw EEG data to get all subject data
% % 
% % %sj 11:13 file name wrong: se = condition # & cd = session #
% % if ismember(subject,(11:13))
% %     %create filename but keep blocks and conditions wildcard (*) for later file
% %     %list
% %     filename = sprintf('GB_sj%02d_se*_bl*_cd3_1.vhdr',subject);
% % else
% %     filename=sprintf('GB_sj%02d_se3_bl*_cd*_1.vhdr',subject);
% % end
% % 
% % %grab all files in current directory with same condition ID
% % file_list = dir(filename);
% % file_list = {file_list.name};
% % 
% % bad_channel_list = {};
% % for iFile = 1:length(file_list)
% %     
% %     filename = file_list{iFile};
% %     
% %     % Grab block number
% %     iBlock = str2num(file_list{iFile}([strfind(file_list{iFile},'bl')+2:strfind(file_list{iFile},'_cd')-1]));
% %     
% %     if subject == 19 && iBlock == 13
% %         go = ''; 
% %     end
% %     
% %     % Grab condition number
% %     if ismember(subject,(11:13))
% %         iCon = str2num(file_list{iFile}([strfind(file_list{iFile}, 'se')+2]));
% %     else
% %         iCon = str2num(file_list{iFile}([strfind(file_list{iFile}, 'cd')+2]));
% %     end
% %     
% %     
% %     if filtering == 1
% %         
% %         EEG = pop_fileio([EEGraw_dir filename]);
% %         % downsample data
% %         EEG = pop_resample(EEG, 250);
% %         
% %         %% Change event codes to reflect condition
% %         
% %         %make array to change event codes
% %         event_codes = {'S101','S102','S103','S104','S105','S106',...
% %             'S107','S108','S109','S110','S111','S112','S113',...
% %             'S114','S115','S116','S117','S118','S119','S120'};
% %         
% %         %changing the event to show condition
% %         for iEvent=1:length(EEG.event)
% %             if ismember(EEG.event(iEvent).type,event_codes)
% %                 event=EEG.event(iEvent).type;
% %                 event(2)=int2str(iCon);
% %                 EEG.event(iEvent).type = event;
% %             end
% %         end
% %         
% %         % highpass filter the data at 1 Hz (for ICA, ASR, and CleanLine)
% %         EEG = pop_eegfiltnew(EEG,1);
% %         
% %         % edit channel location
% %         EEG = pop_chanedit(EEG, 'lookup',...
% %             '/home/garrett/eeglab14_1_2b/plugins/dipfit3.2/standard_BESA/standard-10-5-cap385.elp');
% %         
% %         save([EEG_filt sprintf('sj%02d_bl%02d_con%02d_filt.mat',subject,iBlock,iCon)],'EEG','-v7.3');
% %         
% %     end
% %     
% %     %% Clean Data & Average
% %     
% %     if cleaning == 1
% %         
% %         
% %         load([EEG_filt sprintf('sj%02d_bl%02d_con%02d_filt.mat',subject,iBlock,iCon)],'EEG');
% %         
% %         %remove line noise using CleanLine function, TAKES A WHILE
% %         EEG = pop_cleanline(EEG,'SignalType','Channels','ChanCompIndices',[1:EEG.nbchan]);
% %         
% %         % create event list for epoch
% %         all_events_int = [101:120,201:220,301:320,401:420];
% %         event_cnt = 1;
% %         all_events_str = num2cell(zeros(1,length(all_events_int)));
% %         for iEvent = 1:length(all_events_int)
% %             all_events_str{iEvent} = ['S' int2str(all_events_int(iEvent))];
% %             event_cnt = event_cnt + 1;
% %         end
% %       
% %         % Apply clean_rawdata() to reject bad channels and correct continuous data using Artifact Subspace Reconstruction (ASR)
% %         % using defaults and Makotos code https://sccn.ucsd.edu/wiki/Makoto%27s_useful_EEGLAB_code
% %         % make sure to specificy available RAM to ensure reproducability due to
% %         % adaptive RAM assignment
% %         % Turned off rejection of bad "windows"
% %         originalEEG = EEG;
% %         EEG = clean_rawdata(EEG,5,-1,.85,4,20,0.25,'WindowCriterionTolerances','off','availableRAM_GB',jobRAM);
% %         
% %         % save original channel locations for later
% %         EEG.original_chanlocs = originalEEG.chanlocs;
% %         
% %         % create list of bad channels to interpolate them all
% %         bad_channels = setdiff({EEG.original_chanlocs.labels},{EEG.chanlocs.labels});
% %         bad_channel_list = unique(cat(2,bad_channel_list,bad_channels));
% %         
% %         save([EEG_clean sprintf('sj%02d_bl%02d_con%02d_ft_clean.mat',subject,iBlock,iCon)],'EEG');
% %         
% %         % save bad channel list for each sj
% %         if iFile == length(file_list)
% %             save([EEG_clean sprintf('sj%02d_bad_channels.mat',subject)],'bad_channel_list')
% %         end
% %         
% %     end
% % end
% % 
% % %% Interpolate and Epoch
% % if epoch == 1
% %     
% %     cd(EEG_clean)
% %     
% %     % grab cleaned blocks
% %     filename = sprintf('sj%02d_bl*_con*_ft_clean.mat',subject);
% %     file_list = dir(filename);
% %     file_list = {file_list.name};
% %     
% %     % load bad channel list
% %     load([EEG_clean sprintf('sj%02d_bad_channels.mat',subject)],'bad_channel_list')
% %     
% %     for iFile = 1:length(file_list)
% %         
% %         % load filtered EEG data
% %         load([EEG_clean file_list{iFile}],'EEG')
% %         
% %         % Grab block number
% %         iBlock = str2num(file_list{iFile}([strfind(file_list{iFile},'bl')+2:strfind(file_list{iFile},'_con')-1]));
% %         
% %         % Grab condition number
% %         iCon = str2num(file_list{iFile}([strfind(file_list{iFile}, 'con')+3:strfind(file_list{iFile},'_ft')-1]));
% %         
% %         %remove bad channels across blocks
% %         EEG = pop_select(EEG, 'nochannel',bad_channel_list);
% %         
% %         %interpolate removed channels
% %         EEG = pop_interp(EEG,EEG.original_chanlocs, 'spherical');
% %         
% % 
% %         % save continous data
% %         EEG.continousData = EEG.data;
% %         
% %         % do big epoch before ICA? Or just epoch to our time of interest
% %         % shot period of interest (-3 to 2)
% %         EEG = pop_epoch(EEG, all_events_str,[-3 2]);
% %         
% %         % remove baseline?
% %         EEG = pop_rmbase(EEG,[-2000 -1500]);
% %         
% %         % save cleaned epoched data
% %         save([EEG_ep sprintf('sj%02d_bl%02d_con%02d_ft_clean_ep.mat',subject,iBlock,iCon)],'EEG','-v7.3');
% %     end
% %    
% %     % merge cleaned epoched data
% %     GB_EEG_merge(subject)
% %     
% %     
% % end
% % 
% % 
% % end


