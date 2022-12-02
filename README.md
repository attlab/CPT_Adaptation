# Habituation of the Stress Response Multiplex to Repeated Cold Pressor Exposure

Insert paper details and abstract here when accepted!

This repository contains scripts for analyzing the preprocessed CPT_Adapatation EEG data.  

The data are available upon here:[INSERT BOX LINK - Upload RAW Physio Data]

This project typically lives in: /home/bullock/BOSS/CPT_Adaptation [can transfer to /work when complete]

### Script Authors: 

Tom Bullock, Attention Lab, UCSB 

Neil Dundon, Action Lab, UCSB

Repository last updated: XXXXXXXXXXX




## GENERAL

`CPT_SUBJECTS.m` List of valid CPT subjects for each measure, with notes



## CORTISOL

`CORT_Plot.m` Plot cortisol results averaged across time of day (TOD)

`CORT_Stats_Resample.m` Generate resampled stats for results averaged across TOD

`CORT_Plot_Split_TOD.m` Plot cortisol results split by AM/PM session

`CORT_Stats_Resample_TOD.m` Generate resampled stats plit by AM/PM session



## DEMOGRAPHICS

`DEMOGRAPHICS_Get_Info.m` Extract demographic info 

`DEMOGRAPHICS_Get_Info_Additional.m` Extract additional demographic info (income etc.) to address a reviewer comment






## EEG

### Run preprocessing scripts to recover a few missing event codes.  These scripts are on BOSS cluster.  

`EEG_Prepro_Wrapper.m`

`EEG_process_CPT_New.m`

`EEG_Recover_CPT_Triggers_From_EYE.m`


### Move EEG data from BOSS MASTER structure to `EEG_CPT_Prepro` directory on BIC cluster.  Now preprocess and run ICA.

dir: EEG_CPT_Prepro

`EEG_Clean_For_ICA.m` +job Clean data in prep for ICA (for broadband muscle noise analysis set analysisType=0, for main ICA analyses set analysisType=1)

dir: EEG_Processed_Cleaned_For_ICA

`EEG_AMICA.m` +job Run ICA on data

dir: EEG_ICA_50Hz_LP

