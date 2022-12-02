%{
PHYSIO_Prepro_Extract_Interpolate_MEAP_Data
Author: Tom Bullock, UCSB Attention Lab
Date: 12.01.22

Notes: This script loops through the MEAP data for all subjects and
sessions in the correct temporal order, computes the various physio
measures and interpolates into a standardized format. All measures saved in
a "Master" file.  

Try/Catch statements necessary because some subs are missing measures e.g.
BP.

%}

clear
close all

% add paths
addpath(genpath('/data/DATA_ANALYSIS/All_Dependencies'))

% select subjects
subjects = [108,111,114,116,117,118,119,120,121,123,125,127,128,130,132,...
    133,135,136,138,139,140,144,146,147,148,149,150,151,154,155,156,157,158,...
    160,161]; 

% set dirs
sourceDirMEAP = '/data/DATA_ANALYSIS/BOSS_PREPROCESSING/PHYSIO/MEAPED_Physio/CPT_MEAPED_DATA_FINAL';
sourceDirHF = '/data/DATA_ANALYSIS/BOSS_PREPROCESSING/PHYSIO/MEAPED_Physio/neil_hf_analyses/HF_Files_30';
sourceDirTaskOrder = '/bigboss/BOSS/Projects/CPT_Adaptation/Data_Compiled';
destDir = '/bigboss/BOSS/Projects/CPT_Adaptation/Data_Compiled';

% load subject event order (determine CPT trial order)
load([sourceDirTaskOrder '/' 'Task_Order.mat'])

% loop through subs, generate measures, compile into matrices
for iSub=1:length(subjects)
    sjNum = subjects(iSub)
    
    for iOrder=1:5 % CPT/WPT trial order

        for iSession=1:2 % CPT=1, WPT=2
            
            % clear vars
            clear hr bp pp bp bp1 tpr co sv lvet
            
            % find the task order
            clear rowIndex thisTemporalTaskOrder
            rowIndex = find(taskOrderStruct.sjNums==sjNum);
            thisTemporalTaskOrder = squeeze(taskOrderStruct.allTaskOrder(rowIndex,iSession,:));
            
            % add subject exception
            if sjNum==120&&iSession==1; thisTemporalTaskOrder{2} = 'cv';end
            
            % load MEAP data file
            thisFile =  dir([sourceDirMEAP '/' sprintf('sj%d',sjNum) '/' sprintf('sess%d',iSession+1) '/' sprintf('sj%d_se%02d_%s_*.mea.mat',sjNum,iSession+1,thisTemporalTaskOrder{iOrder+1})]);
            meap = load([thisFile.folder '/'  thisFile.name]);
              
            
            
            % HF PROCESSING:
            % load HF file (if exists)
            try
            thisFileHF = dir([sourceDirHF '/' sprintf('sj%d_se%02d_%s_*.mat',sjNum,iSession+1,thisTemporalTaskOrder{iOrder+1})]);
                all_hf = load([thisFileHF.folder '/' thisFileHF.name]);
            catch
                all_hf=[];
            end
            
            % downsample HF from 2000 Hz to 1000 Hz
            try
                all_hf_ds.resid_HF=all_hf.resid_HF(1:2:end);
                all_hf_ds.resid_t=all_hf.resid_t(1:2:end);
            catch
                all_hf_ds=[];
            end
            
            % create hf vector from resid_HF (not exactly 19500 samples, so
            % pre pad vector with NaNs for consistency with other measures
            % note that first 30 secs of resid_HF are NaNs because modelling)
            try
                %hf = NaN(1,19500);
                hf = all_hf_ds.resid_HF(1:19000); % chop final 5k samples (5 s data) coz crazy modeling artifacts 
            catch
                hf=NaN(1,19000); % if no HF data for sub, then NaNs
            end
            %hf = hf(1:19000); 
            hf = hf(1:100:19000); % resample to 1 Hz
            
            
            
            % BP PROCESSING:
            % downsample BP to 1Hz and remove end of time-series (set to
            % 1:19400 - interpolation not necessary for BP).  If no BP for
            % subject, then replace with a row vector of NaNs.  Also
            % extract SBP and DBP indices                
            SBP = [];
            DBP = [];
            Peak_Times = [];
            
            if ismember(sjNum,[120,123,140]) % subs without BP data
                bp=NaN(1,195);
            else
                try
                    bp= resample(meap.bp_data(1:end),1,1000); % should be 195 long
                    for iBeat=1:length(meap.systole_indices)                      
                        SBP(iBeat) = meap.mea_bp_matrix(iBeat,meap.systole_indices(iBeat));
                        DBP(iBeat) = meap.mea_bp_matrix(iBeat,meap.diastole_indices(iBeat));
                        Peak_Times = meap.peak_times;
                    end            
                catch
                    bp = NaN(1,195);
                    SBP = NaN;
                    DBP = NaN;
                    Peak_Times = NaN;
                end
            end
            bp = bp(1:195); % if BP slightly longer, crop to 195 s data
            
            
            
            % PEP PROCESSING: 
            % create a new PEP to deal with updating issue in MEAP
            meap.new_pep = meap.b_indices - meap.dzdt_pre_peak;
            
            
            
            % HR, PEP, TPR, LVET, CO, SV PROCESSING: 
            % intepolate to normalize data to 195 s (not all measures present for all subs, hence try/catch)               
            hr=interp1(double(meap.peak_times),double(meap.mea_hr),linspace(0,195,19500)); 
            pp=interp1(double(meap.peak_times),double(meap.new_pep),linspace(0,195,19500));
            lvet=interp1(double(meap.peak_times),double(meap.lvet),linspace(0,195,19500));
             
            try
                co=interp1(double(meap.peak_times),double(meap.resp_corrected_co),linspace(0,195,19500));
            catch
                co=NaN(1,19500);
            end
            
            try
                sv=interp1(double(meap.peak_times),double(meap.resp_corrected_sv),linspace(0,195,19500));
            catch
                sv=NaN(1,19500);
            end
            
            try
                tpr=interp1(double(meap.peak_times),double(meap.resp_corrected_tpr),linspace(0,195,19500));
            catch
                tpr = NaN(1,19500);
            end
            
            % resample all measures to 1 Hz
            hr = hr(1:100:19500);
            pp = pp(1:100:19500);
            lvet = lvet(1:100:19500);
            co = co(1:100:19500);
            sv = sv(1:100:19500);
            tpr = tpr(1:100:19500);
            
            
            
            % compile "master" mats for measures
            all_BP(iSub,iOrder,iSession,:) = bp;
            all_HR(iSub,iOrder,iSession,:) = hr;
            all_PEP(iSub,iOrder,iSession,:) = pp;
            all_TPR(iSub,iOrder,iSession,:) = tpr;
            all_LVET(iSub,iOrder,iSession,:) = lvet;
            all_CO(iSub,iOrder,iSession,:) = co;
            all_SV(iSub,iOrder,iSession,:) = sv;
            all_HF(iSub,iOrder,iSession,:) = hf;
            
            % compile separate struct for SBP/DBP measuring purposes
            all_SBP_DBP(iSub,iOrder,iSession).SBP = SBP;
            all_SBP_DBP(iSub,iOrder,iSession).DBP = DBP;
            all_SBP_DBP(iSub,iOrder,iSession).Peak_Times = Peak_Times;
            
        end
    end
end

%disp('not saving!!!')
save([destDir '/' 'PHYSIO_MASTER_FINAL.mat'],'all_BP','all_HR','all_PEP','all_TPR','all_LVET','all_CO','all_SV','all_HF','subjects','all_SBP_DBP')