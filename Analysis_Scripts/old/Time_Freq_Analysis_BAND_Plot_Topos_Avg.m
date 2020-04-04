%{
Time_Freq_Analysis_BAND_Plot_Topos
Author:Tom Bullock
Date: 12.23.19

%}

clear
close all

% set dirs
sourceDir = '/home/bullock/BOSS/CPT_Adaptation/Data_Compiled';

% load compiled data 
load([sourceDir '/' 'Time_Freq_Bandpassed_Data_Band_ICA_Brain80.mat' ])

% baseline correct data? (1=yes, 0=no)
baselineCorrect=1;

sjIdx = 1:34;

% plot averaged topos for each period
for thisFreq=1:4
   figure;
   
    if      thisFreq==1; theseData = delta_all; %thisYlim= 'maxmin';% [2,12];%'maxmin'; %[0,60];
    elseif  thisFreq==2; theseData = theta_all; %thisYlim= 'maxmin';% [1,6];%'maxmin'; %[0,15];
    elseif  thisFreq==3; theseData = alpha_all; %thisYlim= 'maxmin';% [1,30];%'maxmin'; %[0,40];
    elseif  thisFreq==4; theseData = beta_all; %thisYlim= 'maxmin';% [1,6];%'maxmin'; %[0,50];
    end
    
    % set ylims
    if baselineCorrect
        if      thisFreq==1; thisYlim = [-1,7];
        elseif  thisFreq==2; thisYlim = [-1,1];
        elseif  thisFreq==3; thisYlim = [-2,10];
        elseif  thisFreq==4; thisYlim = [-1,2];
        end
    else
        if      thisFreq==1; thisYlim = [2,12];
        elseif  thisFreq==2; thisYlim = [1,6];
        elseif  thisFreq==3; thisYlim = [1,30];
        elseif  thisFreq==4; thisYlim = [1,6];
        end
    end
    
    %baseline correct
    if baselineCorrect
        theseData = theseData - mean(theseData(:,:,:,:,25:40),5);
    end
    
    %elects=20;
    cnt=0;
    for iEpoch=1:5
        
        for iSession=1:2
            cnt=cnt+1;
            subplot(5,2,cnt)
            % skip first 15 secs of immersion in avg (noisy)
            topoplot(squeeze(mean(mean(theseData(sjIdx,iSession,iEpoch,:,80:155),1),5)),...
                chanlocs,'maplimits',thisYlim)
            colorbar
            %pause(2)
        end
        
    end
    
end

% plot pairwise comparisons
for thisFreq=1:4
   figure;
   
    if      thisFreq==1; theseData = delta_all; %thisYlim= 'maxmin';% [2,12];%'maxmin'; %[0,60];
    elseif  thisFreq==2; theseData = theta_all; %thisYlim= 'maxmin';% [1,6];%'maxmin'; %[0,15];
    elseif  thisFreq==3; theseData = alpha_all; %thisYlim= 'maxmin';% [1,30];%'maxmin'; %[0,40];
    elseif  thisFreq==4; theseData = beta_all; %thisYlim= 'maxmin';% [1,6];%'maxmin'; %[0,50];
    end
    
    % set ylims
    if baselineCorrect
        if      thisFreq==1
        elseif  thisFreq==2
        elseif  thisFreq==3
        elseif  thisFreq==4
        end
    end
    
    %baseline correct
    if baselineCorrect
        theseData = theseData - mean(theseData(:,:,:,:,25:40),5);
    end
    
    %elects=20;
    cnt=0;
    for iEpoch=1:5
        
            cnt=cnt+1;
            subplot(5,1,cnt)
            
            data1 = squeeze(mean(theseData(sjIdx,1,iEpoch,:,80:155),5));
            data2 = squeeze(mean(theseData(sjIdx,2,iEpoch,:,80:155),5));
            
            hResults=ttest(data1,data2);
            
            topoplot(hResults,...
                chanlocs,'maplimits',[0,1])
            colorbar

        
    end
    
end

