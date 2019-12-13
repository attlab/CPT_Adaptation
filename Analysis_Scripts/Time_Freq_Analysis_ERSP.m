%{
ERSP_Time_Freq_Analysis
Author: Tom Bullock, UCSB Attention Lab
Date: 09.05.19

This script grabs pre-processed CPT EEG files and uses newtimef to generate
ERSPs for each subject. 

"Task_Order.mat' must be present and correct for all subjects in order to
determine the temporal order that the CPT sessions were completed in.

%% FOR THE ICA datasets, just PAD the data either side before running this,
to prevent the data being cut off...

% Just stick with ERSPS perhaps?  Also try just doing FFT at specific
times (better cope with noise over time, perhaps)

%}

function Time_Freq_Analysis_ERSP(sjNum,analysisType)

%% add scripts dir to path
%addpath(genpath('/data/DATA_ANALYSIS/CPT/Analysis_Scripts')) % BOSS cluster
%addpath(genpath('/Users/tombullock/Documents/Psychology/BOSS/CPT/Analysis_Scripts_Local')) % local
addpath(genpath('/home/bullock/BOSS/CPT_Adaptation/Analysis_Scripts'))

% load eeglab into path (unless already present)
%if ~exist('eeglab.m')
    %cd('/Users/tombullock/Documents/MATLAB/eeglab14_1_2b') % local
    %cd('/data/DATA_ANALYSIS/All_Dependencies/eeglab14_1_1b') % BOSS
    cd('/home/bullock/matlab_2016b/TOOLBOXES/eeglab14_1_1b')
    eeglab
    close all
    cd ..
%else
    close all
%end

% define analysis type
%analysisType=1;
%sourceDir='/Users/tombullock/Documents/Psychology/BOSS/CPT/EEG_ICA'; % local
sourceDir='/home/bullock/BOSS/CPT_Adaptation/EEG_ICA_COMPS_LABELLED'; % icb
destDir='/home/bullock/BOSS/CPT_Adaptation/Time_Freq_Results_IC_Label';

    
%% loop through sessions (1=treatment, 2=control) and CPT exposures (tasks)
ersp=[];
for iSession=1:2 
    
    % load EEG data (all 5 sessions in order)
    clear EEG
    load([sourceDir '/' sprintf('sj%d_se%02d_EEG_clean_ica.mat',sjNum,iSession+1)]);
    
    % calculate the ICA activations and remove bad components (occ only)
    EEG.icaact = (EEG.icaweights*EEG.icasphere)*EEG.data(EEG.icachansind,:); %% ADDED THIS COZ icaact is currently [] QUERY???
   
    % get bad components from IC Label classification matrix and remove
    % anything that isn't brain
    cnt=0;
    for i=1:length(EEG.etc.ic_classification.ICLabel.classifications)
        if EEG.etc.ic_classification.ICLabel.classifications(i,1)>.75
            cnt=cnt+1;
            goodComps(cnt) = i;
        end
    end
    badCompsICLabel = setdiff(1:length(EEG.etc.ic_classification.ICLabel.classifications),goodComps)
    EEG=pop_subcomp(EEG,badCompsICLabel,0);
    
    %% get bad comps from manual IC labeling (tom - just eye and ekg)
    %EEG=pop_subcomp(EEG,bad_comps_occ_ekg,0); 
    
    % save the channel locations
    chanlocs=EEG.chanlocs;
    
    % low pass filter to remove noise above 30 Hz (already 1 Hz LPF for ICA)
    if analysisType==1
        EEG = my_fxtrap(EEG,0,30,.1,0,0,0); %hp,lp,transition,rectif,smooth, resamp
    end
    
    % epoch data to length of CPT immersions
    EEG=pop_epoch(EEG,{2},[0,194.9]);
    
    % ERSP Settings
    if analysisType==1
        erspSettings.freqs=[1,30];
        erspSettings.nFreqs=30;
        erspSettings.winsize=1000;
        erspSettings.timesout=200;
    else
        erspSettings.freqs=[1,100];
        erspSettings.nFreqs=50;
        erspSettings.winsize=1000;
        erspSettings.timesout=200;
    end

    
    % generate an ERSP for each epoch [figure out how to plot specific
    % times using timesout]
    for iEpoch=1:5
        for iChan=1:EEG.nbchan
            [erspTmp,~,~,times,freqs] = newtimef(EEG.data(iChan,:,iEpoch),EEG.pnts,...
                [EEG.xmin, EEG.xmax]*1000,...
                EEG.srate,'cycles',0,...
                'freqs',erspSettings.freqs,...
                'nfreqs',erspSettings.nFreqs,...
                'winsize',erspSettings.winsize,... % samples for moving window (1000 = 4 secs window, note default is much larger for smoother data...may want to expand this)
                'timesout',erspSettings.timesout,... % impacted by winsize (this needs to be worked out - ideally do 1-195)
                'plotersp','off',...
                'plotitc','off',...
                'plottype','image');
            
            ersp(iSession,iEpoch,iChan,:,:) = erspTmp;
        end
    end
    
end

% save data
if analysisType==1
    save([destDir '/' sprintf('sj%d_ersp_30.mat',sjNum)],'ersp','times','freqs','chanlocs')
else
    save([destDir '/' sprintf('sj%d_ersp_100.mat',sjNum)],'ersp','times','freqs','chanlocs')
end

return