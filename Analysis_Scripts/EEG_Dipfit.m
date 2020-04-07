%{
EEG_Dipfit
Author: Tom Bullock, UCSB Attention Lab
Date: 04.05.20

Do dipole fitting on ICA/ICLabel Data (for future, just integrate this into
the ICA script)

%}

%clear
%close all
function EEG_Dipfit(filename)

% set dirs and load EEGLAB
parentDir = '/home/bullock/BOSS/CPT_Adaptation';
sourceDir = [parentDir '/' 'EEG_ICA_50Hz_LP'];
destDir = [parentDir '/' 'EEG_ICA_50Hz_LP_DIPFIT'];
scriptsDir = [parentDir '/' 'Analysis_Scripts'];
eeglabDir = '/home/bullock/Toolboxes/eeglab2019_1';

cd(eeglabDir)
eeglab
close all
cd(scriptsDir)


% load data
load([sourceDir '/' filename]);

% Estimate single equivalent dipoles
% Havent used below lines for anything yet

% % original dipfit from Neil Script
% eeglab_dipDir = '/home/bullock/Toolboxes/eeglab2019_1/plugins/dipfit3.3';
% templateChannelFilePath = [eeglab_dipDir 'standard_BESA/standard-10-5-cap385.elp'];
% hdmFilePath  = [eeglab_dipDir 'standard_BEM/standard_vol.mat'];
% EEG = pop_dipfit_settings( EEG, 'hdmfile',[eeglab_dipDir 'standard_BEM/standard_vol.mat'],...
%     'coordformat','MNI','mrifile',...
%     [eeglab_dipDir 'standard_BEM/standard_mri.mat'],'chanfile',...
%     [eeglab_dipDir 'standard_BEM/elec/standard_1005.elc'],'coord_transform',...
%     [0.83215 -15.6287 2.4114 0.081214 0.00093739 -1.5732 1.1742 1.0601 1.1485] ,'chansel',1:63);

% tom dipfit
EEG = pop_dipfit_settings( EEG, ...
    'hdmfile','/home/bullock/Toolboxes/eeglab2019_1/plugins/dipfit3.3/standard_BEM/standard_vol.mat',...
    'coordformat','MNI','mrifile','/home/bullock/Toolboxes/eeglab2019_1/plugins/dipfit3.3/standard_BEM/standard_mri.mat',...
    'chanfile','/home/bullock/Toolboxes/eeglab2019_1/plugins/dipfit3.3/standard_BEM/elec/standard_1005.elc',...
    'chansel',[1:63] );

% apparently this is necessary (chan locs were set to BESA up to this
% point)
EEG=pop_chanedit(EEG, 'lookup','/home/bullock/Toolboxes/eeglab2019_1/plugins/dipfit3.3/standard_BEM/elec/standard_1005.elc');

% does the dipole fit
EEG = pop_multifit(EEG, 1:EEG.nbchan,'threshold', 100, 'dipplot','off','plotopt',{'normlen' 'on'});

% % Search for and estimate symmetrically constrained bilateral dipoles
% EEG = fitTwoDipoles(EEG, 'LRR', 35);


% save data to same location
%save([sourceDir '/' filename],'EEG','bad_comps_occ_ekg','bad_comps_occ_ekg_iclabel')
save([destDir '/' filename],'EEG')

return
