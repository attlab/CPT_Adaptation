# Habituation of the Stress Multiplex to Repeated Cold Pressor Exposure

<Insert paper details and abstract here when accepted>

This repository contains scripts for analyzing the preprocessed CPT_Adapatation EEG data.  The data are available upon request.

Script Authors: 

Tom Bullock, Attention Lab, UCSB 
Neil Dundon, Action Lab, UCSB

Repository last updated: 10.27.21



## GENERAL

`CPT_SUBJECTS.m` List of valid CPT subjects for each measure, with notes



## EEG Preprocessing 

*Move Prepro EEG data from BOSS MASTER structure to EEG_CPT_Prepro file here first.*

`EEG_Clean_For_ICA.m` + job Clean data in prep for ICA (for broadband muscle noise analysis set analysisType=0, for main ICA analyses set analysisType=1)

`EEG_AMICA.m` + job Run ICA on data

`EEG_IC_Label.m` + job Run IC Label classifier on data and save EEG files with IC Label classification mat

`EEG_ICLabel_Get_Classification_Stats.m` Get a summary of IC classification across all subjects and conditions.

`EEG_Dipfit.m' + job Do dipole fitting in ICA/ICLABEL data

`EEG_ICLabel_Get_Classification_Stats.m` Gets a summary of classification stats across all subjects



## EEG Analyses

`EEG_Stats_Resample_Within_ANOVA.m` + job Computes permuted stats

`EEG_Stats_Resample_Within_ANOVA_TimeGrad.m` + job Computes permuted stats averaged over time bins [no baseline correction

`EEG_Stats_Resample_Within_ANOVA_TimeGrad_Base.m + job Computes permuted stats averaged over time bins [baseline correction

`Time_Freq_Analysis_ERSP_ICA.m` + job Generate ERSPS (run newtimef on data)

`Time_Freq_Analysis_ERSP_Compile.m` Compile ERSP data from individual subjects

`Time_Freq_Analysis_ERSP_Plot.m` Plot ERSPs 

`Time_Freq_Analysis_ERSP_Plot_Topos*.m` Generate topo plots for manuscript for ANT (anticipatory) and REC (during CPT and recovery)

`Time_Freq_Analysis_Post_Hocs*.m` Post hoc stats for specific bands

`Time_Freq_Analysis_ERSP_Stats_Resample.m` Run resampled stats on data for main analysis

`Time_Freq_Analysis_ERSP_Stats_Resample_1_100Hz.m`+job Broadband analysis (for supplemental info)




## PHYSIO Analysis

`Physio_Stats_Resample.m` + job  Compute resampled t-test stats for all physio measures (required for plots)

`Physio_Plot.m` Generate plots for all physio measures (regular)

`Physio_Plot_Compare_Within_Session.m` Generate within condition comparision plots (paired with GLMMs)

`Physio_Convert_To_LF.m` Convert data to long format for GLMM analyses (not included in manuscript)

`Classify_Stress_Rank_Order_Analysis.m` Perform rank order analyses on the physio data only

`Classify_Stress_Rank_Order_Plot.m` Plot rank order analysis for each physio measure including all 10 trials

`Classify_Stress_Rank_Order_Plot_Individual_Trials.m` Plot rank order analysis for each physio measure separate for each CPT/WPT trial pair.

`Physio_Interactions.m` Run quick stats to test for interactions between induced stress and evoked stress across different cardiac measures

`Physio_Plot_Compare_Within_Session_With_Stats_ANOVA.m` Create physio plots for manuscript



## EYE Analysis

*First move compiled EYE_CPT_Master.mat file from BOSS>ICB cluster*

`EYE_Plot_Pupil_Group.m` Compare pupil diameter grouped by condition (1 plot per trial, just pairwise comparisons)

`EYE_Plot_Pupil_Within_Cond_Comparisons.m` Compare pupil diameter with ANOVA then pairwise comparisons (for manuscript)

`EYE_Plot_Pupil_Individual.m` Individual pupil diameter plots (saves images in subfolders in plots, useful for determining which subjects have good/bad data)

`EYE_Stats_Resample.m` Compute resampled stats for eye data (pairwise comparisons only)

`EYE_Stats_Reasmple_Within_ANOVA.m` + job Compute resampled stats for manuscript (ANOVA + Pairwise comparisons)

`EYE_Stats_Resample_Within_ANOVA_Avg.m` Additional analysis averaged across 

`EYE_Convert_to_LF.m` Convert eye-tracker data from wide format to long format for analysis in R



## Self Report

`Self_Report_Plot.m` Plot self-reported pain ratings (currently all n=50 subjects)

`Self_Report_Stats_Resample.m` Compute resampled stats

`Self_Report_Stats_Resample_Within_Cond.m` Compute resampled stats within condition (??)

`Self_Report_Stats_Resample_ANOVA_For_MS.m`



## Cortisol 

`Cortisol_Plot.m` Plot cortisol results averaged across time of day (TOD)

`Cortisol_Stats_Resample.m` Generate resampled stats

`Cortisol_Plot_Split_TOD.m` Plot cortisol results split by AM/PM session

`Cortisol_Stats_Resample_TOD.m` Generate resampled stats plit by AM/PM session



## Misc/Dependencies 

`Demographic_Info.m` Compiles demographic info for presentation

`my_fxcomb.m` Neil's comb filter

`my_fixtrap.m` Neil's trapizoidal filter

`shadedErrorBar.m` Creates exactly that (borrowed)

`simple_mixed_anova.m` Does that (borrowed)



## Most Relevant Scripts for Michael [REMOVE THIS FOR FINAL VERSION OF REPO!]

`Time_Freq_Analysis_ERSP_ICA.m` Loads data that has already been run through ICA, applies component rejection criteria, does time/freq analysis

`Time_Freq_Analysis_ERPS_Compile.m` Compiles the ERSPs from individual subjects (analysis type 1 = no ICA, analysis type 6 = ICA)

`EYE_Plot_Pupil_Within_Cond_Comparisons.m` Loads pupil data, rejects bad subjects, normalizes and baseline corrects (optional)

`Physio_Plot_For_Manuscript.m` Loads master physio data file, removes bad subjects on a per measure basis, plots data

