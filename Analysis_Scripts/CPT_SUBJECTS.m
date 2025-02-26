%{
CPT_SUBJECTS
Author: Tom Bullock
Date: 09.15.18

List of subject numbers (and works in progress) for CPT

Note that I may want to create different outputs for EEG, EYE, BEH, PHYS
because missing files...

%}

function [subjects_eeg_eye_intact,subjects_all] = CPT_SUBJECTS


%% EEG + EYE intact subjects n=34 (052419) ...now need to test the next step to see if any need triggers recovering?!
subjects_eeg_eye_intact = [103,108,111,114,115,117:119, 121,123:126,128,132,133,135,136,138,139,140,144,146,147,149,150,151,154:158,160,161]; % all intact 

%% EYE intact subjects n=9 (EEG BROKEN)
subjects_eye_only = [102,105,109,116,127,130,143,148,159]; % all intact EYETRACKING

%% All subjects together in ascending order (n=43)
subjects_all = sort([subjects_eeg_eye_intact,subjects_eye_only]);


%% NOTES ON SUBJECTS (TOM, 05.25.19)
% 102 se03 cf is bad [UNRECOVERABLE EEG Cuts off early]
% 103 se02 and se03 are missing rs and g1 [FIXED!]
% 104 se02 missing files, se03 missing cr eye and eeg [UNRECOVERABLE]
% 105 se02 cr EEG missing triggers [POSSIBLY RECOVERABLE]*
% 107 se02 cm missing eeg+eye [UNRECOVERABLE]
% 108 both se02 and se03 have no EEG triggers [FIXED]
% 109 se02 cm eeg missing triggers [POSSIBLY RECOVERABLE *]
% 110 se02 cf eeg+eye missing [UNRECOVERABLE]
% 114 se03 missing triggers [FIXED!]
% 116 se03 cv short [EEG UNRECOVERABLE coz SE03, EYE GOOD]
% 119 se03 segment 2 stars prior to first rs trigger [FIXED]
% 120 se02 cv eeg+eye? missing [UNRECOVERABLE]
% 122 - se03cn missing eeg and eye files [UNRECOVERABLE but only because SE03!] 
% 124 looks like a EKG became unplugged halfway through (which session?)
% 125 se01 missing rs,g1 physio (FIXED), se02 good, se03 good
% 126 se02 segmented(NOT FIXED), se03 missing whole physio file [NOT FIXED, EEG OK]
% 127 se01 (stop/start, NOT FIXED), se03 cf eeg file bad [EEG UNRECOVERABLE, EYE OK]
% 128 se02 skip rs,g1 [FIXED]
% 130 se03 cn is short [EEG UNRECOVERABLE but only because SE03!, EYE OK]
% 134 se03cv is short [EEG UNRECOVERABLE but only becuase SE03!, EYE OK]
% 139 GOOD?!
% 140 GOOD?!
% 143 se02 missing triggers and physio corrupted [UNRECOVERABLE]
% 144 se01 no triggers at all, se02 missing first few files (FIXED) se03 good
% 146 se02 many eeg triggers missiing, but alignment looks good
% 147 GOOD?!
% 148 se02cn is short [EEG UNRECOVERABLE, EYE GOOD]
% 150 GOOD?!
% 159 se02 no triggers sent at all [UNRECOVERABLE]



end