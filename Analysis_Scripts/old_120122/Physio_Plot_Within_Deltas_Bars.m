%{
Plot Physio Within Condition Analyses Bar Plots
Author: Tom Bullock
Date:06.18.22

Generate bar plots for all 8 physio within analyses (deltas for baseline
vs. peak)

%}

clear
close all

sourceDirPhysio = '/home/bullock/BOSS/CPT_Adaptation/Data_Compiled/Resampled_Stats';
sourceDirPupil = '/home/bullock/BOSS/CPT_Adaptation/Data_Compiled';
destDir = '/home/bullock/BOSS/CPT_Adaptation/Plots';


for iPlot=1:9
    
    subplot(5,2,iPlot);
    
    if      iPlot==1; thisMeasure = 'HR';
    elseif  iPlot==2; thisMeasure = 'HF';
    elseif  iPlot==3; thisMeasure = 'PEP';
    elseif  iPlot==4; thisMeasure = 'LVET';
    elseif  iPlot==5; thisMeasure = 'CO';
    elseif  iPlot==6; thisMeasure = 'SV';
    elseif  iPlot==7; thisMeasure = 'BP';
    elseif  iPlot==8; thisMeasure = 'TPR';
    elseif  iPlot==9; thisMeasure = 'Pupil'; % stored in different folder w/different naming conv
    end
    
    if iPlot ~=9
        load([sourceDirPhysio '/' 'STATS_Physio_Resampled_Within_Analysis_' thisMeasure '.mat'])
        theseData = all_physio_deltas;
    else
        load([sourceDirPupil '/' 'STATS_WITHIN_Resampled_EYE_n21_DELTAS.mat'])
        theseData = permute(pa_mat_deltas,[1,3,2]);
    end
    
    thisMean = squeeze(nanmean(theseData,1));
    thisSEM = squeeze(nanstd(theseData,0,1)/sqrt(size(theseData,1)));
    
    bar(thisMean); hold on
    errorbar(thisMean, thisSEM, 'linestyle','none');
    
    title(thisMeasure);
    
    clear theseData
    
    
end

