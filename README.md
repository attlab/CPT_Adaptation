# CPT_Adaptation

Scripts for taking the preprocessed CPT_Adapatation EEG data (preprocessed on BOSS cluster and located in MASTER structure) and moving forwards with data analysis

Script Authors: 

Tom Bullock Neil Dundon, Tyler (put GLMM R scripts online?)

Last updated: 04.04.20



## EEG Preprocessing

*Move Prepro EEG data from BOSS MASTER structure to EEG_CPT_Prepro file here first.*

`CPT_SUBJECTS.m` List of valid CPT subjects for each measure, with notes

`EEG_Clean_For_ICA.m` + job Clean data in prep for ICA (for broadband muscle noise analysis set analysisType=0, for main ICA analyses set analysisType=1)

`EEG_AMICA.m` + job Run ICA on data

`EEG_IC_Label.m` + job Run IC Label classifier on data and save EEG files with IC Label classification mat

`EEG_ICLabel_Get_Classification_Stats.m` Get a summary of IC classification across all subjects and conditions.



## EEG Analyses

`Time_Freq_Analysis_ERSP.m`[+ job + compile + plot + topoPlot] Run newtimef on preprocessed EEG data, compile, plot



## PHYSIO Analysis

`Physio_Stats_Resample.m` Compute resampled t-test stats for all physio measures (required for plots)

`Physio_Plot.m` Generate plots for all physio measures (regular)

`Physio_Plot_Compare_Within_Session.m` Generate within condition comparision plots (paired with GLMMs)

`Physio_Convert_To_LF.m` Convert data to long format for GLMM analyses

`Classify_Stress_Rank_Order_Analysis.m` Perform rank order analyses on the physio data only

`Classify_Stress_Rank_Order_Plot.m` Plot rank order analysis for each physio measure including all 10 trials

`Classify_Stress_Rank_Order_Plot_Individual_Trials.m` Plot rank order analysis for each physio measure separate for each CPT/WPT trial pair.



## EYE Analysis

*First move compiled EYE_CPT_Master.mat file from BOSS>ICB cluster*

`EYE_Plot_Pupil_Group.m` Group pupil diameter plots

`EYE_Plot_Pupil_Individual.m` Individual pupil diameter plots (saves images in subfolders in plots)

`EYE_Stats_Resample.m` Do resampled stats for eye data



## Self Report

`Self_Report_Plot.m` Plot self-reported pain ratings (currently all n=50 subjects)

`Self_Report_Stats_Resample.m` Compute resampled stats

`Self_Report_Stats_Resample_Within_Cond.m` Compute resampled stats within condition (??)



## Cortisol 

`Cortisol_Plot.m` Plot cortisol results (currently all subjects)

`Cortisol_Stats_Resample.m` Generate resampled stats



## Misc

`Demographic_Info.m` Compiles demographic info for presentation

`my_fxcomb.m` Neil's comb filter

`my_fixtrap.m` Neil's trapizoidal filter