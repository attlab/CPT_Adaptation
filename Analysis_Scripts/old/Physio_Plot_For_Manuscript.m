%{
Physio_Plot_Compare_Within_Session_With_Stats
Author: Tom Bullock
Date: 04.24.20

Do within-session comparison plots for CPT/WPT separately, then add stats
lines to the base of the plots.

%}

clear
close all

% do baseline correction? (0=no, 1=yes)
plotBlCorrectedPhysio = 0;

% use resampled stats (0=no, 1=yes)
useResampledStats = 1;

% set dirs
sourceDir =  '/home/bullock/BOSS/CPT_Adaptation/Data_Compiled';
destDir = '/home/bullock/BOSS/CPT_Adaptation/Plots';
resampledStatsDir = [sourceDir '/' 'Resampled_Stats'];


% load compiled data
load([sourceDir '/' 'PHYSIO_MASTER_RESP_CORR.mat' ])


% % load resampled stats
% if plotBlCorrectedPhysio==1
%     load([sourceDir '/' 'STATS_Physio_Resampled_Bl_Corrected.mat'],'allCardioStats')
% else
%     load([sourceDir '/' 'STATS_Physio_Resampled_Uncorrected.mat'],'allCardioStats')
% end

% load task order (only useful to ID individual subs data file)
sourceDirTaskOrder = sourceDir;
load([sourceDirTaskOrder '/' 'Task_Order.mat'])

% plot averaged data (1) or individuals (0)
plotType=1;

% if plotting individuals, choose subject index, disp sjnum and order
if plotType==0
    sjIdx = 26;
    disp(['Displaying SjNum ' num2str(subjects(sjIdx))])
end

% x-axis length(should be 195 secs, but was restricted to 190?)
xAxisLength=195;

% remove bad subjects (120, 123) as they have short recovery periods
badSubjectsIdx(1) = find(subjects==120);
badSubjectsIdx(2) = find(subjects==123);

all_CO(badSubjectsIdx,:,:,:) = [];
all_HR(badSubjectsIdx,:,:,:) = [];
all_LVET(badSubjectsIdx,:,:,:) = [];
all_PEP(badSubjectsIdx,:,:,:) = [];
all_SV(badSubjectsIdx,:,:,:) = [];


% remove additional bad subjects (133,157) from HF data because noise
badSubjectsIdx = [];
badSubjectsIdx(1) = find(subjects==120);
badSubjectsIdx(2) = find(subjects==123);
badSubjectsIdx(3) = find(subjects==133);
badSubjectsIdx(4) = find(subjects==157);

all_HF(badSubjectsIdx,:,:,:) = [];

% remove bad subjects from BP (if they have NaNs) and TPR
if plotType==1
    tmp = [];
    tmp = isnan(all_BP);
    tmp = sum(sum(sum(tmp,2),3),4);
    all_BP(tmp>0,:,:,:)=[];
    all_TPR(tmp>0,:,:,:)=[];
    badSubjects_BP_TPR = subjects(tmp>0); % store vector of bad subs
end

badSubjects_CO_HR_LVET_PEP_SV = [120,123]; % store vectors of bad subs
badSubjects_HF = [120,123,133,157];

% do baseline correction on all measures (correcting to mean 20-40 secs
% period in baseline)
if plotBlCorrectedPhysio
    all_BP = all_BP-mean(all_BP(:,:,:,26:40),4);
    all_CO = all_CO-mean(all_CO(:,:,:,2600:4000),4);
    all_HR = all_HR-mean(all_HR(:,:,:,2600:4000),4);
    all_LVET = all_LVET-mean(all_LVET(:,:,:,2600:4000),4);
    all_PEP = all_PEP-mean(all_PEP(:,:,:,2600:4000),4);
    all_SV = all_SV-mean(all_SV(:,:,:,2600:4000),4);
    all_TPR = all_TPR-mean(all_TPR(:,:,:,2600:4000),4);
    all_HF = all_HF-nanmean(all_HF(:,:,:,3200:4000),4);% [nan for first 30 secs coz classifier training...address this?] 
