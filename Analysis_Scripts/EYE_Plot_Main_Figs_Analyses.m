%{
EYE_Plot_Main_Figs_Analyses
Author: Tom Bullock, UCSB Attention Lab
Date: 12.01.22

Plots pupil data. Option to import resampled stats data.  

%}

clear
close all

% set dirs
sourceDir = '/home/bullock/BOSS/CPT_Adaptation/Data_Compiled';
plotDir = '/home/bullock/BOSS/CPT_Adaptation/Plots';

% load compiled EYE Data (paMatAll = sub,session,task,eye,timepoint)
load([sourceDir '/' 'CPT_EYE_Master.mat'])

% baseline correction [Note that Event times are 1,20000,32500,77500,97500]
baselineCorrect=1;

% use resampled stats (requires separate script to be run) (0=no, 1=yes)
useResampledStats = 1;

% remove bad subjects
badSubs = [103,105,108,109,115,116,117,118,126,128,135,136,138,139,140,146,147,148,154,157,158,159];
[a,b] = setdiff(subjects,badSubs);
paMatAll = paMatAll(b,:,:,:,:);

% do baseline correction
if baselineCorrect==1
    paMatBL= nanmean(paMatAll(:,:,:,:,round(26000/2):round(40000/2)),5);
    paMatAll = paMatAll - paMatBL;
end

% select time period for plotting ANOVA and t-test results only
if baselineCorrect==0
    timesForPlotting = 1:64;
else
    timesForPlotting = 65:195;
end

% downsample to 1Hz [average across each second (500Hz original SR)]
for i=1:195
    paMattAll_DS(:,:,:,:,i) = nanmean(paMatAll(:,:,:,:,((i*500)+1:(i+1)*500)-500),5);
end
paMatAll = paMattAll_DS;

% plot settings
theseXlims=[0,195];
theseXticks=[0,40,65,95,125,155,195];
theseYlims = [-.3,1];

% normalize between -1 and 1
maxPA = squeeze(max(max(max(max(nanmean(paMatAll,1))))));
minPA = squeeze(min(min(min(min(nanmean(paMatAll,1))))));
paMatAll = (paMatAll-minPA)/(maxPA-minPA);

% some plot settings
thisYlinePos = [-.05, -.15, -.25];
thisLineGap = .025;
thisLineWidth = 7;

% apply baseline correction to these plots?
if baselineCorrect==1
    thisLabel='bln';
else
    thisLabel='raw';
end

% get ANOVA results
clear condVec trialVec intVec

if useResampledStats==1 % get ANOVA results from resampled data mats
    
    % load permuted stats
    load([sourceDir '/' 'STATS_WITHIN_Resampled_EYE_n21_' thisLabel '.mat'])
    for t=1:length(allPupilStats.ANOVA)
        condVec(t) = allPupilStats.ANOVA(t).var1.pValueANOVA;
        trialVec(t) = allPupilStats.ANOVA(t).var2.pValueANOVA;
        intVec(t) = allPupilStats.ANOVA(t).varInt.pValueANOVA;
    end
    
else
    
    addpath(genpath('/home/bullock/BOSS/CPT_Adaptation/resampling'))
    % name variables
    var1_name = 'cond';
    var1_levels = 2;
    var2_name = 'trial';
    var2_levels = 5;
    
    clear condVec trialVec intVec
    
    for t=1:size(paMatAll,5)
        
        % rearrange data for analysis
        observedData = [squeeze(mean(paMatAll(:,1,:,:,t),4)),squeeze(mean(paMatAll(:,2,:,:,t),4))];
                
        % run ANOVA
        statOutput = teg_repeated_measures_ANOVA(observedData,[var1_levels var2_levels],{var1_name, var2_name});
        
        % create vectors of main and int p-values (this will do)
        condVec(t) = statOutput(1,4);
        trialVec(t) = statOutput(2,4);
        intVec(t) = statOutput(3,4);
        
    end
    
end


