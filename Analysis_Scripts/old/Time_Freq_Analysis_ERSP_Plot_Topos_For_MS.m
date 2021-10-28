%{ 
CPT_Plot_Topos
Author: Tom Bullock
Date: 09.18.18
%}


eeglabDir = '/home/bullock/Toolboxes/eeglab2019_1'; 
cd(eeglabDir)
eeglab

clear
close all


% set dirs
parentDir = '/home/bullock/BOSS/CPT_Adaptation';
sourceDir = [parentDir '/' 'Data_Compiled'];
destDir = [parentDir '/' 'Plots'];




% load compiled ERSP dataset & chanlocs (only 1 and 6 for now)
analysisType=1;

if analysisType==1
    load([sourceDir '/' 'GRAND_ERSP_1-100Hz.mat' ])  
    load([sourceDir '/' 'STATS_EEG_ERSP_1-100Hz_TOPOS.mat'])
elseif analysisType==2
    load([sourceDir '/' 'GRAND_ERSP_1-30Hz_ICA_Occ_Rej.mat' ])
elseif analysisType==3
    load([sourceDir '/' 'GRAND_ERSP_1-30Hz_ICA_Brain_80.mat' ])
    load([sourceDir '/' 'STATS_EEG_ERSP_1-30Hz_ICA_Brain_80.mat'])
elseif analysisType==4
    load([sourceDir '/' 'GRAND_ERSP_1-30Hz_ICA_Brain_60.mat' ])
elseif analysisType==5
    load([sourceDir '/' 'GRAND_ERSP_1-30Hz_ICA_Brain_Other_Top.mat' ])
elseif analysisType==6
    load([sourceDir '/' 'GRAND_ERSP_1-30Hz_ICA_ICLabel_Dipfit_50HzLP.mat'])
    load([sourceDir '/' 'STATS_EEG_ERSP_1-30Hz_ICA_ICLabel_Dipfit_50HzLP.mat'])
end

% analysis specific settings
if analysisType==1
    freqIdx=1:5;
else
    freqIdx=1:4;
end

% baseline correct
if analysisType>1
    erspBL = mean(erspAll(:,:,:,:,:,25:39),6);
else
    erspBL = mean(erspAll(:,:,:,:,:,26:40),6);
end
ersp = erspAll-erspBL;

% remove FT elects?



% plot freqs
for iFreq=1;%freqIdx
    
    % stuff
    if analysisType==1
        if iFreq==1
            theseFreqs = 1:3;
            theseMapLimits = [-4,4];
            thisFreqName = 'Delta';
        elseif iFreq==2
            theseFreqs = 4:7;
            theseMapLimits = [-2,4];
            thisFreqName = 'Theta';
        elseif iFreq==3
            theseFreqs = 8:14;
            theseMapLimits = [-1,3];
            thisFreqName = 'Alpha';
        elseif iFreq==4
            theseFreqs = 15:30;
            theseMapLimits = [-1,5];
            thisFreqName = 'Beta';
        elseif iFreq==5
            theseFreqs=31:100;
            theseMapLimits = [-1,10];
            thisFreqName = '30-100Hz';
        end
    elseif analysisType==3||analysisType==6
        if iFreq==1
            theseFreqs = 1:3;
            theseMapLimits = [-1,4];
            thisFreqName = 'Delta';
        elseif iFreq==2
            theseFreqs = 4:7;
            theseMapLimits = [-1,2];
            thisFreqName = 'Theta';
        elseif iFreq==3
            theseFreqs = 8:14;
            theseMapLimits = [-1,3];
            thisFreqName = 'Alpha';
        elseif iFreq==4
            theseFreqs = 15:30;
            theseMapLimits = [-1,5];
            thisFreqName = 'Beta';
        end
        
        
    end
    
%     if analysisType==1
%         theseFreqs = 1:50;
%         theseMapLimits = [-2,8];
%         iFreq=5;
%         thisFreqName='1-100Hz';
%     end
    
    % plot topo
    h=figure;
    set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, .2, 0.70]);
    
    
    cnt=0;
    for iExposures=1:5
        for iSession=1:2
            for iTimes=2;%1:3
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
                
                if      iSession==1 && iTimes==1; thisTitle='ICE Baseline';
                elseif  iSession==1 && iTimes==2; thisTitle='ICE CPT';
                elseif  iSession==1 && iTimes==3; thisTitle='ICE Recovery';
                elseif  iSession==2 && iTimes==1; thisTitle='WARM Baseline';
                elseif  iSession==2 && iTimes==2; thisTitle='WARM CPT';
                elseif  iSession==3 && iTimes==3; thisTitle='WARM Recovery';
                end
                
                cnt=cnt+1;
                cntVec = [1,2,4,5,7,8,10,11,13,14];
                subplot(5,3,cntVec(cnt))
                %pause(1)
                theseData = squeeze(mean(mean(mean(ersp(:,iSession,iExposures,:,theseFreqs,theseTimes),1),5),6));
                
                %theseMapLimits = 'maxmin';
                
                topoplot(theseData,chanlocs,...
                    'maplimits',theseMapLimits)
                %title(thisTitle)
                %cbar
                
                %end
            end
        end
    end
    



    
    theseMapLimits = [0,1];
    
%     if analysisType==1
%         theseFreqs = 1:50;
%     end
    
    % plot topo
    %figure;
    cnt=0;
    for iExposures=1:5
        for iTimes=2;%1:3
            %for iExposures=1:5
%             if      iTimes==1; theseTimes = 1:24;thisTitle = 'Baseline - Pairwise';
%             elseif  iTimes==2; theseTimes = 78:160; thisTitle = 'Immersion - Pairwise';
%             elseif  iTimes==3; theseTimes = 182:197; thisTitle = 'Recovery - Pairwise';
%             end
            
            if      iTimes==1; theseTimes = 10:24; thisTitle = 'Baseline - Pairwise';
            elseif  iTimes==2; theseTimes = 80:155; thisTitle = 'Immersion - Pairwise';
            elseif  iTimes==3; theseTimes = 180:194; thisTitle = 'Recovery - Pairwise';
            end
            
            % if doing 1-30 Hz analysis, shift times to compensate for
            % cut off at start of ERSP
            if analysisType>1
                theseTimes=theseTimes-1;
            end
            
            cnt=cnt+1;
            cntVec = [3,6,9,12,15];
            subplot(5,3,cntVec(cnt))
            
            
% %             %pause(1)
%             theseData1 = squeeze(mean(mean(ersp(:,1,iExposures,:,theseFreqs,theseTimes),5),6)); %se01
%             theseData2 = squeeze(mean(mean(ersp(:,2,iExposures,:,theseFreqs,theseTimes),5),6)); %se02
%             theseData = ttest(theseData1,theseData2);
%             disp('non-resampled stats used')

            theseData = squeeze(sigVec(iExposures,iFreq,:));
            disp('resampled stats')
            
            
            topoplot(theseData,chanlocs,...---
                'maplimits',theseMapLimits)
            %title(thisTitle)
            %cbar
            
            
        end
    end
    
    if analysisType==3
        saveas(h,[destDir '/' 'EEG_ERSP_1-30_Brain80_Topos_' thisFreqName '.eps'],'epsc')
    elseif analysisType==1
        saveas(h,[destDir '/' 'EEG_ERSP_1-100Hz_No_ICA_Topos_' thisFreqName '.eps'],'epsc')
    elseif analysisType==6
        saveas(h,[destDir '/' 'EEG_ERSP_1-30Hz_Topos_Brain70_Dip15' thisFreqName '.eps'],'epsc')
    end

    
    %close all
    
end



