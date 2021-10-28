%{ 
CPT_Plot_Topos
Author: Tom Bullock
Date: 09.18.18
%}

clear
close all

% set dirs
parentDir = '/home/bullock/BOSS/CPT_Adaptation';
sourceDir = [parentDir '/' 'Data_Compiled'];

% load compiled ERSP dataset & chanlocs
analysisType=1;

if analysisType==1
    load([sourceDir '/' 'GRAND_ERSP_1-100Hz.mat' ])  
    load([sourceDir '/' 'STATS_EEG_ERSP_1-100Hz_TOPOS.mat'])
elseif analysisType==2
    load([sourceDir '/' 'GRAND_ERSP_1-30Hz_ICA_Occ_Rej.mat' ])
elseif analysisType==3
    load([sourceDir '/' 'GRAND_ERSP_1-30Hz_ICA_Brain_80.mat' ])
elseif analysisType==4
    load([sourceDir '/' 'GRAND_ERSP_1-30Hz_ICA_Brain_60.mat' ])
elseif analysisType==5
    load([sourceDir '/' 'GRAND_ERSP_1-30Hz_ICA_Brain_Other_Top.mat' ])
end

% analysis specific settings
if analysisType==1
    freqIdx=1;
else
    freqIdx=1:4;
end

% baseline correct
erspBL = mean(erspAll(:,:,:,:,:,25:40),6);
ersp = erspAll-erspBL;

% remove FT elects?



% plot freqs
for iFreq=freqIdx
    
    % stuff
    if iFreq==1
        theseFreqs = 1:3;
        theseMapLimits = [-1,4];
    elseif iFreq==2
        theseFreqs = 4:7;
        theseMapLimits = [-1,2];
    elseif iFreq==3
        theseFreqs = 8:14;
        theseMapLimits = [-1,3];
    elseif iFreq==4
        theseFreqs = 15:30;
        theseMapLimits = [-1,5];
    end
    
    if analysisType==1
        theseFreqs = 1:50;
        theseMapLimits = [-2,8];
    end
    
    % plot topo
    figure;
    cnt=0;
    for iExposures=1:5
        for iSession=1:2
            for iTimes=2;%1:3
                %for iExposures=1:5
                if      iTimes==1; theseTimes = 10:24; %   10:24;%25:40;
                elseif  iTimes==2; theseTimes = 80:155; %   78:160;
                elseif  iTimes==3; theseTimes = 180:194; %    182:197;
                end
                
                if      iSession==1 && iTimes==1; thisTitle='ICE Baseline';
                elseif  iSession==1 && iTimes==2; thisTitle='ICE CPT';
                elseif  iSession==1 && iTimes==3; thisTitle='ICE Recovery';
                elseif  iSession==2 && iTimes==1; thisTitle='WARM Baseline';
                elseif  iSession==2 && iTimes==2; thisTitle='WARM CPT';
                elseif  iSession==3 && iTimes==3; thisTitle='WARM Recovery';
                end
                
                cnt=cnt+1;
                subplot(5,2,cnt)
                %pause(1)
                theseData = squeeze(mean(mean(mean(ersp(:,iSession,iExposures,:,theseFreqs,theseTimes),1),5),6));
                topoplot(theseData,chanlocs,...
                    'maplimits',theseMapLimits)
                
                %title(thisTitle)
                %cbar
                
                %end
            end
        end
    end
    
end

% plot pairwise comparisions on topos
% plot freqs
for iFreq=freqIdx
    
    % stuff
    if iFreq==1
        theseFreqs = 1:3;
    elseif iFreq==2
        theseFreqs = 4:7;
    elseif iFreq==3
        theseFreqs = 8:14;
    elseif iFreq==4
        theseFreqs = 15:30;
    end
    
    theseMapLimits = [0,1];
    
    if analysisType==1
        theseFreqs = 1:50;
    end
    
    % plot topo
    figure;
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
            
            cnt=cnt+1;
            subplot(5,1,cnt)
            %pause(1)
            theseData1 = squeeze(mean(mean(ersp(:,1,iExposures,:,theseFreqs,theseTimes),5),6)); %se01
            theseData2 = squeeze(mean(mean(ersp(:,2,iExposures,:,theseFreqs,theseTimes),5),6)); %se02
            %theseData = ttest(theseData1,theseData2); % regular t-tests
            theseData = squeeze(sigVec(iExposures,5,:)); 
            
            topoplot(theseData,chanlocs,...
                'maplimits',theseMapLimits)
            %title(thisTitle)
            %cbar
            
            
        end
    end
    
end



