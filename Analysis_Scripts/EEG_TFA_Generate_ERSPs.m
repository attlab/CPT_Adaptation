function EEG_TFA_Generate_ERSPs(sjNum,analysisType)

%{
EEG_TFA_Generate_ERSPs
Author: Tom Bullock, UCSB Attention Lab
Date: 09.05.19 (last updated 12.02.22)

This script grabs pre-processed, clean CPT EEG files and uses newtimef to
generate Event Related Spectral Perturbations (ERSPs) for each subject

Notes:

"Task_Order.mat' must be present and correct for all subjects in order to
determine the temporal order that the CPT sessions were completed in.

%}

% add scripts dir to path
addpath(genpath('/home/bullock/BOSS/CPT_Adaptation/Analysis_Scripts')) % ICB Cluster

% add EEGLAB path
eeglabDir = '/home/bullock/Toolboxes/eeglab2019_1';
cd(eeglabDir);
eeglab
close all
cd ..

% set dirs
%sourceDir = '/home/bullock/BOSS/CPT_Adaptation/EEG_ICA_50Hz_LP_DIPFIT';
sourceDir = '/home/bullock/BOSS/CPT_Adaptation/EEG_RERUN/EEG_ICA_50Hz_LP_DIPFIT'; %TOM RERUN
if analysisType==1 % final was 11
    %destDir = '/home/bullock/BOSS/CPT_Adaptation/Time_Freq_results_1-30Hz_ICLabel_Dipfit_NewBL';% correct baseline in newtimef function
    destDir = '/home/bullock/BOSS/CPT_Adaptation/EEG_RERUN/Time_Freq_results_1-30Hz_ICLabel_Dipfit_NewBL'; % TOM RERUN
elseif analysisType==2 % was 12
    %destDir = '/home/bullock/BOSS/CPT_Adaptation/Time_Freq_results_1-30Hz_ICLabel_Dipfit_No_BL_Corr'; % no baseline correction at all for anticipaotry stuff
    destDir = '/home/bullock/BOSS/CPT_Adaptation/EEG_RERUN/Time_Freq_results_1-30Hz_ICLabel_Dipfit_No_BL_Corr'; % TOM RERUN
end
  
% loop through sessions (1=treatment, 2=control) and CPT exposures (tasks)
ersp=[];
for iSession=1:2 
    
    % load EEG data (all 5 sessions in order)
    load([sourceDir '/' sprintf('sj%d_se%02d_EEG_clean_ica.mat',sjNum,iSession+1)]);
    
    % calculate the ICA activations and remove bad components (occ only)
    %EEG.icaact = (EEG.icaweights*EEG.icasphere)*EEG.data(EEG.icachansind,:);
    
    % get index of "brain"components from ICLabel
    brainIdx  = find(EEG.etc.ic_classification.ICLabel.classifications(:,1) >= 0.7); % > 70% brain == good ICs.
    
    % Perform IC rejection using residual variance of the IC scalp maps.
    rvList    = [EEG.dipfit.model.rv];
    goodRvIdx = find(rvList < 0.15)'; % < 15% residual variance == good ICs (i.e. brain sources)
    
    % Perform IC rejection using inside brain criterion.
    load(EEG.dipfit.hdmfile); % This returns 'vol'. (cluster pathway)
    
    %load('/Users/tombullock/Documents/MATLAB/eeglab2019_1/plugins/dipfit/standard_BEM/standard_vol.mat') % local pathway
    dipoleXyz = zeros(length(EEG.dipfit.model),3);
    for icIdx = 1:length(EEG.dipfit.model)
        dipoleXyz(icIdx,:) = EEG.dipfit.model(icIdx).posxyz(1,:);
    end
    depth = ft_sourcedepth(dipoleXyz, vol);
    depthThreshold = 1;
    insideBrainIdx = find(depth<=depthThreshold);
    
    % Take AND across the three criteria.
    goodIcIdx = intersect(brainIdx, goodRvIdx);
    goodIcIdx = intersect(goodIcIdx, insideBrainIdx);
    
    % Perform IC rejection.
    EEG = pop_subcomp(EEG, goodIcIdx, 0,1);
    
    % Post-process to update ICLabel data structure.
    EEG.etc.ic_classification.ICLabel.classifications_brain_only = EEG.etc.ic_classification.ICLabel.classifications(goodIcIdx,:);
    
%     % Post-process to update EEG.icaact.
%     EEG.icaact = [];
%     EEG = eeg_checkset(EEG, 'ica');
%  
    
    % save the channel locations
    chanlocs=EEG.chanlocs;

    % epoch data to length of CPT immersions
    EEG=pop_epoch(EEG,{2},[0,194.9]);
    
    % ersp settings
    erspSettings.freqs=[1,30];
    erspSettings.nFreqs=30;
    erspSettings.winsize=1000;
    %erspSettings.timesout=200;
    erspSettings.timesout= find(EEG.times==4):1000:EEG.times(end); % actually 2002 to 192002
    
    if analysisType==1 % sub baseline
        thisBaseline = [26000,40000];
    elseif analysisType==2
         thisBaseline = NaN; % do not sub baseline
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
                'plottype','image',...
                'baseline',thisBaseline); % apply baseline correction
            
            ersp(iSession,iEpoch,iChan,:,:) = erspTmp;
        end
    end
    
    comps.goodIC(iSession) = {goodIcIdx};
    comps.goodRV(iSession) = {goodRvIdx};
    
    if analysisType==1
        save([destDir '/' sprintf('sj%d_ersp_1-30Hz.mat',sjNum)],'ersp','times','freqs','chanlocs','comps')
    elseif analysisType==2
        save([destDir '/' sprintf('sj%d_ersp_1-30Hz.mat',sjNum)],'ersp','times','freqs','chanlocs','comps')
    end
    
end

return