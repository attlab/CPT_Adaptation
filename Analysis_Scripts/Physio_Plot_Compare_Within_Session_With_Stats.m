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
plotBlCorrectedPhysio = 1;

% set dirs
sourceDir =  '/home/bullock/BOSS/CPT_Adaptation/Data_Compiled';
destDir = '/home/bullock/BOSS/CPT_Adaptation/Plots';

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
    all_BP = all_BP-mean(all_BP(:,:,:,25:40),4);
    all_CO = all_CO-mean(all_CO(:,:,:,2500:4000),4);
    all_HR = all_HR-mean(all_HR(:,:,:,2500:4000),4);
    all_LVET = all_LVET-mean(all_LVET(:,:,:,2500:4000),4);
    all_PEP = all_PEP-mean(all_PEP(:,:,:,2500:4000),4);
    all_SV = all_SV-mean(all_SV(:,:,:,2500:4000),4);
    all_TPR = all_TPR-mean(all_TPR(:,:,:,2500:4000),4);
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

% loop through measures and plot
for iMeasure=1:8

    % select data
    allPhysio=[];
    if plotBlCorrectedPhysio
        if      iMeasure==1; allPhysio = all_CO; thisTitle1 = 'CO';
        elseif  iMeasure==2; allPhysio = all_HR; thisTitle1 = 'HR';
        elseif  iMeasure==3; allPhysio = all_LVET; thisTitle1  = 'LVET'; 
        elseif  iMeasure==4; allPhysio = all_PEP; thisTitle1= 'PEP';
        elseif  iMeasure==5; allPhysio = all_SV; thisTitle1 = 'SV';
        elseif  iMeasure==6; allPhysio = all_TPR; thisTitle1 = 'TPR';
        elseif  iMeasure==7; allPhysio = all_BP; thisTitle1 = 'BP';
        elseif  iMeasure==8; allPhysio = all_HF; thisTitle1 = 'HF';
        end
        thisYlim = [-.3,1];
        thisYlinePos = [-.05, -.15, -.25];
        thisLineGap = .025;
        thisLineWidth = 7;
    else
        if      iMeasure==1; allPhysio = all_CO; thisTitle1 = 'CO'; thisYlim = [1.8,3]; thisYtick =2.2:.2:3; thisYlinePos = [2.1,2,1.9];thisLineWidth=7;thisLineGap = .03;
        elseif  iMeasure==2; allPhysio = all_HR; thisTitle1 = 'HR'; thisYlim = [52,90]; thisYtick = [60:10:900]; thisYlinePos = [60,57,54];thisLineWidth=7;thisLineGap = 1;
        elseif  iMeasure==3; allPhysio = all_LVET; thisTitle1  = 'LVET'; thisYlim=[260,300]; thisYtick = [260:10:300]; thisYlinePos = [270,267,264];thisLineWidth=7;thisLineGap = 1;
        elseif  iMeasure==4; allPhysio = all_PEP; thisTitle1= 'PEP'; thisYlim = [62,90]; thisYtick = [70:5:90];thisYlinePos = [68,66,64];thisLineWidth=7;thisLineGap = .5;
        elseif  iMeasure==5; allPhysio = all_SV; thisTitle1 = 'SV'; thisYlim = [25,45]; thisYtick = [25:5:45];thisYlinePos = [30,28,26];thisLineWidth=7;thisLineGap = .5;
        elseif  iMeasure==6; allPhysio = all_TPR; thisTitle1 = 'TPR'; thisYlim = [2000,4000];thisYtick = [2500:500:4000];thisYlinePos = [2400,2300,2200];thisLineWidth=7;thisLineGap = 50;
        elseif  iMeasure==7; allPhysio = all_BP; thisTitle1 = 'BP';thisYlim = [58,110]; thisYtick = [70:10:110];thisYlinePos = [68,64,60];thisLineWidth=7;thisLineGap = 1;
        elseif  iMeasure==8; allPhysio = all_HF; thisTitle1 = 'HF'; thisYlim = [4,8]; thisYtick = [5:1:8];thisYlinePos = [5,4.7,4.4];thisLineWidth=7;thisLineGap = .1;
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
    

    % loop through CPT and WPT conditions and plot separately
    %plotCnt=0;
    for iCond=1:2
        
        
    
        % new figure
        h=figure('units','normalized','OuterPosition',[0,0,.75,.60]);
        
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
        for iOrder=[5,4,3,2,1]
            
            % select line colors
            if      iOrder==1; thisColor = [255,0,0]; %red
            elseif  iOrder==2; thisColor = [255,140,0];% orange 
            elseif  iOrder==3; thisColor = [252,226,5]; % yellow
            elseif  iOrder==4; thisColor = [0,255,0]; % green
            elseif  iOrder==5; thisColor = [0,0,255]; %blue
            end
            
            % plot line for trial
            plot(linspace(1,xAxisLength,size(allPhysio,4)),squeeze(nanmean(allPhysio(:,iOrder,iCond,:),1)),'color',thisColor./255,'linewidth',4);hold on

            % set y-axis limits etc.
            if plotBlCorrectedPhysio==0
                set(gca,'ylim',thisYlim)
            else
                set(gca,'ylim',thisYlim)
                thisYtick = [0,.5,1];
            end
              
            set(gca,'fontsize',28,'box','off','linewidth',1.5,'xlim',[1,194],'XTick',[0,40,65,155,194],'XTickLabel',[0,40,65,155,195],...
                'YTick',thisYtick)
            
        end
        
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
            
        
        % do pairwise comparisons (T1 vs. T5, T1 vs. T3, T3 vs. T5) -
        % [eventually replace with resampled]
        clear hResults_T1T5 hResults_T1T3 hResults_T3T5
        hResults_T1T5 = squeeze(ttest(allPhysio(:,1,iCond,:),allPhysio(:,5,iCond,:)));
        hResults_T1T3 = squeeze(ttest(allPhysio(:,1,iCond,:),allPhysio(:,3,iCond,:)));
        hResults_T3T5 = squeeze(ttest(allPhysio(:,3,iCond,:),allPhysio(:,5,iCond,:)));
        
        
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
            
            for s = 1:length(hResults)
                if hResults(s)==1
                    line([s,s+1],[YlinePos,YlinePos],'linewidth',thisLineWidth,'color',thisColor1./255);
                    line([s,s+1],[YlinePos-thisLineGap,YlinePos-thisLineGap],'linewidth',thisLineWidth,'color',thisColor2./255);
                end
            end
        end
        
       
        % add title
        %title(thisTitle,'FontSize',28)
        %xlabel('Time (s)','fontsize',24)
        
        % change aspect ratio
        pbaspect([3,1,1])
        
        
        % save image
        if plotType==1
            if plotBlCorrectedPhysio
                saveas(h,[destDir '/' 'Physio_wStats_Bln_Within_' thisTitle1 '_' thisSession '.eps'],'epsc')
            else
                saveas(h,[destDir '/' 'Physio_wStats_Raw_Within_' thisTitle1 '_' thisSession '.eps'],'epsc')
            end
        end
         
    end
        

        
end
