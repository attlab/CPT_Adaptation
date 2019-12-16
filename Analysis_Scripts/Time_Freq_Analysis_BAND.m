%{
Time_Freq_Analysis_BAND
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

function Time_Freq_Analysis_BAND(sjNum)

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
%    close all
%end

% define analysis type
analysisType=1;
%sourceDir='/Users/tombullock/Documents/Psychology/BOSS/CPT/EEG_ICA'; % local
sourceDir='/home/bullock/BOSS/CPT_Adaptation/EEG_ICA_COMPS_LABELLED'; % icb
if analysisType==1
    %destDir= '/Users/tombullock/Documents/Psychology/BOSS/CPT/ERSP_ICA_OCC_30Hz_LPF';
    destDir='/home/bullock/BOSS/CPT_Adaptation/Time_Freq_Results_Band_IC_Label';
end
    
%% loop through sessions (1=treatment, 2=control) and CPT exposures (tasks)

for iSession=1:2 
    
    % load EEG data (all 5 sessions in order)
    clear EEG EEGO EEG_delta EEG_theta EEG_alpha EEG_alpha1 EEG_alpha2 EEG_beta EEG_delta_hilb EEG_theta_hilb EEG_alpha_hilb EEG_alpha1_hilb EEG_alpha2_hilb EEG_beta_hilb
    load([sourceDir '/' sprintf('sj%d_se%02d_EEG_clean_ica.mat',sjNum,iSession+1)]);
    
    % calculate the ICA activations and remove bad components (occ only)
    EEG.icaact = (EEG.icaweights*EEG.icasphere)*EEG.data(EEG.icachansind,:); %% ADDED THIS COZ icaact is currently [] QUERY???
    
    
    % get bad components from IC Label classification matrix and remove
    % anything that isn't brain
    cnt=0;
    for i=1:length(EEG.etc.ic_classification.ICLabel.classifications)
        if EEG.etc.ic_classification.ICLabel.classifications(i,2)<.8
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
    
    % epoch the data
    EEG=pop_epoch(EEG,{2},[0,194.9]);
    
    % loop through freq bands and bandpass filter
    freqs=[...
        1,3;
        4,7;
        8,13;
        14,30;
        8,10;
        11,13
        ];
    
    for f=1:4
        
        clear eegs data tempEEG 
        
        disp(['Bandpass Filtering between ' num2str(freqs(f,1)),' and ' num2str(freqs(f,2)) ' Hz'])
    
    
        %% BUTTERWORTH FILTER
        filterorder = 3;
        type = 'bandpass';
        [z1,p1] = butter(filterorder, [freqs(f,1), freqs(f,2)]./(EEG.srate/2),type);
        
        data = double(EEG.data);
        tempEEG = NaN(size(data,1),EEG.pnts,size(data,3));
        for x = 1:size(data,1) % loop through chans
            for y = 1:size(data,3) % loop through trials
                dataFilt1 = filtfilt(z1,p1,data(x,:,y)); % was filtfilt
                tempEEG(x,:,y) = dataFilt1; % tymp = chans x times x trials
            end
        end
        
        %% apply hilbert to each channel and epoch in turn (try not doing
        %this for now)
        eegs = [];
        for j=1:size(tempEEG,1) % chan loop
            for i=1:size(tempEEG,3) % trial loop
                eegs(j,:,i) = hilbert(squeeze(tempEEG(j,:,i)));
            end
        end
        
        % convert to power
        eegs = abs(eegs).^2;
        
        % resample to reduce memory load
        for r=1:size(eegs,3)
           
            eegs_rs(:,:,r)=resample(eegs(:,:,r)',1,250)';
            %eegs_rs(:,:,r)=downsample(eegs(:,:,r)',25)';
            
        end
        
        if      f==1; EEG_band(iSession).delta=eegs_rs;
        elseif  f==2; EEG_band(iSession).theta=eegs_rs;
        elseif  f==3; EEG_band(iSession).alpha=eegs_rs;
        elseif  f==4; EEG_band(iSession).beta=eegs_rs;
        end
        

    end
    
end

% save data
save([destDir '/' sprintf('sj%d_band.mat',sjNum)],'EEG_band','chanlocs')

return