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
analysisType=3;
if analysisType==2
    load([sourceDir '/' 'GRAND_ERSP_1-30Hz_ICA_Occ_Rej.mat' ])
elseif analysisType==3
    load([sourceDir '/' 'GRAND_ERSP_1-30Hz_ICA_Brain_80.mat' ])
end

% baseline correct
erspBL = mean(erspAll(:,:,:,:,:,5:45),6);
ersp = erspAll-erspBL;

% plot freqs
for iFreq=1:4
    
    % stuff
    if iFreq==1
        theseFreqs = 1:3;
        theseMapLimits = [-1,4];
    elseif iFreq==2
        theseFreqs = 4:7;
        theseMapLimits = [-1,2];
    elseif iFreq==3
        theseFreqs = 8:12;
        theseMapLimits = [-1,3];
    elseif iFreq==4
        theseFreqs = 13:30;
        theseMapLimits = [-1,5];
    end
    
    % plot topo
    figure;
    cnt=0;
    for iExposures=1:5
        for iSession=1:2
            for iTimes=1:3
                %for iExposures=1:5
                if      iTimes==1; theseTimes = 1:40;
                elseif  iTimes==2; theseTimes = 65:155;
                elseif  iTimes==3; theseTimes = 155:195;
                end
                
                if      iSession==1 && iTimes==1; thisTitle='ICE Baseline';
                elseif  iSession==1 && iTimes==2; thisTitle='ICE CPT';
                elseif  iSession==1 && iTimes==3; thisTitle='ICE Recovery';
                elseif  iSession==2 && iTimes==1; thisTitle='WARM Baseline';
                elseif  iSession==2 && iTimes==2; thisTitle='WARM CPT';
                elseif  iSession==3 && iTimes==3; thisTitle='WARM Recovery';
                end
                
                cnt=cnt+1;
                subplot(5,6,cnt)
                %pause(1)
                theseData = squeeze(mean(mean(mean(ersp(:,iSession,iExposures,:,theseFreqs,theseTimes),1),5),6));
                topoplot(theseData,chanlocs,...
                    'maplimits',theseMapLimits)
                title(thisTitle)
                cbar
                
                %end
            end
        end
    end
    
end

% plot pairwise comparisions on topos
% plot freqs
for iFreq=1:4
    
    % stuff
    if iFreq==1
        theseFreqs = 1:3;
    elseif iFreq==2
        theseFreqs = 4:7;
    elseif iFreq==3
        theseFreqs = 8:12;
    elseif iFreq==4
        theseFreqs = 13:30;
    end
    
    theseMapLimits = [0,1];
    
    % plot topo
    figure;
    cnt=0;
    for iExposures=1:5
        for iTimes=1:3
            %for iExposures=1:5
            if      iTimes==1; theseTimes = 1:40; thisTitle = 'Baseline - Pairwise';
            elseif  iTimes==2; theseTimes = 65:155; thisTitle = 'Immersion - Pairwise';
            elseif  iTimes==3; theseTimes = 155:195; thisTitle = 'Recovery - Pairwise';
            end
            
            cnt=cnt+1;
            subplot(5,3,cnt)
            %pause(1)
            theseData1 = squeeze(mean(mean(ersp(:,1,iExposures,:,theseFreqs,theseTimes),5),6)); %se01
            theseData2 = squeeze(mean(mean(ersp(:,2,iExposures,:,theseFreqs,theseTimes),5),6)); %se02
            theseData = ttest(theseData1,theseData2);
            
            topoplot(theseData,chanlocs,...
                'maplimits',theseMapLimits)
            title(thisTitle)
            cbar
            
            
        end
    end
    
end



