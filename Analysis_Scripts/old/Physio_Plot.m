%{
Physio_Plot_Individuals
Author: Tom Bullock, UCSB Attention Lab
Date: 06.01.19

Plot individual data together for QC/outlier assessment.
Plot mean data for each measure automatically omitting subs with missing
measures (e.g. BP).

Note: if plotting shaded error bars, need to do this in stages OR matlab
crashes

Notes on SUBJECTS:
127, 140, 139 are all missing HF data in one or more conditions BUT this
doesn't impact any of the other measures

133 and 157 HF data both contain large SPIKES that distort
everything...remove these from HF analyses reporrting



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

% load resampled stats
if plotBlCorrectedPhysio==1
    load([sourceDir '/' 'STATS_Physio_Resampled_Bl_Corrected.mat'],'allCardioStats')
else
    load([sourceDir '/' 'STATS_Physio_Resampled_Uncorrected.mat'],'allCardioStats')
end

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



%  % if plotting averages, option to remove subjects with short recovery
%     % periods (120,123)
%     badSubjectsIdx=[];
%     if plotType==1 && ismember(iMeasure,[1:7])
%         badSubjectsIdx(1) = find(subjects==120);
%         badSubjectsIdx(2) = find(subjects==123);
%         
%         badSubjects_CO_HR_LVET_PEP_SV = [120,123];
%         
% %     elseif plotType==1 && iMeasure==6
% %         badSubjectsIdx
%         
%     elseif plotType==1 && iMeasure==8
%         badSubjectsIdx(1) = find(subjects==120);
%         badSubjectsIdx(2) = find(subjects==123);
%         badSubjectsIdx(3) = find(subjects==133);
%         badSubjectsIdx(4) = find(subjects==157);
%         
%         badSubjects_HF = [120,123,133,157];
%         
%     end
%     
%     % remove select subjects if plotting averages
%     if plotType==1
%         allPhysio(badSubjectsIdx,:,:,:) = [];
%     end



% if plotting average, do regular plots or shaded error bars?
plotErrorBars=1;

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
all_HF = all_HF(:,:,:,1:100:19000); %% FIX TO 195!




% plot measures across all five CPTs and two sessions
for iMeasure=1:8
    %h=figureFullScreen;
    %h=figure;
    h=figure('units','normalized','outerposition',[0 0 .3 2]); % was .3 1
    
    allPhysio=[];
    if plotBlCorrectedPhysio
        if      iMeasure==1; allPhysio = all_CO; thisTitle1 = 'CO'; thisYlim = [-1.5,1];
        elseif  iMeasure==2; allPhysio = all_HR; thisTitle1 = 'HR'; thisYlim = [-15,30];
        elseif  iMeasure==3; allPhysio = all_LVET; thisTitle1  = 'LVET'; thisYlim=[-30,15];
        elseif  iMeasure==4; allPhysio = all_PEP; thisTitle1= 'PEP'; thisYlim = [-15,10];
        elseif  iMeasure==5; allPhysio = all_SV; thisTitle1 = 'SV'; thisYlim = [-15,10];
        elseif  iMeasure==6; allPhysio = all_TPR; thisTitle1 = 'TPR'; thisYlim = [-800,200];
        elseif  iMeasure==7; allPhysio = all_BP; thisTitle1 = 'BP';thisYlim = [-20,25];
        elseif  iMeasure==8; allPhysio = all_HF; thisTitle1 = 'HF';thisYlim = [-5,5];
        end
        thisYlim = [-.3,1];
        thisYlinePos = [-.2];
    else
        if      iMeasure==1; allPhysio = all_CO; thisTitle1 = 'CO'; thisYlim = [1.5,3.2]; thisYlinePos = 1; thisYtick = [1,2,3]; 
        elseif  iMeasure==2; allPhysio = all_HR; thisTitle1 = 'HR'; thisYlim = [50,100]; thisYlinePos = 55; thisYtick = [60:20:100];
        elseif  iMeasure==3; allPhysio = all_LVET; thisTitle1  = 'LVET'; thisYlim=[250,310]; thisYlinePos = 255; thisYtick = [250:20:310];
        elseif  iMeasure==4; allPhysio = all_PEP; thisTitle1= 'PEP'; thisYlim = [60,90]; thisYlinePos = 65; thisYtick = [60:10:90];
        elseif  iMeasure==5; allPhysio = all_SV; thisTitle1 = 'SV'; thisYlim = [25,45]; thisYlinePos = 28; thisYtick = [25:10:45];
        elseif  iMeasure==6; allPhysio = all_TPR; thisTitle1 = 'TPR'; thisYlim = [2000,4200]; thisYlinePos = 2200; thisYtick = [2000:1000:4000];
        elseif  iMeasure==7; allPhysio = all_BP; thisTitle1 = 'BP';thisYlim = [60,110]; thisYlinePos = 65; thisYtick = [70:20:110];
        elseif  iMeasure==8; allPhysio = all_HF; thisTitle1 = 'HF'; thisYlim = [3,9]; thisYlinePos = 3.5; thisYtick = [3:2:9];
        end
    end
    
    % select subject if plotting individual
    if plotType==0
        allPhysio = allPhysio(sjIdx,:,:,:);
    end
    
    % null the first few seconds
    allPhysio(:,:,:,1:2) = NaN;
    
    % normalize data
    if plotBlCorrectedPhysio
        maxData = max(max(max(nanmean(allPhysio,1))));
        minData = min(min(min(nanmean(allPhysio,1))));
        allPhysio = (allPhysio-minData)/(maxData-minData);
    end
    
    % set plot title
    thisTitle = ['CPT ' thisTitle1  ' (n = ' num2str(size(allPhysio,1)) ')'];

    for iOrder=1:5
        
        subplot(5,1,iOrder)
        
        if plotErrorBars==0 %|| iMeasure==6
            plot(linspace(1,xAxisLength,size(allPhysio,4)),squeeze(nanmean(allPhysio(:,iOrder,1,:),1)),'color',[51,153,255]./255,'linewidth',2);hold on
            plot(linspace(1,xAxisLength,size(allPhysio,4)),squeeze(nanmean(allPhysio(:,iOrder,2,:),1)),'color',[255,51,51]./255,'linewidth',2);
        else
            
            
            
            for iCond=1:2
                if iCond==1; thisColor = [51,153,255];
                elseif iCond==2; thisColor = [255,51,51];
                end
                
                thisMean = smooth(squeeze(nanmean(allPhysio(:,iOrder,iCond,:),1)),5);
                thisSEM = smooth(squeeze(nanstd(allPhysio(:,iOrder,iCond,:),0,1)./sqrt(size(allPhysio,1))),5);
                
                if iMeasure==8 % necessary if smoothing HF data because otherwise "smooth" extrapolates the empty first 30 secs
                    thisMean(1:31)=NaN;
                    thisSEM(1:31)=NaN;
                end
                
                shadedErrorBar(linspace(1,xAxisLength,size(allPhysio,4)),thisMean,thisSEM,{'color',thisColor./255,'linewidth',1}); hold on
                
            end
        end
        
        if plotBlCorrectedPhysio==1
            %thisYlim = [-15,15];
            if plotType==1
                set(gca,'ylim',thisYlim)
            end
            thisYtick = [0:.5:1]
        else
            %thisYlim = [60,90];
            if plotType==1
                set(gca,'ylim',thisYlim)
            end
                        %%thisYtick = [0:.5:1]

        end

        set(gca,'fontsize',18,'box','off','linewidth',1.5,'xlim',[1,194],'XTick',[0,40,65,155,194],'XTickLabel',[0,40,65,155,195],'YTick',thisYtick)
        
        
        % which stats to use? (0=regular, 1=resampled)
        pairwiseCompType=1;
        if pairwiseCompType==0
            disp('NOT RESAMPLED STATS!')
        else
            disp('RESAMPLED STATS!')
        end
        
        if pairwiseCompType==1
            if      iMeasure==1; hResults = allCardioStats.co_sigVec(:,iOrder);
            elseif  iMeasure==2; hResults = allCardioStats.hr_sigVec(:,iOrder);
            elseif  iMeasure==3; hResults = allCardioStats.lvet_sigVec(:,iOrder);
            elseif  iMeasure==4; hResults = allCardioStats.pep_sigVec(:,iOrder);
            elseif  iMeasure==5; hResults = allCardioStats.sv_sigVec(:,iOrder);
            elseif  iMeasure==6; hResults = allCardioStats.tpr_sigVec(:,iOrder);
            elseif  iMeasure==7; hResults = allCardioStats.bp_sigVec(:,iOrder);
            elseif  iMeasure==8; hResults = allCardioStats.hf_sigVec(:,iOrder);
            end
        else
            [hResults,pResults,CIresults,statsResults] = ttest(allPhysio(:,iOrder,1,:),allPhysio(:,iOrder,2,:));
            hResults = squeeze(hResults);
        end
        
        % null fake results for first 32 secs of HFHRV
        if iMeasure==8         
            hResults (1:32) = NaN;         
        end
        
        % add line for t-test results to base of plots
        for s = 1:length(hResults)
            if hResults(s)==1
                if plotBlCorrectedPhysio>-1
                    if iMeasure~=1
                        line([s,s+1],[thisYlinePos,thisYlinePos],'linewidth',6,'color',[9,112,84]./255);
                    else
                        line([s,s+1],[thisYlim(1)+.2,thisYlim(1)+.2],'linewidth',6,'color',[9,112,84]./255);
                    end
                else
                    %line([s,s+1],[62,62],'linewidth',2);
                end
            end
        end
        
        % add lines
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

        % change plot aspect ratio
        pbaspect([4,1,1])
        
    end
    
    % save image
    if plotType==1
        if plotBlCorrectedPhysio
            saveas(h,[destDir '/' 'Physio_' thisTitle1 '.eps'],'epsc')
        else
            saveas(h,[destDir '/' 'Physio_Raw' thisTitle1 '.eps'],'epsc')
        end
    end
    
end


% save downsampled, baseline corrected physio data
if plotBlCorrectedPhysio
    save([sourceDir '/' 'PHYSIO_Clean_Bl_Corr_Norm.mat'],'all_BP','all_HR','all_LVET','all_PEP','all_HF','all_SV','all_CO','all_TPR','subjects','badSubjects_BP_TPR','badSubjects_CO_HR_LVET_PEP_SV','badSubjects_HF')
else
    save([sourceDir '/' 'PHYSIO_Clean_Uncorr.mat'],'all_BP','all_HR','all_LVET','all_PEP','all_HF','all_SV','all_CO','all_TPR','subjects','badSubjects_BP_TPR','badSubjects_CO_HR_LVET_PEP_SV','badSubjects_HF')
end