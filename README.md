# CPT_Adaptation

Scripts for taking the preprocessed CPT_Adapatation EEG data (preprocessed on BOSS cluster and located in MASTER structure) and moving forwards with data analysis

## EEG Preprocessing

Move Prepro EEG data from BOSS MASTER structure to EEG_CPT_Prepro file here.

`EEG_Clean_For_ICA.m` + job Clean data in prep for ICA (for broadband muscle noise analysis set analysisType=0, for main ICA analyses set analysisType=1)

`EEG_AMICA.m` + job Run ICA on data

`EEG_IC_Label.m` + job Run IC Label classifier on data and save EEG files with IC Label classification mat



## EEG Analyses

ERSP (newtimef), BAND (bandpass) or FFT (simple spectral)

`Time_Freq_Analysis_ERSP.m`[+ job + compile + plot + topoPlot] Run newtimef on preprocessed EEG data, compile, plot

`Time_Freq_Analysis_BAND.m` [+ job + compile/plot] Run bandpass filters on EEG data to extract delta,theta,alpha,beta, compile, plot

`Time_Freq_Analysis_FFT.m` [+ job + compile] Run fft averaged across specific timepoints.


## EYE Analysis

**Move compiled EYE_CPT_Master.mat file from BOSS>ICB cluster**

`EYE_Plot_Pupil_Group.m` Group pupil diameter plots

'EYE_Plot_Pupil_Individual.m` Individual pupil diameter plots



## TO DO

Fix EEG_Clean_For_ICA script to work with imported data

Run AMICA (if possible) on notched EEG data OR just use AAR algo instead to get rid of eyeblinks?

Reject eyeblinks?

Re-plot data etc.






## OLD STUFF (REMOVE EVENTUALLY)

%% Move data onto local machine to run component rejection (cluster doesn't handle graphics well) %%

`EEG_Reject_Components.m` This adds a vector of bad comonents (occular and ekg artifacts only) to the data structure (bad_comps_occ_ekg)