end

% downsample to reduce figure size (mbs)
all_HR = all_HR(:,:,:,1:100:19500);
all_LVET = all_LVET(:,:,:,1:100:19500);
all_PEP = all_PEP(:,:,:,1:100:19500);
all_SV = all_SV(:,:,:,1:100:19500);
all_TPR = all_TPR(:,:,:,1:100:19500);
all_CO = all_CO(:,:,:,1:100:19500);
all_HF = all_HF(:,:,:,1:100:19000);

%% select time period for plotting ANOVA and t-test results only
if plotBlCorrectedPhysio==0
    timesForPlotting = 1:64;
else
    timesForPlotting = 65:195;
end
   

% loop through measures and plot
for iMeasure=8;%1:8

    % select data
    allPhysio=[];
    if plotBlCorrectedPhysio
        if      iMeasure==1; allPhysio = all_CO; thisTitle1 = 'CO'; thisEBXPosStart=73; thisEBYPosStart = 0;
        elseif  iMeasure==2; allPhysio = all_HR; thisTitle1 = 'HR'; thisEBXPosStart=73; thisEBYPosStart = 0;
        elseif  iMeasure==3; allPhysio = all_LVET; thisTitle1  = 'LVET'; thisEBXPosStart=73; thisEBYPosStart = -.5;
        elseif  iMeasure==4; allPhysio = all_PEP; thisTitle1= 'PEP'; thisEBXPosStart=162; thisEBYPosStart = 0;
        elseif  iMeasure==5; allPhysio = all_SV; thisTitle1 = 'SV'; thisEBXPosStart=162; thisEBYPosStart = -.2;
        elseif  iMeasure==6; allPhysio = all_TPR; thisTitle1 = 'TPR'; thisEBXPosStart=125; thisEBYPosStart = -.12;
        elseif  iMeasure==7; allPhysio = all_BP; thisTitle1 = 'BP'; thisEBXPosStart=73; thisEBYPosStart = 0;
        elseif  iMeasure==8; allPhysio = all_HF; thisTitle1 = 'HF'; thisEBXPosStart=125; thisEBYPosStart = 0;
        end
        thisYlim = [-.3,1];
        thisYlinePos = [-.05, -.15, -.25];
        thisLineGap = .025;
        thisLineWidth = 7;
    else
        if      iMeasure==1; allPhysio = all_CO; thisTitle1 = 'CO'; thisYlim = [1.8,3]; thisYtick =2.2:.2:3; thisYlinePos = [2.1,2,1.9];thisLineWidth=7;thisLineGap = .03; thisEBXPosStart=10; thisEBYPosStart = 1.9;
        elseif  iMeasure==2; allPhysio = all_HR; thisTitle1 = 'HR'; thisYlim = [52,90]; thisYtick = [60:10:900]; thisYlinePos = [60,57,54];thisLineWidth=7;thisLineGap = 1;thisEBXPosStart=10; thisEBYPosStart = 85;
        elseif  iMeasure==3; allPhysio = all_LVET; thisTitle1  = 'LVET'; thisYlim=[260,300]; thisYtick = [260:10:300]; thisYlinePos = [270,267,264];thisLineWidth=7;thisLineGap = 1;thisEBXPosStart=10; thisEBYPosStart = 270;
        elseif  iMeasure==4; allPhysio = all_PEP; thisTitle1= 'PEP'; thisYlim = [62,90]; thisYtick = [70:5:90];thisYlinePos = [68,66,64];thisLineWidth=7;thisLineGap = .5; thisEBXPosStart=10; thisEBYPosStart = 86;
        elseif  iMeasure==5; allPhysio = all_SV; thisTitle1 = 'SV'; thisYlim = [25,45]; thisYtick = [25:5:45];thisYlinePos = [30,28,26];thisLineWidth=7;thisLineGap = .5;  thisEBXPosStart=10; thisEBYPosStart = 41;
        elseif  iMeasure==6; allPhysio = all_TPR; thisTitle1 = 'TPR'; thisYlim = [1500,4000];thisYtick = [2000:500:4000];thisYlinePos = [2400,2300,2200]-500;thisLineWidth=5;thisLineGap = 40;  thisEBXPosStart=10; thisEBYPosStart = 2200;
        elseif  iMeasure==7; allPhysio = all_BP; thisTitle1 = 'BP';thisYlim = [58,110]; thisYtick = [70:10:110];thisYlinePos = [68,64,60];thisLineWidth=7;thisLineGap = 1;  thisEBXPosStart=10; thisEBYPosStart = 100;
        elseif  iMeasure==8; allPhysio = all_HF; thisTitle1 = 'HF'; thisYlim = [4,8]; thisYtick = [5:1:8];thisYlinePos = [5,4.7,4.4];thisLineWidth=7;thisLineGap = .1;  thisEBXPosStart=-5; thisEBYPosStart = 4.4;
        end
        
        
        

    end
    
    % null the first few seconds of baseline because crazy results
    allPhysio(:,:,:,1:2) = NaN;
    
    % normalize data between -1 and 1 (for bln only)
    if plotBlCorrectedPhysio
        maxData = max(max(max(nanmean(allPhysio,1))));
        minData = min(min(min(nanmean(allPhysio,1))));
        allPhysio = (allPhysio-minData)/(maxData-minData);
    end
    
    
    
    %% LOAD RESAMPLED STATS DATA
    if plotBlCorrectedPhysio==0
        thisLabel = 'Uncorrected';
    else
        thisLabel = 'Bl_Corrected';
    end
    
    load([resampledStatsDir '/' 'STATS_Physio_Resampled_' thisLabel '_' thisTitle1 '.mat'])
    
    % get ANOVA results
    clear condVec trialVec intVec
    if useResampledStats==1 % get ANOVA results from resampled data mats
        
        for t=1:length(allCardioStats.ANOVA)
            condVec(t) = allCardioStats.ANOVA(t).var1.pValueANOVA;
            trialVec(t) = allCardioStats.ANOVA(t).var2.pValueANOVA;
            intVec(t) = allCardioStats.ANOVA(t).varInt.pValueANOVA;
        end
        
    else % compute ANOVA results here and now
        
        addpath(genpath('/home/bullock/BOSS/CPT_Adaptation/resampling'))
        % name variables
        var1_name = 'cond';
        var1_levels = 2;
        var2_name = 'trial';
        var2_levels = 5;
        
        clear condVec trialVec intVec
        
        for t=1:size(allPhysio,4)
            
            % rearrange data for analysis
            observedData = [squeeze(allPhysio(:,:,1,t)),squeeze(allPhysio(:,:,2,t))];
            
            % run ANOVA
            statOutput = teg_repeated_measures_ANOVA(observedData,[var1_levels var2_levels],{var1_name, var2_name});
            
            % create vectors of main and int p-values (this will do)
            condVec(t) = statOutput(1,4);
            trialVec(t) = statOutput(2,4);
            intVec(t) = statOutput(3,4);
            
        end
       
    end
    
    
    %% create figure
    h=figure('units','normalized','outerposition',[0 0 0.5 1]); % 1 was .4
    
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
        
        if iMeasure==8
            hResults(1:32)=1;
        else
            hResults(1:2) = 1;
        end
        
        for s = 1:length(hResults)
            if hResults(s)<.05 && ismember(s,timesForPlotting)
                line([s,s+1],[YlinePos,YlinePos],'linewidth',30,'color',thisColor1./255);
            end
        end
        
    end
    theseXlims=[0,195];

    set(gca,'Visible','off','XLim',theseXlims,'yLim',[1,3])

    
    

    % loop through CPT and WPT conditions and plot separately
    %plotCnt=0;
    for iCond=1:2
        
        if iCond==1
            subplotIdx=1:3;
        else
            subplotIdx=5:7;
        end
        
        subplot(7,1,subplotIdx)
        
        
        
        %plotCnt=plotCnt+1;
        %subplot(2,1,plotCnt);
        
        if      iCond==1; thisSession='CPT';
        elseif  iCond==2; thisSession='WPT';
        end
        
        if plotBlCorrectedPhysio==0
            rawBlTitle = 'Raw';
        else
            rawBlTitle = 'Bln';
        end
        
        % set plot title
        thisTitle = [thisTitle1 ' ' thisSession ' ' '(' rawBlTitle ')' ];
        
        % loop through trials
        eb_cnt=140;
        semEB = [];
        for iOrder=[5,4,3,2,1]
            
            errorBarYposVector = [.9,.7,.5,.3,.1];
            
            % select line colors
            if      iOrder==1; thisColor = [255,0,0]; thisYPos = errorBarYposVector(1); thisXPos = 10; %red
            elseif  iOrder==2; thisColor = [255,140,0];thisYPos = errorBarYposVector(2); thisXPos = 13;% orange
            elseif  iOrder==3; thisColor = [252,226,5]; thisYPos = errorBarYposVector(3); thisXPos = 16;% yellow
            elseif  iOrder==4; thisColor = [0,255,0]; thisYPos = errorBarYposVector(4); thisXPos = 19; % green
            elseif  iOrder==5; thisColor = [0,0,255]; thisYPos = errorBarYposVector(5); thisXPos = 22;%blue
            end
            
            thisXPos=thisEBXPosStart + thisXPos;
            thisYPos = thisEBYPosStart + .88;

            
            % plot line for trial
            h_axis = plot(...
                linspace(1,xAxisLength,size(allPhysio,4)),...
                squeeze(nanmean(allPhysio(:,iOrder,iCond,:),1)),... % add a 5 point MW smoothing function for plots 7 & 8 [TOM 08.09.22]??? REMOVED
                'color',thisColor./255,...
                'linewidth',4);hold on
            
            % plot error bars in legend fig using line function
            if plotBlCorrectedPhysio==1 && iMeasure==8
                timesForPlotting = 65:190;
            end
             
            
            semEB = nanstd(nanmean(allPhysio(:,iOrder,iCond,timesForPlotting),4),0,1)./sqrt(size(allPhysio,1)); % make this specific for RAW/NORM time durations
            
            line([thisXPos,thisXPos],[thisYPos-semEB,thisYPos+semEB],...
                'linewidth',10,...
                'color',thisColor./255); hold on;
            
            %line([196,196],[0.25,0.75],'linewidth',10)
            
            
