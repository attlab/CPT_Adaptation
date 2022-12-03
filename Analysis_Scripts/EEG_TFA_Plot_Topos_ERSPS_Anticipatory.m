%{
EEG_TFA_Plot_Topos_ERSPS_Anticipatory
Author: Tom Bullock, UCSB Attention Lab
Date: 10.12.20 (updated 12.02.22)

Plot baseline activity across the freq bands


%}

clear
close all

% %load eeglab 
% eeglabDir = '/home/bullock/Toolboxes/eeglab2019_1'; 
% cd(eeglabDir)
% eeglab

% set dirs
%parentDir = '/home/bullock/BOSS/CPT_Adaptation';
parentDir = '/home/bullock/BOSS/CPT_Adaptation/EEG_RERUN';
sourceDir = [parentDir '/' 'Data_Compiled'];
destDir = [parentDir '/' 'Plots'];

% import permuted stats?
usePermStats=1;
if usePermStats==0
    disp('NOT USING PERM STATS!!! CAUTION!')
end

% load compiled ERSP dataset
load([sourceDir '/' 'GRAND_ERSP_1-30Hz_ICA_ICLabel_Dipfit_50HzLP_NoBlCorr.mat'])

% rename var
ersp = erspAll;

% loop through freqs
for iFreq=1:4 %was 4
    
    % create figure
    h=figure;
    set(gcf, 'Units', 'Normalized', 'OuterPosition',[0 0.0282 0.2288 0.9446]); 
    
    % freq band specific settings
    if iFreq==1
        theseFreqs = 1:3;
        theseMapLimits = [-6,8];
        thisFreqName = 'Delta';
    elseif iFreq==2
        theseFreqs = 4:7;
        theseMapLimits = [-10,4];
        thisFreqName = 'Theta';
    elseif iFreq==3
        theseFreqs = 8:14;
        theseMapLimits = [-8,2];
        thisFreqName = 'Alpha';
    elseif iFreq==4
        theseFreqs = 15:30;
        theseMapLimits = [-16,-2];
        thisFreqName = 'Beta';
    end
    
    % loop through trials (exposures) and conditions (CPT/WPT)
    cnt=0;
    for iExposures=1:5
        for iTimes=1 % only plotting one time-frame, so this is redundant, but i left in anyway
            for iCond=1:2
                
                % select times for averaging over
                theseTimes = 1:39;
                
                % generate plot titles
                if      iCond==1 && iTimes==1; thisTitle='CPT B';
                elseif  iCond==2 && iTimes==1; thisTitle='WPT B';
                end
                
                % add to counter
                cnt=cnt+1;
                
                % create vector 
                cntVec = [1,2,4,5,7,8,10,11,13,14]+.5;
                
                % create subplot
                subplot(6,3,cntVec(cnt));
                
                % specify data for plot
                theseData = squeeze(mean(mean(mean(ersp(:,iCond,iExposures,:,theseFreqs,theseTimes),1),5),6));
                
                % creat a quick summary of activation for reality check
                %dataSummary(iExposures,iCond) = mean(theseData);
                
                % generate plot
                topoplot(theseData,chanlocs,...
                    'maplimits',theseMapLimits,...
                    'electrodes','on')
                %cbar
                
            end
        end
    end
    
    
    % add ANOVA statistical comparisions
    clear condVec trialVec intVec
    
    for iTimes=1
        
        % select times
        theseTimes = 2:40; % baseline
        
        % select stats to use (compute on the fly OR load resampled?)
        if usePermStats==1
            
            load([sourceDir '/' 'STATS_WITHIN_Resampled_ERSP_ANOVA_30Hz_NewBL_BASE_ONLY_' thisFreqName '.mat'])
            for iChan=1:63
                condVec(iChan,iTimes) =  allANOVA(iFreq,iChan).var1.pValueANOVA;
                trialVec(iChan,iTimes) = allANOVA(iFreq,iChan).var2.pValueANOVA;
                intVec(iChan,iTimes) = allANOVA(iFreq,iChan).varInt.pValueANOVA;
            end
            
        else
            
            % add resample toolbox to path
            addpath(genpath('/home/bullock/BOSS/CPT_Adaptation/resampling'))
            
            % name variables
            var1_name = 'cond';
            var1_levels = 2;
            var2_name = 'trial';
            var2_levels = 5;
            
            % loop through all channels
            for iChan=1:63
                
                observedData = [squeeze(mean(mean(ersp(:,1,:,iChan,theseFreqs,theseTimes),5),6)),squeeze(mean(mean(ersp(:,2,:,iChan,theseFreqs,theseTimes),5),6))];
                
                % run ANOVA
                statOutput = teg_repeated_measures_ANOVA(observedData,[var1_levels var2_levels],{var1_name, var2_name});
                
                % create vectors of main and int p-values (this will do)
                condVec(iChan, iTimes) = statOutput(1,4);
                trialVec(iChan,iTimes) = statOutput(2,4);
                intVec(iChan, iTimes) = statOutput(3,4);
                
            end
            
        end
        
    end
    
    clear cntVec
    
    % plot ANOVA results onto topos (cond, trial, interaction)
    for iTimes=1
        for iPlot=1:3
            
            if      iPlot==1; theseData = condVec(:,iTimes); plotPos = 16; thisTitle = 'Cond';
            elseif  iPlot==2; theseData = trialVec(:,iTimes); plotPos = 17; thisTitle = 'Trial';
            elseif  iPlot==3; theseData = intVec(:,iTimes); plotPos = 18; thisTitle = 'Int';
            end
            
            % convert p-vals into a vector of 0's (ns) and 1's (sig)
            for t=1:length(theseData) 
                if theseData(t)<.05
                    statVec(t)=1;
                else
                    statVec(t)=0;
                end
            end
            
            % generate subplot
            t=subplot(6,3,plotPos);
            
            %title(thisTitle);
            
            % plot data
            topoplot(statVec,chanlocs,...
                'maplimits',[0,1],...
                'electrodes','on')
            
            % moves ANOVA plots down slightly
            t.Position(2) = .05;
            
            clear statVec theseData
            
        end
    end
    
    saveas(h,[destDir '/' 'EEG_ERSP_1-30Hz_Topos_Brain70_Dip15_TimeGraded_BASE_ONLY' thisFreqName '.eps'],'epsc')

end