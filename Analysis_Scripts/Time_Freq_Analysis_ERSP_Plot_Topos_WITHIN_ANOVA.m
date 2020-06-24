%{
Time_Freq_Analysis_ERSP_Plot_Topos_WITHIN_ANOVA
Author: Tom Bullock
Date: 05.17.20

%}

% load eeglab
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

% load compiled ERSP dataset and perm stats
analysisType=1; % 1 = 1-100 Hz, 2 = 1-30 Hz

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
    load([sourceDir '/' 'STATS_WITHIN_Resampled_ERSP_ANOVA_30Hz_NewBL.mat']) % new (bl calculatd in ERSP compute script)
    
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
    set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.06, .18, .8]); % replace 1 with .8 to get back to normal
    
    
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
        for iCond=1:2
            for iTimes=2;
                %for iExposures=1:5
                if      iTimes==1; theseTimes = 10:24; %   10:24;%25:40;
                elseif  iTimes==2; theseTimes = 80:155; %   78:160;
                elseif  iTimes==3; theseTimes = 180:194; %    182:197;
                end
                
                % if doing 1-30 Hz analysis, shift times to compensate for
                % cut off at start of ERSP
                if analysisType>1
                    theseTimes=theseTimes-1;
                end
                
                if      iCond==1 && iTimes==1; thisTitle='ICE Baseline';
                elseif  iCond==1 && iTimes==2; thisTitle='ICE CPT';
                elseif  iCond==1 && iTimes==3; thisTitle='ICE Recovery';
                elseif  iCond==2 && iTimes==1; thisTitle='WARM Baseline';
                elseif  iCond==2 && iTimes==2; thisTitle='WARM CPT';
                elseif  iCond==3 && iTimes==3; thisTitle='WARM Recovery';
                end
                
                cnt=cnt+1;
                %                 cntVec = [1,2,4,5,7,8,10,11,13,14];
                %                 subplot(5,3,cntVec(cnt))
                
                cntVec = [1,4,7,10,13,16,19,22,25,28];
                
                subplot(6,6,cntVec(cnt):cntVec(cnt)+2)
                
                
                
                %pause(1)
                theseData = squeeze(mean(mean(mean(ersp(:,iCond,iExposures,:,theseFreqs,theseTimes),1),5),6));
                
                %theseMapLimits = 'maxmin';
                
                %h=figure;
                
                topoplot(theseData,chanlocs,...
                    'maplimits',theseMapLimits)
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
    
    
    if usePermStats==1

        clear condVec trialVec intVec

        for iChan=1:63
            condVec(iChan) =  allANOVA(iFreq,iChan).var1.pValueANOVA;
            trialVec(iChan) = allANOVA(iFreq,iChan).var2.pValueANOVA;
            intVec(iChan) = allANOVA(iFreq,iChan).varInt.pValueANOVA;
        end
        
    else
        
        addpath(genpath('/home/bullock/BOSS/CPT_Adaptation/resampling'))
        % name variables
        var1_name = 'cond';
        var1_levels = 2;
        var2_name = 'trial';
        var2_levels = 5;
        
        clear condVec trialVec intVec
        
        % loop through all channels
        for iChan=1:63
            
            observedData = [squeeze(mean(mean(ersp(:,1,:,iChan,theseFreqs,theseTimes),5),6)),squeeze(mean(mean(ersp(:,2,:,iChan,theseFreqs,theseTimes),5),6))];
            
            % run ANOVA
            statOutput = teg_repeated_measures_ANOVA(observedData,[var1_levels var2_levels],{var1_name, var2_name});
            
            % create vectors of main and int p-values (this will do)
            condVec(iChan) = statOutput(1,4);
            trialVec(iChan) = statOutput(2,4);
            intVec(iChan) = statOutput(3,4);
            
        end
        
    end
    
    
    
    % plot ANOVA results onto topos
    for iPlot=1:3
        
        if      iPlot==1; theseData = condVec; plotPos = 31:32;
        elseif  iPlot==2; theseData = trialVec; plotPos = 33:34;
        elseif  iPlot==3; theseData = intVec; plotPos = 35:36;
        end
        
        % convert p-vals into a vector of 0's (ns) and 1's (sig)
        for t=1:length(theseData)
            
            if theseData(t)<.05
                statVec(t)=1;
            else
                statVec(t)=0;
            end
               
        end
        
        t=subplot(6,6,plotPos);
        
        topoplot(statVec,chanlocs,...---
            'maplimits',[0,1])
        
        % moves ANOVA plots down slightly
        t.Position(2) = .05;
        
        clear statVec theseData
        
    end
    
    if analysisType==1
        saveas(h,[destDir '/' 'EEG_ERSP_1-100Hz_No_ICA_Topos_' thisFreqName '.eps'],'epsc')
    else
        saveas(h,[destDir '/' 'EEG_ERSP_1-30Hz_Topos_Brain70_Dip15' thisFreqName '.eps'],'epsc')
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
