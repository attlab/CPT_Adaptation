%{
Physio_Plot_Individuals
Author: Tom Bullock, UCSB Attention Lab
Date: 06.01.19

Plot individual data together for QC/outlier assessment.
Plot mean data for each measure automatically omitting subs with missing
measures (e.g. BP).

Note: if plotting shaded error bars, need to do this in stages OR matlab
crashes
%}

clear
close all

% add paths
%addpath(genpath('/data/DATA_ANALYSIS/All_Dependencies'))

% set dirs
sourceDir =  '/home/bullock/BOSS/CPT_Adaptation/Data_Compiled';
destDir = '/home/bullock/BOSS/CPT_Adaptation/Plots';

% load compiled data
load([sourceDir '/' 'PHYSIO_MASTER.mat' ])

% load resampled stats data
load([sourceDir '/' 'STATS_Physio_Resampled_Bl_Corrected.mat'],'allCardioStats')

% load task order (only useful to ID individual subs data file)
sourceDirTaskOrder = sourceDir;
load([sourceDirTaskOrder '/' 'Task_Order.mat'])


% plot averaged data (1) or individuals (0)
plotType=1;

% if plotting individuals, choose subject index, disp sjnum and order
if plotType==0
    sjIdx = 35;
    disp(['Displaying SjNum ' num2str(subjects(sjIdx))])
end

% if plotting averages, option to remove subjects with short recovery
% periods (120,123)
badSubjectsIdx=[];
if plotType==1
    badSubjectsIdx(1) = find(subjects==120);
    badSubjectsIdx(2) = find(subjects==123);
end

% choose which measure(s) to plot (1:7)
%plotMeasures = 1:7;

% x-axis length(should be 195 secs, but was restricted to 190?)
xAxisLength=195;

% do baseline correction?
plotBlCorrectedPhysio = 1;

% if plotting average, remove NaN subs (just BP and TPR have this issue)
if plotType==1
    tmp = [];
    tmp = isnan(all_BP);
    tmp = sum(sum(sum(tmp,2),3),4);
    all_BP(tmp>0,:,:,:)=[];
end

% if plotting average, do regular plots or shaded error bars?
plotErrorBars=1;



% tmp = [];
% tmp = isnan(all_CO(:,:,:,1:195));
% tmp = sum(sum(sum(tmp,2),3),4);
% all_CO(tmp>0,:,:,:)=[];

% tmp = [];
% tmp = isnan(all_TPR);
% tmp = sum(sum(sum(tmp,2),3),4);
% all_TPR(tmp>0,:,:,:)=[];

% do baseline correction on all measures (correcting to mean 20-40 secs
% period in baseline)
if plotBlCorrectedPhysio
    all_BP = all_BP-mean(all_BP(:,:,:,20:40),4);
    all_CO = all_CO-mean(all_CO(:,:,:,2000:4000),4);
    all_HR = all_HR-mean(all_HR(:,:,:,2000:4000),4);
    all_LVET = all_LVET-mean(all_LVET(:,:,:,2000:4000),4);
    all_PEP = all_PEP-mean(all_PEP(:,:,:,2000:4000),4);
    all_SV = all_SV-mean(all_SV(:,:,:,2000:4000),4);
    all_TPR = all_TPR-mean(all_TPR(:,:,:,2000:4000),4);
    vall_HF = all_HF-nanmean(all_HF(:,:,:,3200:4200),4);% [nan for first 30 secs coz classifier training...address this?] 
end

% downsample to reduce figure size (mbs)
all_HR = all_HR(:,:,:,1:100:19500);
all_LVET = all_LVET(:,:,:,1:100:19500);
all_PEP = all_PEP(:,:,:,1:100:19500);
all_SV = all_SV(:,:,:,1:100:19500);
all_TPR = all_TPR(:,:,:,1:100:19500);
all_CO = all_CO(:,:,:,1:100:19500);
all_HF = all_HF(:,:,:,1:100:19000); %% FIX TO 195!



% % set y axes (larger for individuals, smaller for group level stuff)
% if plotType~=1
%     setYaxesForGroup=0;
% else
%     setYaxesForGroup=1;
% end

% generate difference waves
all_BP_diff = squeeze(all_BP(:,:,1,:) - all_BP(:,:,2,:));
all_HR_diff = squeeze(all_HR(:,:,1,:) - all_HR(:,:,2,:));
all_LVET_diff = squeeze(all_LVET(:,:,1,:) - all_LVET(:,:,2,:));
all_PEP_diff = squeeze(all_PEP(:,:,1,:) - all_PEP(:,:,2,:));
all_SV_diff = squeeze(all_SV(:,:,1,:) - all_SV(:,:,2,:));
all_HF_diff = squeeze(all_HF(:,:,1,:) - all_HF(:,:,2,:));

h=figure;
for iMeasure = 1:6
    
    statLineYpos = 0;
    
    subplot(2,3,iMeasure);
    
    if      iMeasure==1; theseData_diff=all_BP_diff; theseData = all_BP;
    elseif  iMeasure==2; theseData_diff=all_HR_diff; theseData = all_HR;
    elseif  iMeasure==3; theseData_diff=all_LVET_diff; theseData = all_LVET;
    elseif  iMeasure==4; theseData_diff=all_PEP_diff; theseData = all_PEP;
    elseif  iMeasure==5; theseData_diff=all_SV_diff; theseData = all_SV;
    elseif  iMeasure==6; theseData_diff=all_HF_diff; theseData = all_HF;
    end
    
    % remove bad subs
    theseData_diff(badSubjectsIdx,:,:,:) = [];
    
    % normalize data
    %% normalize between -1 and 1
    maxData = max(max(nanmean(theseData_diff,1)));
    minData = min(min(nanmean(theseData_diff,1)));
    theseData_diff = (theseData_diff-minData)/(maxData-minData);
    
