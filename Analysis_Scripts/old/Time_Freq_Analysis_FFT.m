%{
Time_Freq_Analysis_FFT
Author: Tom Bullock, UCSB Attention Lab
Date: 10.31.19

Compute FFTs for CPT baseline, exposure and recovery.
%}

function Time_Freq_Analysis_FFT(sjNum)

%% add scripts dir to path
addpath(genpath('/home/bullock/BOSS/CPT_Adaptation/Analysis_Scripts_Local'))

%% load eeglab into path (unless already present)
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

%% set directories
destDir = '/home/bullock/BOSS/CPT_Adaptation/Spectra_Results_IC_Label';
sourceDir = '/home/bullock/BOSS/CPT_Adaptation/EEG_ICA_COMPS_LABELLED';

%% loop through sessions (1=treatment, 2=control) and CPT exposures (tasks)
for iSession=1:2 
    
    % load EEG data (all 5 sessions in order)
    clear EEG
    load([sourceDir '/' sprintf('sj%d_se%02d_EEG_clean_ica.mat',sjNum,iSession+1)]);
    
    % calculate the ICA activations and remove bad components (occ only)
    EEG.icaact = (EEG.icaweights*EEG.icasphere)*EEG.data(EEG.icachansind,:); %% ADDED THIS COZ icaact is currently [] QUERY???
    %%EEG=pop_subcomp(EEG,bad_comps_occ_ekg,0); 
    
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
    
    % save the channel locations
    chanlocs=EEG.chanlocs;
    
    % low pass filter to remove noise above 30 Hz (already 1 Hz LPF for ICA)
    EEG = my_fxtrap(EEG,0,30,.1,0,0,0); %hp,lp,transition,rectif,smooth, resamp
    
    % epoch data to length of CPT immersions
    EEG=pop_epoch(EEG,{2},[0,194.9]);
    
    % do separate FFTs for baseline, p1, p2, p3, recovery
    for iFFT=1:5
        
        clear spectra freqs
        
        if      iFFT==1; tstart=find(EEG.times==25000); tend=find(EEG.times==40000); L=tend-tstart;
        elseif  iFFT==2; tstart=find(EEG.times==80000); tend=find(EEG.times==95000); L=tend-tstart;
        elseif  iFFT==3; tstart=find(EEG.times==110000); tend=find(EEG.times==125000); L=tend-tstart;
        elseif  iFFT==4; tstart=find(EEG.times==140000); tend=find(EEG.times==155000); L=tend-tstart;
        elseif  iFFT==5; tstart=find(EEG.times==175000); tend=find(EEG.times==190000); L=tend-tstart;
        end
        
    
        Fs = EEG.srate;
        NFFT = EEG.srate*10;
        
        % pre-allocate spectra
        spectra = zeros(EEG.trials, EEG.nbchan, NFFT);
        
        % for each epoch
        for ii = 1:length(EEG.epoch)
            if rem(ii,10)==0 % this just displays every 10 specs
                disp(ii);
            end
            
            for channel = 1:EEG.nbchan % THIS does an FFT for each channel (may want to reduce number of chans here)
                spectra(ii,channel,:) = fft(EEG.data(channel,tstart:tend,ii),NFFT)/L;  % spectra matrix = 360 (epochs) X 60 (chans) x 2048 (nearest power of 2 to 1500, which is the number of samples per epoch)
            end
        end
        
        freqs = Fs/2*linspace(0,1,NFFT/2+1);    % freqs = a vector of all the freqs from 0 to 250 (check do I need this if I'm filtering at 30Hz?)
        
        % remove freqs above 40 Hz to save space
        spectra = spectra(:,:,find(freqs==1):find(freqs==30));
        freqs = freqs(find(freqs==1):find(freqs==30));      
        allSpec(iSession,iFFT,:,:,:)=spectra;
          
    end
    
end

save([destDir '/' sprintf('sj%02d_spectra.mat',sjNum)],'allSpec','freqs','chanlocs')

return









%%%%%%%%%%%%%

% 
% 
% function Time_Freq_Analysis_FFT(thisFilename)
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
% 
% %% set directories
% interpolateElectrodes=1;
% if interpolateElectrodes
%     eegProcessedFolderAR = '/home/bullock/Kanizsa_Oddball/EEG_EP_AR_Interp';
%     spectraProcessedFolder = '/home/bullock/Kanizsa_Oddball/SPECTRA_Interp';
% else
%     eegProcessedFolderAR = '/home/bullock/Kanizsa_Oddball/EEG_EP_AR';
%     spectraProcessedFolder = '/home/bullock/Kanizsa_Oddball/SPECTRA';
% end
% 
% % load data
% %EEG = pop_loadset([eegProcessedFolderAR '/' thisFilename(1:end-4) '_ep_ar.set']); % ADDED UNTESTED!
% load([eegProcessedFolderAR '/' thisFilename(1:end-4) '.mat']);
% 
% Fs = EEG.srate;
% tstart = 1; % start sample
% tend = EEG.pnts; % end sample
% L = length(EEG.data(1,:,1)); % Length of signal
% NFFT = 1024*10; % set to *4 to do .25 Hz     %2^nextpow2(L); % Next power of 2 from length of y (WHY?)
% 
% % pre-allocate spectra
% spectra = zeros(EEG.trials, EEG.nbchan-8, NFFT);
% 
% % for each epoch
% for ii = 1:length(EEG.epoch)
%     if rem(ii,10)==0 % this just displays every 10 specs
%         disp(ii);
%     end
%     
%     for channel = 1:EEG.nbchan-8 % THIS does an FFT for each channel (may want to reduce number of chans here)
%         spectra(ii,channel,:) = fft(EEG.data(channel,tstart:tend,ii),NFFT)/L;  % spectra matrix = 360 (epochs) X 60 (chans) x 2048 (nearest power of 2 to 1500, which is the number of samples per epoch)
%     end
% end
% 
% freqs = Fs/2*linspace(0,1,NFFT/2+1);    % freqs = a vector of all the freqs from 0 to 250 (check do I need this if I'm filtering at 30Hz?)
% 
% % remove freqs above 40 Hz to save space
% spectra = spectra(:,:,find(freqs==1):find(freqs==40));
% freqs = freqs(find(freqs==1):find(freqs==40));
% 
% % save the EEG process log and EEG chanlocs files
% processLog = EEG.processLog;
% chanlocs = EEG.chanlocs;
% trialLocs = EEG.trialLocs;
% 
% % count number of trials within each position bin
% %clear binCnt
% binMin = [];
% binCnt = [];
% for bin = 1:6 % ori bins
%     binCnt(bin) = sum(trialLocs == bin);
% end
% binMin = min(binCnt); % find bin with min trial count
% 
% % save
% parsave([spectraProcessedFolder '/' 'spectra_' thisFilename(1:14) '.mat'],spectra,freqs,trialLocs,processLog,chanlocs,binMin)
% 
% 
% 
% 
% 
% %matlabpool close
% %delete(mypool);
% 
% 
% % set up AR report to run automatically here
% 

%return