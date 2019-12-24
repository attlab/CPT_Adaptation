%{
EEG_IC_Label
Author: Tom Bullock, UCSB Attention Lab
Date: 12.12.19

To do - if this works, reapply it to my new ICA labels

%}

%clear
%close all
function EEG_IC_Label(filename)

% set dirs and load EEGLAB
parentDir = '/home/bullock/BOSS/CPT_Adaptation';
sourceDir = [parentDir '/' 'EEG_ICA_Notch'];
destDir = [parentDir '/' 'EEG_ICA_Notch_IC_Label'];
scriptsDir = [parentDir '/' 'Analysis_Scripts'];
eeglabDir = '/home/bullock/Toolboxes/eeglab2019_1';

cd(eeglabDir)
eeglab
close all
cd(scriptsDir)


% load data
load([sourceDir '/' filename]);

% apply IC Label
EEG = iclabel(EEG);

% % view eye and heart classes
% cnt=0;
% for i=1:length(EEG.etc.ic_classification.ICLabel.classifications)
%     if EEG.etc.ic_classification.ICLabel.classifications(i,3)>.8  || EEG.etc.ic_classification.ICLabel.classifications(i,4)>..8
%         cnt=cnt+1;
%         bad_comps_occ_ekg_iclabel(cnt) = i;
%     end
% end

% save data to same location
%save([sourceDir '/' filename],'EEG','bad_comps_occ_ekg','bad_comps_occ_ekg_iclabel')
save([destDir '/' filename],'EEG')

return