%             % try plotting error bars at various points           
%             for iEB=1:5
%                 
%                 if      iEB==1; xEB = 30;
%                 elseif  iEB==2; xEB = 80;
%                 elseif  iEB==3; xEB = 110;
%                 elseif  iEB==4; xEB = 140;
%                 elseif  iEB==5; xEB = 180;
%                 end
%                 
%                 xEB = xEB+iOrder;
%                    
%                 errorbar(...
%                     xEB,...
%                     squeeze(nanmean(allPhysio(:,iOrder,iCond,xEB+iOrder),1)),...
%                     nanstd(nanmean(allPhysio(:,iOrder,iCond,xEB+iOrder),4),0,1)./sqrt(size(allPhysio,1)),...
%                     'color','k',...
%                     'linewidth',3,...
%                     'CapSize',0);hold on
%             end
                
                
            
            
            
            % set y-axis limits etc.
            if plotBlCorrectedPhysio==0
                set(gca,'ylim',thisYlim)
            else
                set(gca,'ylim',thisYlim)
                thisYtick = [0,.5,1];
            end
            
            % only x-ticks for bottom plot
            if iCond==2
                thisXtickLabel = [0,40,65,95,125,155,195];
            else
                thisXtickLabel = [];
            end
            
            set(gca,'fontsize',28,'box','off','linewidth',1.5,'xlim',[1,194],'XTick',[1,40,65,95,125,155,194],'XTickLabel',thisXtickLabel,...
                'YTick',thisYtick)
            
        end
        
