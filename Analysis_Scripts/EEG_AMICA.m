function EEG_AMICA(subNum,session)
%{ 
EEG AMICA
Author: Neil (adapted by Tom for CPT)
Date: 01.09.20

%}

% add dirs, paths etc.
Parent_dir = '/home/bullock/BOSS/CPT_Adaptation/';
scriptsDir = [Parent_dir 'Analysis_Scripts'];
eeglabDir = '/home/bullock/Toolboxes/eeglab2019_1'; 
cleanDataDir = [Parent_dir 'EEG_Processed_Cleaned_For_ICA/'];
EEG_ica_dir = [Parent_dir 'EEG_ICA_50Hz_LP/'];
addpath(genpath(scriptsDir))

% import EEGLAB functions
cd(eeglabDir)
eeglab
close all
cd(scriptsDir)


% load data
load([cleanDataDir sprintf('sj%d_se%02d_clean.mat',subNum,session+1)]);
EEG.data = double(EEG.data); % use double precision for ICA

% get data rank
if isfield(EEG.etc, 'clean_channel_mask')
    dataRank = min([rank(double(EEG.data')) sum(EEG.etc.clean_channel_mask)]);
else
    dataRank = rank(double(EEG.continousData'));
end

% run ICA
try
    
    % AMICA takes forever on continous data, use send email function to notify when done
    runamica15(EEG.data, 'num_chans', EEG.nbchan,...
        'outdir', [EEG_ica_dir sprintf('sj%d_se%02d_EEG_ica',subNum,session+1)],...
        'pcakeep', dataRank, 'num_models', 1,...
        'do_reject', 1, 'numrej', 15, 'rejsig', 3, 'rejint',1);
    
    EEG.etc.amica  = loadmodout15([EEG_ica_dir sprintf('sj%d_se%02d_EEG_ica',subNum,session+1)]); % loads AMICA output from outdir
    EEG.etc.amica.S = EEG.etc.amica.S(1:EEG.etc.amica.num_pcs, :);
    EEG.icaweights = EEG.etc.amica.W;
    EEG.icasphere  = EEG.etc.amica.S;
    EEG = eeg_checkset(EEG, 'ica');
    
        %     % Estimate single equivalent dipoles
    % 	% Havent used below lines for anything yet
    %     templateChannelFilePath = [eeglab_dipDir 'standard_BESA/standard-10-5-cap385.elp'];
    %     hdmFilePath  = [eeglab_dipDir 'standard_BEM/standard_vol.mat'];
    %     EEG = pop_dipfit_settings( EEG, 'hdmfile',[eeglab_dipDir 'standard_BEM/standard_vol.mat'],...
    %         'coordformat','MNI','mrifile',...
    %         [eeglab_dipDir 'standard_BEM/standard_mri.mat'],'chanfile',...
    %         [eeglab_dipDir 'standard_BEM/elec/standard_1005.elc'],'coord_transform',...
    %         [0.83215 -15.6287 2.4114 0.081214 0.00093739 -1.5732 1.1742 1.0601 1.1485] ,'chansel',[1:63] );
    %     EEG = pop_multifit(EEG, 1:EEG.nbchan,'threshold', 100, 'dipplot','off','plotopt',{'normlen' 'on'});
    %
    %     % Search for and estimate symmetrically constrained bilateral dipoles
    %     EEG = fitTwoDipoles(EEG, 'LRR', 35);
    
    
    % apply IC Label
    EEG = iclabel(EEG);
    
    % save data
    save([EEG_ica_dir sprintf('sj%02d_se%02d_EEG_clean_ica.mat',subNum,session+1)], 'EEG','-v7.3');
    
catch e
    header = sprintf('Error running ICA PREPROCESSING for SJ %02d. WHY HAVE YOU FORSAKEN ME.',subNum);
    message = sprintf('The identifier was:\n%s.\nThe message was:\n%s', e.identifier, e.message);
    sendEmailToMe(header,message)
    error(message)
end

return