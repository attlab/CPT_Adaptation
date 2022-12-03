%{
EEG_TFA_Plot_Topos_ERSPS_Response
Author: Tom Bullock, UCSB Attention Lab
Date: 10.11.20 (updated 12.02.22)

Create a group of plots that divides CPT immersion period into
early/middle/late/rec

%}

% %load eeglab
% eeglabDir = '/home/bullock/Toolboxes/eeglab2019_1'; 
% cd(eeglabDir)
% eeglab

clear
close all

% set dirs
%parentDir = '/home/bullock/BOSS/CPT_Adaptation';
parentDir = '/home/bullock/BOSS/CPT_Adaptation/EEG_RERUN';
sourceDir = [parentDir '/' 'Data_Compiled'];
destDir = [parentDir '/' 'Plots'];

% baseline correction in plotting script?
blCorrectInPlotScript=0; % no because already blc in ERSP

% import permuted stats?
usePermStats=1;
if usePermStats==0
    disp('NOT USING PERM STATS!!! CAUTION!')
end

% load compiled ERSP dataset and perm stats
load([sourceDir '/' 'GRAND_ERSP_1-30Hz_ICA_ICLabel_Dipfit_50HzLP_NewBL.mat'])


% baseline correct in script [no for ms, because already blc in ERSP]
if blCorrectInPlotScript==1
    if analysisType>1
        erspBL = mean(erspAll(:,:,:,:,:,25:39),6);
    else
        erspBL = mean(erspAll(:,:,:,:,:,26:40),6);
    end
    ersp = erspAll-erspBL;
else
    ersp = erspAll;
    disp('BL CORRECTION IN PLOTTING SCRIPT DISABLED!!!!')
    pause(1)
end


% loop through freqs
for iFreq=1:4
    
    % create figure
    h=figure;
    set(gcf, 'Units', 'Normalized', 'OuterPosition',[0 0.2947 0.6902 0.6781]);
    
    % select frequencies to average over
    if iFreq==1
        theseFreqs = 1:3;
        theseMapLimits = [-4,0];
        thisFreqName = 'Delta';
    elseif iFreq==2
        theseFreqs = 4:7;
        theseMapLimits = [-4,0];
        thisFreqName = 'Theta';
    elseif iFreq==3
        theseFreqs = 8:14;
        theseMapLimits = [-4,0];
        thisFreqName = 'Alpha';
    elseif iFreq==4
        theseFreqs = 15:30;
        theseMapLimits = [-4,0];
        thisFreqName = 'Beta';
    end
    
    
    cnt=0;
    for iExposures=1:5
        for iTimes=2:5
            for iCond=1:2
                
                %for iExposures=1:5
                if      iTimes==1; theseTimes = 10:24; % baseline   
                elseif  iTimes==2; theseTimes = 65:94; % early immersion
                elseif  iTimes==3; theseTimes = 95:124; % mid immersion
                elseif  iTimes==4; theseTimes = 125:154; % late immersion
                elseif  iTimes==5; theseTimes = 155:191; %  recovery
                end
                
                % if doing 1-30 Hz analysis, shift times to compensate for
                % cut off at start of ERSP
                %if analysisType>1
                    theseTimes=theseTimes-1;
                %end
                
                if      iCond==1 && iTimes==1; thisTitle='CPT B';
                elseif  iCond==1 && iTimes==2; thisTitle='CPT E';
                elseif  iCond==1 && iTimes==3; thisTitle='CPT M';
                elseif  iCond==1 && iTimes==4; thisTitle='CPT L';
                elseif  iCond==1 && iTimes==5; thisTitle='CPT R';
                elseif  iCond==2 && iTimes==1; thisTitle='WPT B';
                elseif  iCond==2 && iTimes==2; thisTitle='WPT E';
                elseif  iCond==2 && iTimes==3; thisTitle='WPT M';
                elseif  iCond==2 && iTimes==4; thisTitle='WPT L';
                elseif  iCond==2 && iTimes==5; thisTitle='WPT R';
                end
                
                % counter
                cnt=cnt+1;

                % counter vec
                cntVec = [
                    1,2,4,5,7,8,10,11,...
                    13,14,16,17,19,20,22,23,...
                    25,26,28,29,31,32,34,35,...
                    37,38,40,41,43,44,46,47,...
                    49,50,52,53,55,56,58,59,...
                    ]+.5;
                    
                % make subplot
                subplot(6,12,cntVec(cnt));
                
                % select data for plotting
                theseData = squeeze(mean(mean(mean(ersp(:,iCond,iExposures,:,theseFreqs,theseTimes),1),5),6));
                
                %theseMapLimits = 'maxmin';
                                
                topoplot(theseData,chanlocs,...
                    'maplimits',theseMapLimits,...
                    'electrodes','on')
                
                %title(thisTitle)
                %cbar
                
            end
        end
    end
    
    
    %% add ANOVA statistical comparisions
    clear condVec trialVec intVec
    
    for iTimes=2:5
        
        %for iExposures=1:5
        if      iTimes==1; theseTimes = 10:24; % baseline
        elseif  iTimes==2; theseTimes = 65:94; % early immersion
        elseif  iTimes==3; theseTimes = 95:124; % mid immersion
        elseif  iTimes==4; theseTimes = 125:154; % late immersion
        elseif  iTimes==5; theseTimes = 155:191; %    182:197;
        end
        
        if usePermStats==1
            
            load([sourceDir '/' 'STATS_WITHIN_Resampled_ERSP_ANOVA_30Hz_NewBL_TimeGrad' thisFreqName '.mat'])           
            
            for iChan=1:63
                condVec(iChan,iTimes) =  allANOVA(iFreq,iChan,iTimes-1).var1.pValueANOVA;
                trialVec(iChan,iTimes) = allANOVA(iFreq,iChan,iTimes-1).var2.pValueANOVA;
                intVec(iChan,iTimes) = allANOVA(iFreq,iChan,iTimes-1).varInt.pValueANOVA;
            end
            
        else
            
            % add resample to path
            addpath(genpath('/home/bullock/BOSS/CPT_Adaptation/resampling'))
            
            % name variables
            var1_name = 'cond';
            var1_levels = 2;
            var2_name = 'trial';
            var2_levels = 5;
            
            %clear condVec trialVec intVec
            
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
    
    % plot ANOVA results onto topos
    for iTimes=2:5
        for iPlot=1:3 % condition, trial, interaction
            
            if      iPlot==1; theseData = condVec(:,iTimes); plotPos = [61.2,64.2,67.2,70.2]; thisTitle = 'Cond';
            elseif  iPlot==2; theseData = trialVec(:,iTimes); plotPos = [62,65,68,71]; thisTitle = 'Trial';
            elseif  iPlot==3; theseData = intVec(:,iTimes); plotPos = [62.8,65.8,68.8,71.8]; thisTitle = 'Int';
            end
            
            % convert p-vals into a vector of 0's (ns) and 1's (sig)
            for t=1:length(theseData)
                if theseData(t)<.05
                    statVec(t)=1;
                else
                    statVec(t)=0;
                end      
            end
            
            t=subplot(6,12,plotPos(iTimes-1));
            
            %title(thisTitle);
            
            topoplot(statVec,chanlocs,...
                'maplimits',[0,1],...
                'electrodes','on')
            
            % moves ANOVA plots down slightly
            %t.Position(2) = .05;
            
            clear statVec theseData
            
        end
    end
    
    % generate plots
    saveas(h,[destDir '/' 'EEG_ERSP_1-30Hz_Topos_Brain70_Dip15_TimeGradedRec' thisFreqName '.eps'],'epsc')

end