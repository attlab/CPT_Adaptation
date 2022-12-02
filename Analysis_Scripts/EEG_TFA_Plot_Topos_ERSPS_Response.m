%{
Time_Freq_Analysis_ERSP_Plot_Topos_WITHIN_ANOVA_Time_Graded
Author: Tom Bullock, UCSB Attention Lab
Date: 10.11.20

Create a grip of plots that divides CPT immersion period into
early/middle/late (also possibly bl and rec)

***THIS PLOTS EARLY, MID, LATE and REC!*** 

%}

% %load eeglab
% eeglabDir = '/home/bullock/Toolboxes/eeglab2019_1'; 
% cd(eeglabDir)
% eeglab

clear
close all

% set dirs
parentDir = '/home/bullock/BOSS/CPT_Adaptation';
sourceDir = [parentDir '/' 'Data_Compiled'];
destDir = [parentDir '/' 'Plots'];

% baseline correction in plotting script?
blCorrectInPlotScript=0;

% import permuted stats?
usePermStats=1;
if usePermStats==0
    disp('NOT USING PERM STATS!!! CAUTION!')
end

% load compiled ERSP dataset and perm stats
analysisType=2; % 1 = 1-100 Hz, 2 = 1-30 Hz

if analysisType==1
    load([sourceDir '/' 'GRAND_ERSP_1-100Hz_NewBL.mat' ])
    %load([sourceDir '/' 'STATS_EEG_ERSP_1-100Hz_TOPOS.mat'])
    %load([sourceDir '/' 'STATS_WITHIN_Resampled_ERSP_ANOVA_100Hz.mat'])%Bl
    %calculated in plotting script)
    load([sourceDir '/' 'STATS_WITHIN_Resampled_ERSP_ANOVA_100Hz_NewBL.mat']) % new (bl calculated in ERSP compute script)
else
    %load([sourceDir '/' 'GRAND_ERSP_1-30Hz_ICA_ICLabel_Dipfit_50HzLP.mat']) %original
    load([sourceDir '/' 'GRAND_ERSP_1-30Hz_ICA_ICLabel_Dipfit_50HzLP_NewBL.mat'])

    %load([sourceDir '/' 'STATS_EEG_ERSP_1-30Hz_ICA_ICLabel_Dipfit_50HzLP.mat'])
    %load([sourceDir '/' 'STATS_WITHIN_Resampled_ERSP_ANOVA_30Hz.mat']) % original (BL calculated in plotting script)
    %load([sourceDir '/' 'STATS_WITHIN_Resampled_ERSP_ANOVA_30Hz_NewBL.mat']) % new (bl calculatd in ERSP compute script)
    
end




% analysis specific settings
if analysisType==1
    freqIdx=1:5;
else
    freqIdx=1:4;
end

% baseline correct
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
for iFreq=freqIdx
    
    h=figure;
    set(gcf, 'Units', 'Normalized', 'OuterPosition',[0 0.2947 0.6902 0.6781]); % replace 1 with .8 to get back to normal
    
    % original settings w/3 columns [0 0.0049 0.7090 0.9679]
    %[0 0.2947 0.6902 0.6781]
    
    if analysisType==1
        
        if iFreq==1
            theseFreqs = 1:3;
            %theseMapLimits = [-4,4];
            theseMapLimits = [-6,0];
            thisFreqName = 'Delta';
        elseif iFreq==2
            theseFreqs = 4:7;
            %theseMapLimits = [-2,4];
            theseMapLimits = [-6,0];
            thisFreqName = 'Theta';
        elseif iFreq==3
            theseFreqs = 8:14;
            %theseMapLimits = [-1,3];
            theseMapLimits = [-6,0];
            thisFreqName = 'Alpha';
        elseif iFreq==4
            theseFreqs = 15:30;
            %theseMapLimits = [-1,5];
            theseMapLimits = [-6,2];
            thisFreqName = 'Beta';
        elseif iFreq==5
            theseFreqs=31:100;
            %theseMapLimits = [-1,10];
            theseMapLimits = [-6,2];
            thisFreqName = '30-100Hz';
        end
        
    else
        
        if iFreq==1
            theseFreqs = 1:3;
            %theseMapLimits = [-1,4];
            theseMapLimits = [-4,0];
            thisFreqName = 'Delta';
        elseif iFreq==2
            theseFreqs = 4:7;
            %theseMapLimits = [-1,2];
            theseMapLimits = [-4,0];
            thisFreqName = 'Theta';
        elseif iFreq==3
            theseFreqs = 8:14;
            %theseMapLimits = [-1,3];
            theseMapLimits = [-4,0];
            thisFreqName = 'Alpha';
        elseif iFreq==4
            theseFreqs = 15:30;
            %theseMapLimits = [-1,5];
            theseMapLimits = [-4,0];
            thisFreqName = 'Beta';
        end
        
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
                elseif  iTimes==5; theseTimes = 155:191; %    182:197;
                end
                
                % if doing 1-30 Hz analysis, shift times to compensate for
                % cut off at start of ERSP
                if analysisType>1
                    theseTimes=theseTimes-1;
                end
                
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
                
                cnt=cnt+1;
                %                 cntVec = [1,2,4,5,7,8,10,11,13,14];
                %                 subplot(5,3,cntVec(cnt))
                
                cntVec = [
                    1,2,4,5,7,8,10,11,...
                    13,14,16,17,19,20,22,23,...
                    25,26,28,29,31,32,34,35,...
                    37,38,40,41,43,44,46,47,...
                    49,50,52,53,55,56,58,59,...
                    ]+.5;
                    
