function Time_Freq_Analysis_ERSP_ICA(sjNum)

%{
ERSP_Time_Freq_Analysis
Author: Tom Bullock, UCSB Attention Lab
Date: 09.05.19

This script grabs pre-processed CPT EEG files and uses newtimef to generate
ERSPs for each subject. 

"Task_Order.mat' must be present and correct for all subjects in order to
determine the temporal order that the CPT sessions were completed in.

Compute ERSPs for IC Label DipFit 50 Hz Low Pass data

%}



%% add scripts dir to path
%addpath(genpath('/data/DATA_ANALYSIS/CPT/Analysis_Scripts')) % BOSS cluster
%addpath(genpath('/Users/tombullock/Documents/Psychology/BOSS/CPT/Analysis_Scripts_Local')) % local
addpath(genpath('/home/bullock/BOSS/CPT_Adaptation/Analysis_Scripts'))

eeglabDir = '/home/bullock/Toolboxes/eeglab2019_1';

cd(eeglabDir);
eeglab
close all
cd ..

% define analysis type
%analysisType=1;
%sourceDir='/Users/tombullock/Documents/Psychology/BOSS/CPT/EEG_ICA'; % local



sourceDir = '/home/bullock/BOSS/CPT_Adaptation/EEG_ICA_50Hz_LP_DIPFIT';
destDir = '/home/bullock/BOSS/CPT_Adaptation/Time_Freq_results_1-30Hz_ICLabel_Dipfit';




    
%% loop through sessions (1=treatment, 2=control) and CPT exposures (tasks)
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
    goodRvIdx = find(rvList < 0.15)'; % < 15% residual variance == good ICs.
    
    
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
    
    comps.goodIC(iSession) = {goodIcIdx};
    comps.goodRV(iSession) = {goodRvIdx};
    
    save([destDir '/' sprintf('sj%d_ersp_1-30Hz.mat',sjNum)],'ersp','times','freqs','chanlocs','comps')
    
end

return
    
    
    
    
    
    
    
    
    
    
    
    
    
    
%     if analysisType==2 % remove occular artifacts identifier by IC Label 
%         badCompsICLabel=[];
%         cnt=0;
%         for i=1:length(EEG.etc.ic_classification.ICLabel.classifications)
%             if EEG.etc.ic_classification.ICLabel.classifications(i,3)>.8
%                 cnt=cnt+1;
%                 badCompsICLabel(cnt)=i;
%             end
%         end
%     end
%     
%     if analysisType==3  % remove anything that ICLabel classifier isn't 80% confident brain      
%         cnt=0;
%         for i=1:length(EEG.etc.ic_classification.ICLabel.classifications)
%             if EEG.etc.ic_classification.ICLabel.classifications(i,1)>.8
%                 cnt=cnt+1;
%                 goodComps(cnt) = i;
%             end
%         end
%         badCompsICLabel = setdiff(1:length(EEG.etc.ic_classification.ICLabel.classifications),goodComps);
%     end
%     
%     if analysisType==4  % remove anything that ICLabel classifier isn't 80% confident brain      
%         cnt=0;
%         for i=1:length(EEG.etc.ic_classification.ICLabel.classifications)
%             if EEG.etc.ic_classification.ICLabel.classifications(i,1)>.6
%                 cnt=cnt+1;
%                 goodComps(cnt) = i;
%             end
%         end
%         badCompsICLabel = setdiff(1:length(EEG.etc.ic_classification.ICLabel.classifications),goodComps);
%     end
%     
%     if analysisType==5 % keep component if classified as either brain or other
%         icClasses=[];
%         goodComps=[]; a=[]; b=[];
%         icClasses=EEG.etc.ic_classification.ICLabel.classifications;
%         cnt=0;
%         for c=1:size(icClasses,1)
%             [a,b]=sort(icClasses(c,:),'descend');
%             if ismember(b(1),[1,7]) % if highest classification is "brain" or "other"
%                 cnt=cnt+1;
%                 goodComps(cnt)=c;
%             end
%         end
%         badCompsICLabel = setdiff(1:length(EEG.etc.ic_classification.ICLabel.classifications),goodComps);
%     end
%     
%     
%     
%     % remove bad ICA components
%     if analysisType>1
%         EEG=pop_subcomp(EEG,badCompsICLabel,0);
%         disp("Removing ICA components")
%     end
%     
%     % apply low-pass filter to remove noise above 30 Hz (already 1 Hz LPF for ICA)
%     if analysisType>1
%         EEG = my_fxtrap(EEG,0,30,.1,0,0,0); %hp,lp,transition,rectif,smooth, resamp
%         disp('Low Pass Filtering')
%     end
%     
%     
%     
%     
%     
%     
%     % save the channel locations
%     chanlocs=EEG.chanlocs;
%         
%     % epoch data to length of CPT immersions
%     EEG=pop_epoch(EEG,{2},[0,194.9]);
%     
%     % ERSP Settings
%     if analysisType==0
%         erspSettings.freqs=[1,500];
%         erspSettings.nFreqs=50;
%         erspSettings.winsize=1000;
%         erspSettings.timesout=200;
%     elseif analysisType==1
%         erspSettings.freqs=[1,100];
%         erspSettings.nFreqs=100;
%         erspSettings.winsize=1000;
%         erspSettings.timesout= find(EEG.times==1):1000:EEG.times(end);
%     elseif analysisType>1
%         erspSettings.freqs=[1,30];
%         erspSettings.nFreqs=30;
%         erspSettings.winsize=1000;
%         %erspSettings.timesout=200;
%         erspSettings.timesout= find(EEG.times==4):1000:EEG.times(end); % actually 2002 to 192002
%     else
% 
%     end
% 
%     
%     % generate an ERSP for each epoch [figure out how to plot specific
%     % times using timesout]
%     for iEpoch=1:5
%         for iChan=1:EEG.nbchan
%             [erspTmp,~,~,times,freqs] = newtimef(EEG.data(iChan,:,iEpoch),EEG.pnts,...
%                 [EEG.xmin, EEG.xmax]*1000,...
%                 EEG.srate,'cycles',0,...
%                 'freqs',erspSettings.freqs,...
%                 'nfreqs',erspSettings.nFreqs,...
%                 'winsize',erspSettings.winsize,... % samples for moving window (1000 = 4 secs window, note default is much larger for smoother data...may want to expand this)
%                 'timesout',erspSettings.timesout,... % impacted by winsize (this needs to be worked out - ideally do 1-195)
%                 'plotersp','off',...
%                 'plotitc','off',...
%                 'plottype','image');
%             
%             ersp(iSession,iEpoch,iChan,:,:) = erspTmp;
%         end
%     end
%     
% end
% 
% % save data
% if analysisType==0
%     save([destDir '/' sprintf('sj%d_ersp_1-500Hz.mat',sjNum)],'ersp','times','freqs','chanlocs')
% elseif analysisType==1
%     save([destDir '/' sprintf('sj%d_ersp_1-100Hz.mat',sjNum)],'ersp','times','freqs','chanlocs')
% elseif analysisType>1
%     save([destDir '/' sprintf('sj%d_ersp_1-30Hz.mat',sjNum)],'ersp','times','freqs','chanlocs')
% end
% 
% return