%         [~,hobj,~,~] = legend('T1','T2','T3','T4','T5','location','northeastoutside'); % labels need reversing
%         
%         hl = findobj(hobj,'type','line');
%         
%         for iLegend=2:2:10
%             set(hl(iLegend),'linewidth',semEB(iLegend/2)*2);
%         end


        
        % add event lines
        t1=0; % start pre baseline ( 40 s)
        t2=40; % immersion period (position feet for immersion -25 s)
        t3=65; % start CPT (immerse feet - 90 s)
        t4=155; % recovery (feet out, start recovery baseline - 40 s)
        
        for iLine=1:4
            if iLine==1; tx=t1;thisText = 'Baseline';
            elseif iLine==2; tx=t2; thisText = 'Prep';
            elseif iLine==3; tx=t3; thisText = 'CPT';
            elseif iLine==4; tx=t4; thisText = 'Recovery';
            end
            line([tx,tx],thisYlim,'color','k','linewidth',4,'linestyle',':');
            if iMeasure~=1
                %text(tx,thisYlim(2)+2,thisText,'fontsize',18)
            else
                %text(tx,thisYlim(2)+.5,thisText,'fontsize',18)
            end
        end
        
        
        
        
        %% get the pairwise comparison results
        clear hResults_T1T5 hResults_T1T3 hResults_T3T5
        if useResampledStats==1
            
            hResults_T1T5 = squeeze(allCardioStats.sigVec(iCond,1,:));
            hResults_T1T3 = squeeze(allCardioStats.sigVec(iCond,2,:));
            hResults_T3T5 = squeeze(allCardioStats.sigVec(iCond,3,:));
            
        else
            
            hResults_T1T5 = squeeze(ttest(allPhysio(:,1,iCond,:),allPhysio(:,5,iCond,:)));
            hResults_T1T3 = squeeze(ttest(allPhysio(:,1,iCond,:),allPhysio(:,3,iCond,:)));
            hResults_T3T5 = squeeze(ttest(allPhysio(:,3,iCond,:),allPhysio(:,5,iCond,:)));
            
        end
        
        
        % add line for t-test results to base of plots
        for theseLines=1:3
            
            clear hResults
            
            if theseLines==1
                hResults=hResults_T1T5; YlinePos=thisYlinePos(1); thisColor1 = [255,0,0]; thisColor2 = [0,0,255];
            elseif theseLines==2
                hResults = hResults_T1T3; YlinePos=thisYlinePos(2); thisColor1 = [255,0,0]; thisColor2 = [252,226,5];
            elseif  theseLines==3
                hResults = hResults_T3T5; YlinePos=thisYlinePos(3); thisColor1 = [252,226,5]; thisColor2 = [0,0,255];
            end
            
            if iMeasure==8
                hResults(1:32) = 0;
            else
                hResults(1:2) = 0;
            end
            
            for s = 1:length(hResults)
                if hResults(s)==1 && intVec(s)<.05 && ismember(s,timesForPlotting)% if t-test is sig and ANOVA interaction is sig && is in the time period for plotting, then plot line
                    line([s,s+1],[YlinePos,YlinePos],'linewidth',thisLineWidth,'color',thisColor1./255);
                    line([s,s+1],[YlinePos-thisLineGap,YlinePos-thisLineGap],'linewidth',thisLineWidth,'color',thisColor2./255);
                end
            end
        end
        
        
        
        
        
        
        
        
        
        % observedData = [squeeze(allPain(:,1,:)),squeeze(allPain(:,2,:))];
        
        
        
        
        
        %%%%%%%%%%%%%%%%%%
        
        
        % add title
        %title(thisTitle,'FontSize',28)
        %xlabel('Time (s)','fontsize',24)
        
        % change aspect ratio
        pbaspect([3,1,1])
        
        

    end
        
    
    % save image
    if plotType==1
        if plotBlCorrectedPhysio
            saveas(h,[destDir '/' 'Physio_wStats_Bln_Within_' thisTitle1 '_anv' '.eps'],'epsc')
        else
            saveas(h,[destDir '/' 'Physio_wStats_Raw_Within_' thisTitle1 '_anv' '.eps'],'epsc')
        end
    end
    

        
end