%     maxPA = squeeze(max(max(max(max(nanmean(paMatAll,1))))));
%     minPA = squeeze(min(min(min(min(nanmean(paMatAll,1))))));
%     paMatAll = (paMatAll-minPA)/(maxPA-minPA);
    
    for iPlot=1:5
        
        if      iPlot==1; thisColor = [255,0,0];
        elseif  iPlot==2; thisColor = [252,226,5];
        elseif  iPlot==3; thisColor = [255,192,203];
        elseif  iPlot==4; thisColor = [0,255,0];
        elseif  iPlot==5; thisColor = [255,140,0];
        end
           
        
        % generate plot
        
        % for HFHRV need to NaN out the first part
%         if iMeasure==6
%             theseData_diff(:,:,1:32) = nan;
%         end

        if iMeasure==6
            thisX = 32:190;
        else
            thisX = 1:195;
        end
        
        plot(thisX,smooth(squeeze(nanmean(theseData_diff(:,iPlot,thisX),1)),5),...
            'linewidth',4,...
            'Color',thisColor./255); hold on
        
        
        
        
%         [hResults,pResults,CIresults,statsResults] = ttest(theseData(:,iPlot,1,:),theseData(:,iPlot,2,:));
%         hResults = squeeze(hResults);
%         
        
        
        
        % which stats to use? (0=regular, 1=resampled)
        pairwiseCompType=1;
        if pairwiseCompType==1
            if      iMeasure==1; hResults = allCardioStats.bp_sigVec(:,iPlot);
            elseif  iMeasure==2; hResults = allCardioStats.hr_sigVec(:,iPlot);
            elseif  iMeasure==3; hResults = allCardioStats.lvet_sigVec(:,iPlot);
            elseif  iMeasure==4; hResults = allCardioStats.pep_sigVec(:,iPlot);
            elseif  iMeasure==5; hResults = allCardioStats.sv_sigVec(:,iPlot);
            elseif  iMeasure==6; hResults = allCardioStats.hf_sigVec(:,iPlot);
            end
        else
            [hResults,pResults,CIresults,statsResults] = ttest(theseData(:,iPlot,1,:),theseData(:,iPlot,2,:));
            hResults = squeeze(hResults);
        end
        
        % null fake results for first 32 secs of HFHRV
        if iMeasure==6
           
            hResults (1:32) = NaN;
            
        end
        
        
%         
%         if      iMeasure==1; theseData_diff=all_BP_diff; theseData = all_BP;
%     elseif  iMeasure==2; theseData_diff=all_HR_diff; theseData = all_HR;
%     elseif  iMeasure==3; theseData_diff=all_LVET_diff; theseData = all_LVET;
%     elseif  iMeasure==4; theseData_diff=all_PEP_diff; theseData = all_PEP;
%     elseif  iMeasure==5; theseData_diff=all_SV_diff; theseData = all_SV;
%     elseif  iMeasure==6; theseData_diff=all_HF_diff; theseData = all_HF;
%     end
    
        
        
        
        
        
        
        % add lines for t-test results
        statLineYpos = statLineYpos-.05;
        
        for s=1:length(hResults)
            if hResults(s)==1
            line([s,s+1],[statLineYpos,statLineYpos],'linewidth',6,'color',thisColor./255);
            end
        end
        
    end
    
    % add lines
    t1=0; % start pre baseline ( 40 s)
    t2=40; % immersion period (position feet for immersion -25 s)
    t3=65; % start CPT (immerse feet - 90 s)
    t4=155; % recovery (feet out, start recovery baseline - 40 s)
    
    theseYlims = [-.3,1];%ylim;
    for iLine=1:4
        if iLine==1; tx=t1;thisText = 'Baseline';
        elseif iLine==2; tx=t2; thisText = 'Prep';
        elseif iLine==3; tx=t3; thisText = 'CPT';
        elseif iLine==4; tx=t4; thisText = 'Recovery';
        end
        line([tx,tx],theseYlims,'color','k','linewidth',4,'linestyle',':');
        if iMeasure~=1
            %text(tx,thisYlim(2)+2,thisText,'fontsize',18)
        else
            %text(tx,thisYlim(2)+.5,thisText,'fontsize',18)
        end
        
    end
    
    set(gca,...
        'box','off',...
        'linewidth',1.5,...
        'xlim',[1,194],...
        'XTick',[1,40,65,95,125,155,194],...
        'XTickLabel',[1,40,65,95,125,155,195],...
        'ylim',theseYlims,...
        'ytick',[0,.2,.4,.6,.8,1],...
        'fontsize',18)
    
    pbaspect([2,1,1])
        
        %'xlim',[1,194],'XTick',[1,40,65,155,194],'XTickLabel',[1,40,65,155,195])
    
    %legend('T1','T2','T3','T4','T5')
    
end