%                     10,11,13,14,16,17,...
%                     19,20,22,23,25,26,...
%                     28,29,31,32,34,35,...
%                     37,38,40,41,43,44,...
%                     ]+.5;
                
                %subplot(5,10,cntVec(cnt):cntVec(cnt)+2)
                subplot(6,12,cntVec(cnt));
                
                
                
                %pause(1)
                theseData = squeeze(mean(mean(mean(ersp(:,iCond,iExposures,:,theseFreqs,theseTimes),1),5),6));
                
                %theseMapLimits = 'maxmin';
                
                %h=figure;
                
                topoplot(theseData,chanlocs,...
                    'maplimits',theseMapLimits,...
                    'electrodes','on')
                %cbar
                
%                   h=figure;
%                   topoplot(theseData,chanlocs);
%                   cbar
                
                %title(thisTitle)
                %cbar
                
                %end
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
            
%             
%             if iTimes~=5
%                 load([sourceDir '/' 'STATS_WITHIN_Resampled_ERSP_ANOVA_30Hz_NewBL_TimeGrad_Freq_' thisFreqName '.mat'])
%             else
%                 disp('Pulling REC stats from DIFFERENT mat file!!!')
%                 disp('Pulling REC stats from DIFFERENT mat file!!!')
%                 disp('Pulling REC stats from DIFFERENT mat file!!!')
%                 load([sourceDir '/' 'STATS_WITHIN_Resampled_ERSP_ANOVA_30Hz_NewBL_RecOnly_Freq_' thisFreqName '.mat'])
%             end
            
           
            
            for iChan=1:63
                condVec(iChan,iTimes) =  allANOVA(iFreq,iChan,iTimes-1).var1.pValueANOVA;
                trialVec(iChan,iTimes) = allANOVA(iFreq,iChan,iTimes-1).var2.pValueANOVA;
                intVec(iChan,iTimes) = allANOVA(iFreq,iChan,iTimes-1).varInt.pValueANOVA;
            end
            
        else
            
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
        for iPlot=1:3
            
            
            
            
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
    
    if analysisType==1
        saveas(h,[destDir '/' 'EEG_ERSP_1-100Hz_No_ICA_Topos_TimeGraded' thisFreqName '.eps'],'epsc')
    else
        saveas(h,[destDir '/' 'EEG_ERSP_1-30Hz_Topos_Brain70_Dip15_TimeGradedRec' thisFreqName '.eps'],'epsc')
    end
    
    
    
    
    
end












