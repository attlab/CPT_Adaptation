function EEG_AMICA(subNum,session)
%{ 
==========================================================================
Run AMICA on CPT Data (Neil's scripts adapted by Tom Bullock for CPT)

==========================================================================
%}

%% add dirs, paths etc.
Parent_dir = '/home/bullock/BOSS/CPT_Adaptation/';
scriptsDir = [Parent_dir 'Analysis_Scripts'];
eeglabDir = '/home/bullock/matlab_2016b/TOOLBOXES/eeglab14_1_1b';
addpath(genpath(scriptsDir))

cleanDataDir = [Parent_dir 'EEG_Processed_Cleaned_For_ICA/'];
EEG_ica_dir = [Parent_dir 'EEG_ICA_Notch/'];

cd(eeglabDir)
eeglab
close all
cd(scriptsDir)

%% dirs
%eeglab_dipDir = '/Users/tombullock/Documents/MATLAB/eeglab14_1_2b/plugins/dipfit2.3/';
%Parent_dir = '/Users/tombullock/Documents/Psychology/BOSS/CPT/';
%Parent_dir = '/home/bullock/BOSS/CPT/';
%cleanDataDir = [Parent_dir 'EEG_Processed_Cleaned_For_ICA/'];
%cleanDataDir = [Parent_dir 'EEG_Processed_Cleaned_For_ICA_With_ASR/'];
%EEG_ica_dir = [Parent_dir 'EEG_ICA/'];
%addpath(genpath('/Users/tombullock/Documents/Psychology/BOSS/CPT/Analysis_Scripts_Local'))
%addpath(genpath('/home/bullock/BOSS/CPT/Analysis_Scripts_Local'))


%% load data
load([cleanDataDir sprintf('sj%d_se%02d_clean.mat',subNum,session+1)]);
EEG.data = double(EEG.data); % use double precision for ICA


if isfield(EEG.etc, 'clean_channel_mask')
    dataRank = min([rank(double(EEG.data')) sum(EEG.etc.clean_channel_mask)]);
else
    dataRank = rank(double(EEG.continousData'));
end

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
    
    
    save([EEG_ica_dir sprintf('sj%02d_se%02d_EEG_clean_ica.mat',subNum,session+1)], 'EEG','-v7.3');
    
catch e
    header = sprintf('Error running ICA PREPROCESSING for SJ %02d. WHY HAVE YOU FORSAKEN ME.',subNum);
    message = sprintf('The identifier was:\n%s.\nThe message was:\n%s', e.identifier, e.message);
    sendEmailToMe(header,message)
    error(message)
end

return