% open figure and set size and position
h=figure('units','normalized','outerposition',[0 0 0.5 1]); % 1 was .4

% position for ANOVA results (horizontal bars between Tx and Ct plots)
subplot(7,1,4)

for theseLines=1:3
    
    clear hResults
    
    if theseLines==1
        hResults=condVec; YlinePos=3; thisColor1 = [153,50,204]; thisColor2 = [0,0,255];
    elseif theseLines==2
        hResults = trialVec; YlinePos=2; thisColor1 = [238,130,238]; thisColor2 = [252,226,5];
    elseif  theseLines==3
        hResults = intVec; YlinePos=1; thisColor1 = [64,64,64]; thisColor2 = [0,0,255];
    end
    
    for s = 1:length(hResults)
        if hResults(s)<.05 && ismember(s,timesForPlotting)
            line([s,s+1],[YlinePos,YlinePos],'linewidth',30,'color',thisColor1./255);
        end
    end
    
end

set(gca,'Visible','off','XLim',theseXlims)



% generate pupil data plots
for iCond=1:2
    
    if iCond==1
        subplotIdx=1:3;
    else
        subplotIdx=5:7;
    end
    
    subplot(7,1,subplotIdx)
    
    % loop through lines
    for iOrder=[5,4,3,2,1]
        
        thisEye=1:2; %1=left,2=right
        
        if      iOrder==1; thisColor = [255,0,0]; thisXPos=10;%red
        elseif  iOrder==2; thisColor = [255,140,0];thisXPos=13;% orange ;
        elseif  iOrder==3; thisColor = [252,226,5]; thisXPos=16;% yellow[255,192,203];
        elseif  iOrder==4; thisColor = [0,255,0]; thisXPos=19;% green
        elseif  iOrder==5; thisColor = [0,0,255]; thisXPos=22;%blue
        end
        
        % plot average line for both pupils
        plot(1:195,smooth(squeeze(nanmean(nanmean(paMatAll(:,iCond,iOrder,thisEye,:),1),4)),5),...
            'color',thisColor./255,...
            'linewidth',4); hold on % plot indices (500 Hz,to divide by 2)
        
        
        % add lines for trial events
        for iLine=2:4
            if iLine==1; tx=1;thisText = 'Baseline';
            elseif iLine==2; tx=40; thisText = 'Prep';
            elseif iLine==3; tx=65; thisText = 'CPT';
            elseif iLine==4; tx=155; thisText = 'Recovery';
            end
            line([tx,tx],[-300,600],'color','k','linewidth',4,'linestyle',':');
            text(tx,700,thisText,'fontsize',18)
        end
        
        % add T1, T2 etc labels on left
        thisTime = ['T' num2str(iOrder)];
        %text(-25,0, thisTime,'fontsize',34)
        
        %xlabel('Time (s)','fontsize',18)
        %ylabel('P.Area (norm.)')
        set(gca,...
            'xlim',theseXlims,...
            'XTick',theseXticks,...
            'ylim',theseYlims,...
            'box','off',...
            'fontsize',26,...
            'linewidth',1.5)
        
        % change aspect ratio
        pbaspect([3,1,1])
        
        % set legend (removed for manuscript fig)
        %legend('ICE','WARM')
        
    end
    
    
    % add transparant gray rectangle pre or post 65 s 
    thisYlim = [-0.3,1];
    grayRectColor = [0.6,0.6,0.6,0.5];
    if baselineCorrect
        grayRectDims = [0,thisYlim(1),65,thisYlim(2)-thisYlim(1)]; % gray out the first 65 secs
    else
        grayRectDims = [65,thisYlim(1),194,thisYlim(2)-thisYlim(1)]; % gray out 65-194 secs
    end
    rectangle('Position',grayRectDims,'FaceColor',grayRectColor,'EdgeColor',grayRectColor);
    hold on;
    set(gca,'layer','top');
    
    
    % add SEM lines 
    for iOrder=[5,4,3,2,1]
        
        thisEye=1:2; %1=left,2=right
        
        if      iOrder==1; thisColor = [255,0,0]; thisXPos=10;%red
        elseif  iOrder==2; thisColor = [255,140,0];thisXPos=13;% orange 
        elseif  iOrder==3; thisColor = [252,226,5]; thisXPos=16;% yellow
        elseif  iOrder==4; thisColor = [0,255,0]; thisXPos=19;% green
        elseif  iOrder==5; thisColor = [0,0,255]; thisXPos=22;%blue
        end
         
        semEB = nanstd(nanmean(nanmean(paMatAll(:,iCond,iOrder,thisEye,timesForPlotting),4),5),0,1)./sqrt(size(paMatAll,1)); % make this specific for RAW/NORM time durations
        
        if baselineCorrect==1
            thisXPos = thisXPos -5; thisYPos = .88;
        else
            thisXPos = thisXPos -5 ; thisYPos = .88;
        end
           
        line([thisXPos,thisXPos],[thisYPos-semEB,thisYPos+semEB],...
            'linewidth',10,...
            'color',thisColor./255); hold on;
        
    end
    
    
    % get the pairwise comparison results
    clear hResults_T1T5 hResults_T1T3 hResults_T3T5
    if useResampledStats==1    
        hResults_T1T5 = squeeze(allPupilStats.sigVec(iCond,1,:));
        hResults_T1T3 = squeeze(allPupilStats.sigVec(iCond,2,:));
        hResults_T3T5 = squeeze(allPupilStats.sigVec(iCond,3,:));
    else
        hResults_T1T5 = squeeze(ttest(mean(paMatAll(:,iCond,1,:,:),4),mean(paMatAll(:,iCond,5,:,:),4)));
        hResults_T1T3 = squeeze(ttest(mean(paMatAll(:,iCond,1,:,:),4),mean(paMatAll(:,iCond,3,:,:),4)));
        hResults_T3T5 = squeeze(ttest(mean(paMatAll(:,iCond,3,:,:),4),mean(paMatAll(:,iCond,5,:,:),4)));
    end
    
    % plot pairwise comparision results
    for theseLines=1:3
        
        clear hResults
        
        if theseLines==1
            hResults=hResults_T1T5; YlinePos=thisYlinePos(1); thisColor1 = [255,0,0]; thisColor2 = [0,0,255];
        elseif theseLines==2
            hResults = hResults_T1T3; YlinePos=thisYlinePos(2); thisColor1 = [255,0,0]; thisColor2 = [252,226,5];
        elseif  theseLines==3
            hResults = hResults_T3T5; YlinePos=thisYlinePos(3); thisColor1 = [252,226,5]; thisColor2 = [0,0,255];
        end
        
        for s = 1:length(hResults)
            if hResults(s)==1 && intVec(s)<.05 && ismember(s,timesForPlotting)
                line([s,s+1],[YlinePos,YlinePos],'linewidth',thisLineWidth,'color',thisColor1./255);
                line([s,s+1],[YlinePos-thisLineGap,YlinePos-thisLineGap],'linewidth',thisLineWidth,'color',thisColor2./255);
            end
        end
    end
    
    if      iCond==1; thisCondName = 'CPT';
    elseif  iCond==2; thisCondName = 'WPT';
    end
    
end

% save figures (use export_fig because it allows transparent images to be
% exported as eps)
if baselineCorrect==0
    %saveas(h,[plotDir '/' 'EYE_ANOVA_CPTvWPT_Raw_Within.eps'],'epsc')
    export_fig([plotDir '/' 'EYE_ANOVA_CPTvWPT_Raw_Within.eps'],h,'-eps','-transparent')
else
    %saveas(h,[plotDir '/' 'EYE_ANOVA_CPTvWPT_Bln_Within.eps'],'epsc')
    export_fig([plotDir '/' 'EYE_ANOVA_CPTvWPT_Bln_Within.eps'],h,'-eps','-transparent')
end