% 
% 
% 
% % plot freqs
% for iFreq=1 %freqIdx
%     
%     % stuff
%     if analysisType==1
%         if iFreq==1
%             theseFreqs = 1:3;
%             theseMapLimits = [-4,4];
%             thisFreqName = 'Delta';
%         elseif iFreq==2
%             theseFreqs = 4:7;
%             theseMapLimits = [-2,4];
%             thisFreqName = 'Theta';
%         elseif iFreq==3
%             theseFreqs = 8:14;
%             theseMapLimits = [-1,3];
%             thisFreqName = 'Alpha';
%         elseif iFreq==4
%             theseFreqs = 15:30;
%             theseMapLimits = [-1,5];
%             thisFreqName = 'Beta';
%         elseif iFreq==5
%             theseFreqs=31:100;
%             theseMapLimits = [-1,10];
%             thisFreqName = '30-100Hz';
%         end
%     elseif analysisType==3||analysisType==6
%         if iFreq==1
%             theseFreqs = 1:3;
%             theseMapLimits = [-1,4];
%             thisFreqName = 'Delta';
%         elseif iFreq==2
%             theseFreqs = 4:7;
%             theseMapLimits = [-1,2];
%             thisFreqName = 'Theta';
%         elseif iFreq==3
%             theseFreqs = 8:14;
%             theseMapLimits = [-1,3];
%             thisFreqName = 'Alpha';
%         elseif iFreq==4
%             theseFreqs = 15:30;
%             theseMapLimits = [-1,5];
%             thisFreqName = 'Beta';
%         end
%         
%         
%     end
%     
% %     if analysisType==1
% %         theseFreqs = 1:50;
% %         theseMapLimits = [-2,8];
% %         iFreq=5;
% %         thisFreqName='1-100Hz';
% %     end
%     
%     % plot topo
%     h=figure;
%     set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, .2, 0.70]);
%     
%     
%     cnt=0;
%     for iExposures=1:5
%         for iCond=1:2
%             for iTimes=2;%1:3
%                 %for iExposures=1:5
%                 if      iTimes==1; theseTimes = 10:24; %   10:24;%25:40;
%                 elseif  iTimes==2; theseTimes = 80:155; %   78:160;
%                 elseif  iTimes==3; theseTimes = 180:194; %    182:197;
%                 end
%                 
%                 % if doing 1-30 Hz analysis, shift times to compensate for
%                 % cut off at start of ERSP
%                 if analysisType>1
%                     theseTimes=theseTimes-1;
%                 end
%                 
%                 if      iCond==1 && iTimes==1; thisTitle='ICE Baseline';
%                 elseif  iCond==1 && iTimes==2; thisTitle='ICE CPT';
%                 elseif  iCond==1 && iTimes==3; thisTitle='ICE Recovery';
%                 elseif  iCond==2 && iTimes==1; thisTitle='WARM Baseline';
%                 elseif  iCond==2 && iTimes==2; thisTitle='WARM CPT';
%                 elseif  iCond==3 && iTimes==3; thisTitle='WARM Recovery';
%                 end
%                 
%                 cnt=cnt+1;
%                 cntVec = [1,2,4,5,7,8,10,11,13,14];
%                 subplot(5,3,cntVec(cnt))
%                 %pause(1)
%                 theseData = squeeze(mean(mean(mean(ersp(:,iCond,iExposures,:,theseFreqs,theseTimes),1),5),6));
%                 
%                 %theseMapLimits = 'maxmin';
%                 
%                 topoplot(theseData,chanlocs,...
%                     'maplimits',theseMapLimits)
%                 %title(thisTitle)
%                 %cbar
%                 
%                 %end
%             end
%         end
%     end
%     
% 
% 
% 
%     
%     theseMapLimits = [0,1];
%     
% %     if analysisType==1
% %         theseFreqs = 1:50;
% %     end
%     
%     % plot topo
%     %figure;
%     cnt=0;
%     for iExposures=1:5
%         for iTimes=2;%1:3
%             %for iExposures=1:5
% %             if      iTimes==1; theseTimes = 1:24;thisTitle = 'Baseline - Pairwise';
% %             elseif  iTimes==2; theseTimes = 78:160; thisTitle = 'Immersion - Pairwise';
% %             elseif  iTimes==3; theseTimes = 182:197; thisTitle = 'Recovery - Pairwise';
% %             end
%             
%             if      iTimes==1; theseTimes = 10:24; thisTitle = 'Baseline - Pairwise';
%             elseif  iTimes==2; theseTimes = 80:155; thisTitle = 'Immersion - Pairwise';
%             elseif  iTimes==3; theseTimes = 180:194; thisTitle = 'Recovery - Pairwise';
%             end
%             
%             % if doing 1-30 Hz analysis, shift times to compensate for
%             % cut off at start of ERSP
%             if analysisType>1
%                 theseTimes=theseTimes-1;
%             end
%             
%             cnt=cnt+1;
%             cntVec = [3,6,9,12,15];
%             subplot(5,3,cntVec(cnt))
%             
%             
% % %             %pause(1)
% %             theseData1 = squeeze(mean(mean(ersp(:,1,iExposures,:,theseFreqs,theseTimes),5),6)); %se01
% %             theseData2 = squeeze(mean(mean(ersp(:,2,iExposures,:,theseFreqs,theseTimes),5),6)); %se02
% %             theseData = ttest(theseData1,theseData2);
% %             disp('non-resampled stats used')
% 
%             theseData = squeeze(sigVec(iExposures,iFreq,:));
%             disp('resampled stats')
%             
%             
%             topoplot(theseData,chanlocs,...---
%                 'maplimits',theseMapLimits)
%             %title(thisTitle)
%             %cbar
%             
%             
%         end
%     end
%     
%     if analysisType==3
%         saveas(h,[destDir '/' 'EEG_ERSP_1-30_Brain80_Topos_' thisFreqName '.eps'],'epsc')
%     elseif analysisType==1
%         saveas(h,[destDir '/' 'EEG_ERSP_1-100Hz_No_ICA_Topos_' thisFreqName '.eps'],'epsc')
%     elseif analysisType==6
%         saveas(h,[destDir '/' 'EEG_ERSP_1-30Hz_Topos_Brain70_Dip15' thisFreqName '.eps'],'epsc')
%     end
% 
%     
%     %close all
%     
% end