`EEG_Dipfit.m' +job Do dipole fitting in ICA data

dir: EEG_ICA_50Hz_LP_DIPFIT


### Run Time Frequency Analyses [CLEAN UP AND RE-RUN THESE SCRIPTS]

`EEG_TFA_Generate_ERSPs.m` +job generates ERSPS for anticipatory (no baseline corr) and stress response (baseline corr)

dir: Time_Freq_results_1-30Hz_ICLabel_Dipfit_NewBL
dir: Time_Freq_results_1-30Hz_ICLabel_Dipfit_No_BL_Corr

`EEG_TFA_Compile_ERSPs.m` Compiles ERSPs into a single matrix [need to adjust all the analysis type stuff here - correct but inconsistent]

dir: Data_Compiled/ GRAND_ERSP_1-30Hz_ICA_ICLabel_Dipfit_50HzLP_NewBL.mat
dir: Data_Compiled/ GRAND_ERSP_1-30Hz_ICA_ICLabel_Dipfit_50HzLP_NoBlCorr.mat

`EEG_TFA_Stats_Resample_ERSP_Anticipatory.m` +job Run resampled ERSP data for anticipatory (baseline) period only

dir: Data_Compiled/ 'STATS_WITHIN_Resampled_ERSP_ANOVA_30Hz_NewBL_BASE_ONLY_' thisFreqName '.mat'

`EEG_TFA_Plot_Topos_ERSPS_Anticipatory.m` Plots topos for anticipatory activity (averages ERSPs over freq bands and baseline period)

dir: Plots/ 'EEG_ERSP_1-30Hz_Topos_Brain70_Dip15_TimeGraded_BASE_ONLY' thisFreqName '.eps'

`EEG_TFA_Stats_Resample_ERSP_Response.m` +job Run resampled ERSP data for response activity (averages ERSPs over freq bands and early/mid/late/rec phases)

dir: Data_Compiled/ 'STATS_WITHIN_Resampled_ERSP_ANOVA_30Hz_NewBL_TimeGrad' thisFreqName '.mat'

`EEG_TFA_Plot_Topos_ERSPS_Response.m` Plots topos for stress response activity (averages ERSPs over freq bands and early/mid/late/rec phases)

dir: Plots/ 'EEG_ERSP_1-30Hz_Topos_Brain70_Dip15_TimeGradedRec' thisFreqName '.eps'

**HERE**

`EEG_TFA_Stats_ERSP_Post_Hocs.m` ??????

`EEG_TFA_Stats_ERSP_Post_Hocs_Alpha.m` ???????

`EEG_TFA_Stats_ERSP_Post_Hocs_Delta.m` ??????



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




Useful misc EEG scripts.

`EEG_ICLabel_Get_Classification_Stats.m` Get a summary of IC classification across all subjects and conditions.




## PUPILLOMETRY

`EYE_Compile_Pupil.m` Grabs the raw eyelink data (edfs), identifies start/end points and exports data into CPT_EYE_Master.mat. Note this script lives on BOSS cluster.  MOVE master mat over to BIC05. 

`EYE_Stats_Resample.m` +job Runs resampled ANOVAs + pairwise comparisons on pupil size data 

`EYE_Plot_Main_Figs_Analyses.m` Plot Fig 8 pupil size plots w/stats (resampled)

`EYE_Stats_Resample_Averaged_Immersion_Phase.m` Runs resampled ANOVAs on the averaged immersion phase 



## PHYSIO

`PHYSIO_Prepro_Extract_Interpolate_MEAP_Data.m` Extracts data from RAW MEAP files, interpolates/normalizes each measure to 195 s (1 Hz SR).  Note this script normally lives on the BOSS cluster. Generates PHYSIO_MASTER_FINAL.mat on BOSS Cluster which I transfer to BIC05.

`PHYSIO_Stats_Resample.m` +job Run resampled stats analyses

`PHYSIO_Plot_Main_Figs_Analyses.m` Plot Figs 4-7 w/stats

`PHYSIO_Stats_Resample_3way.m` +job Run resampled stats analysis with 3-way ANOVAs for supplemental info

`PHYSIO_Plot_Main_Figs_Analyses_3way.m` Plot Figs with 3-way ANOVA results for supplemental info 

`PHYSIO_Get_Baseline_Data_For_Table.m` Extract "baseline" measures to plot in Table




## SELF REPORT (PAIN)

`SELF_REPORT_Stats_Resample.m` Runs stats on self-reported pain data [don't think we ended up using this coz ANOVA unnecessary given floor fx]

`SELF_REPORT_Plot.m` Plot self-reported pain ratings 




## MISC/DEPENDENCIES

`Demographic_Info.m` Compiles demographic info for presentation

`my_fxcomb.m` Neil's comb filter

`my_fixtrap.m` Neil's trapizoidal filter

`shadedErrorBar.m` Creates exactly that (borrowed)

`simple_mixed_anova.m` Does that (borrowed)






















###################################################################

## SCRIPTS NOT USED FOR ANALYSES/REPORTING IN MANUSCRIPT + OLD STUFF TO REMOVE!

`Physio_Stats_Resample.m` + job  Compute resampled t-test stats for all physio measures (required for plots)

`Physio_Plot.m` Generate plots for all physio measures (regular)

`Physio_Plot_Compare_Within_Session.m` Generate within condition comparision plots (paired with GLMMs)

`Physio_Convert_To_LF.m` Convert data to long format for GLMM analyses (not included in manuscript)

`Classify_Stress_Rank_Order_Analysis.m` Perform rank order analyses on the physio data only

`Classify_Stress_Rank_Order_Plot.m` Plot rank order analysis for each physio measure including all 10 trials

`Classify_Stress_Rank_Order_Plot_Individual_Trials.m` Plot rank order analysis for each physio measure separate for each CPT/WPT trial pair.

`Physio_Interactions.m` Run quick stats to test for interactions between induced stress and evoked stress across different cardiac measures

`Physio_Plot_Compare_Within_Session_With_Stats_ANOVA.m` Create physio plots for manuscript


`EYE_Plot_Pupil_Group.m` Compare pupil diameter grouped by condition (1 plot per trial, just pairwise comparisons)

`EYE_Plot_Pupil_Within_Cond_Comparisons.m` Compare pupil diameter with ANOVA then pairwise comparisons (for manuscript)

`EYE_Plot_Pupil_Individual.m` Individual pupil diameter plots (saves images in subfolders in plots, useful for determining which subjects have good/bad data)

`EYE_Stats_Resample.m` Compute resampled stats for eye data (pairwise comparisons only)

`EYE_Stats_Reasmple_Within_ANOVA.m` + job Compute resampled stats for manuscript (ANOVA + Pairwise comparisons)

`EYE_Stats_Resample_Within_ANOVA_Avg.m` Additional analysis averaged across 

`EYE_Convert_to_LF.m` Convert eye-tracker data from wide format to long format for analysis in R

`Self_Report_Stats_Resample.m` Compute resampled stats

`Self_Report_Stats_Resample_Within_Cond.m` Compute resampled stats within condition (??)