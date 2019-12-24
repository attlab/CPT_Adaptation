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
plotBlCorrectedPhysio = 0;

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
    all_BP = all_BP-mean(all_BP(:,:,:,15:40),4);
    all_CO = all_CO-mean(all_CO(:,:,:,2500:4000),4);
    all_HR = all_HR-mean(all_HR(:,:,:,2500:4000),4);
    all_LVET = all_LVET-mean(all_LVET(:,:,:,2500:4000),4);
    all_PEP = all_PEP-mean(all_PEP(:,:,:,2500:4000),4);
    all_SV = all_SV-mean(all_SV(:,:,:,2500:4000),4);
    all_TPR = all_TPR-mean(all_TPR(:,:,:,2500:4000),4);
    all_HF = all_HF-nanmean(all_HF(:,:,:,3200:4000),4);% [nan for first 30 secs coz classifier training...address this?] %only 8 secs for bl
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
for iMeasure=[2:5,7,8]
    
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
    else
        if      iMeasure==1; allPhysio = all_CO; thisTitle1 = 'CO'; thisYlim = [-1.5,1];
        elseif  iMeasure==2; allPhysio = all_HR; thisTitle1 = 'HR'; thisYlim = [50,90];
        elseif  iMeasure==3; allPhysio = all_LVET; thisTitle1  = 'LVET'; thisYlim=[260,320];
        elseif  iMeasure==4; allPhysio = all_PEP; thisTitle1= 'PEP'; thisYlim = [60,90];
        elseif  iMeasure==5; allPhysio = all_SV; thisTitle1 = 'SV'; thisYlim = [20,50];
        elseif  iMeasure==6; allPhysio = all_TPR; thisTitle1 = 'TPR'; thisYlim = [-800,200];
        elseif  iMeasure==7; allPhysio = all_BP; thisTitle1 = 'BP';thisYlim = [50,120];
        elseif  iMeasure==8; allPhysio = all_HF; thisTitle1 = 'HF'; thisYlim = [4,10];
        end
    end
    
    % select subject if plotting individual
    if plotType==0
        allPhysio = allPhysio(sjIdx,:,:,:);
    end
    
    % remove select subjects if plotting averages
    if plotType==1
        allPhysio(badSubjectsIdx,:,:,:) = [];
    end
    
    
    
    
    %% create a null distribution of t-tests for every session/timepoint
    
    % iteration loop (null data)
    for i=1:1000
        
        disp(['Null Iteration ' num2str(i)])
        
        % sample (timepoint) loop
        for j=1:size(allPhysio,4)
            
            % trial (CPT/WPT exposure) loop
            for k=1:size(allPhysio,2)
                
                observedData = squeeze(allPhysio(:,k,:,j));
                
                for m=1:length(observedData)
                    thisPerm = randperm(size(observedData,2));
                    nullDataMat(m,:) = observedData(m,thisPerm);
                end
                
                [H,P,CI,STATS] = ttest(nullDataMat(:,1),nullDataMat(:,2));
                tValsNull(i,j,k) = STATS.tstat;
                clear STATS nullDataMat observedData
                
            end
        end
    end
    
    %% generate matrix of real t-test results
    
    % sample (timepoint) loop
    for j=1:size(allPhysio,4)
        % trial (CPT/WPT loop)
        for k=1:size(allPhysio,2)
            observedData = squeeze(allPhysio(:,k,:,j));
            [H,P,CI,STATS] = ttest(observedData(:,1),observedData(:,2));
            tValsObs(j,k) = STATS.tstat;
            clear STATS observedData
        end
    end
    
    
    
   
    %% compare observed t-test at each trial and timepoint with corresponding null distribution of t-values
    
    % sample (timepoint) loop
    for j=1:size(tValsNull,2)
        
        % trial (exposure) loop
        for k=1:size(tValsNull,3)
            
            thisNullDist = sort(tValsNull(:,j,k),1,'descend');
            [~,idx] = min(abs(thisNullDist - tValsObs(j,k)));
            tStatIdx(j,k) = idx;
            clear thisNullDist  idx
            
        end
    end
    
    % convert idx value to probability
    %pValuesPairwise = tStatIdx./1000;
    
    % convert idx value to a vector of 0's and 1's (representing significance
    % at p<.05)
    clear sigVec
    for j=1:size(tStatIdx,1)
        for k=1:size(tStatIdx,2)
            if tStatIdx(j,k)<25 || tStatIdx(j,k)>975
                sigVec(j,k) = 1;
            else
                sigVec(j,k)=0;
            end
        end
    end
    
    if      iMeasure==2 
        allCardioStats.hr_sigVec=sigVec;
        allCardioStats.hr_tValsObs=tValsObs;
        allCardioStats.hr_tValsNull=tValsNull;
    elseif  iMeasure==3 
        allCardioStats.lvet_sigVec=sigVec;
        allCardioStats.lvet_tValsObs=tValsObs;
        allCardioStats.lvet_tValsNull=tValsNull;
    elseif  iMeasure==4 
        allCardioStats.pep_sigVec=sigVec;
        allCardioStats.pep_tValsObs=tValsObs;
        allCardioStats.pep_tValsNull=tValsNull;
    elseif  iMeasure==5 
        allCardioStats.sv_sigVec=sigVec;
        allCardioStats.sv_tValsObs=tValsObs;
        allCardioStats.sv_tValsNull=tValsNull;
    elseif  iMeasure==7 
        allCardioStats.bp_sigVec=sigVec;
        allCardioStats.bp_tValsObs=tValsObs;
        allCardioStats.bp_tValsNull=tValsNull;
    elseif  iMeasure==8 
        allCardioStats.hf_sigVec=sigVec;
        allCardioStats.hf_tValsObs=tValsObs;
        allCardioStats.hf_tValsNull=tValsNull;
    end    
    
    clear sigVec tStatIdx tValsNull tValsObs
end

% save data
if plotBlCorrectedPhysio==1
    save([sourceDir '/' 'STATS_Physio_Resampled_Bl_Corrected.mat'],'allCardioStats','subjects','badSubjectsIdx')
else
    save([sourceDir '/' 'STATS_Physio_Resampled_Uncorrected.mat'],'allCardioStats','subjects','badSubjectsIdx')
end


    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    










    
    
    
%     % set plot title
%     thisTitle = ['CPT ' thisTitle1  ' (n = ' num2str(size(allPhysio,1)) ')'];
%     
%     for iOrder=1:5
%         
%         subplot(5,1,iOrder)
%         
%         if plotErrorBars==0 || iMeasure==6
%             plot(linspace(1,xAxisLength,size(allPhysio,4)),squeeze(nanmean(allPhysio(:,iOrder,1,:),1)),'color',[51,153,255]./255,'linewidth',2);hold on
%             plot(linspace(1,xAxisLength,size(allPhysio,4)),squeeze(nanmean(allPhysio(:,iOrder,2,:),1)),'color',[255,51,51]./255,'linewidth',2);
%         else
%             
%             
%             
%             for iCond=1:2
%                 if iCond==1; thisColor = [51,153,255];
%                 elseif iCond==2; thisColor = [255,51,51];
%                 end
%                 
%                 thisMean = smooth(squeeze(nanmean(allPhysio(:,iOrder,iCond,:),1)),5);
%                 thisSEM = smooth(squeeze(nanstd(allPhysio(:,iOrder,iCond,:),0,1)./sqrt(size(allPhysio,1))),5);
%                 
%                 if iMeasure==8 % necessary if smoothing HF data because otherwise "smooth" extrapolates the empty first 30 secs
%                     thisMean(1:31)=NaN;
%                     thisSEM(1:31)=NaN;
%                 end
%                 
%                 shadedErrorBar(linspace(1,xAxisLength,size(allPhysio,4)),thisMean,thisSEM,{'color',thisColor./255,'linewidth',1}); hold on
%                 
%                 
%                 
%                 
%                 %                 shadedErrorBar(linspace(1,xAxisLength,size(allPhysio,4)),smooth(squeeze(nanmean(allPhysio(:,iOrder,iCond,:),1)),10),...
%                 %                     smooth(squeeze(nanstd(allPhysio(:,iOrder,iCond,:),0,1)./sqrt(size(allPhysio,1))),10),...
%                 %                     {'color',thisColor./255,'linewidth',1}); hold on
%             end
%         end
%         
%         if plotBlCorrectedPhysio==1
%             %thisYlim = [-15,15];
%             if plotType==1
%                 set(gca,'ylim',thisYlim)
%             end
%         else
%             %thisYlim = [60,90];
%             set(gca,'ylim',thisYlim)
%         end
%         
%         set(gca,'fontsize',18,'box','off','linewidth',1.5,'xlim',[1,194],'XTick',[1,40,65,155,194],'XTickLabel',[1,40,65,155,195])
%         
%         
%         % do t-test to determine if lines are different (downsample to reduce number of tests)
%         %if iMeasure==7
%         [hResults,pResults,CIresults,statsResults] = ttest(allPhysio(:,iOrder,1,:),allPhysio(:,iOrder,2,:));
%         %else
%         %   [hResults,pResults,CIresults,statsResults]= ttest(allPhysio(:,iOrder,1,1:100:end),allPhysio(:,iOrder,2,1:100:end));
%         %end
%         hResults = squeeze(hResults);
%         
%         % add line for t-test results to base of plots
%         for s = 1:length(hResults)
%             if hResults(s)==1
%                 if plotBlCorrectedPhysio>-1
%                     if iMeasure~=1
%                         line([s,s+1],[thisYlim(1)+1,thisYlim(1)+1],'linewidth',4,'color',[9,112,84]./255);
%                     else
%                         line([s,s+1],[thisYlim(1)+.2,thisYlim(1)+.2],'linewidth',4,'color',[9,112,84]./255);
%                     end
%                 else
%                     %line([s,s+1],[62,62],'linewidth',2);
%                 end
%             end
%         end
%         
%         % add lines
%         t1=0; % start pre baseline ( 40 s)
%         t2=40; % immersion period (position feet for immersion -25 s)
%         t3=65; % start CPT (immerse feet - 90 s)
%         t4=155; % recovery (feet out, start recovery baseline - 40 s)
%         
%         for iLine=1:4
%             if iLine==1; tx=t1;thisText = 'Baseline';
%             elseif iLine==2; tx=t2; thisText = 'Prep';
%             elseif iLine==3; tx=t3; thisText = 'CPT';
%             elseif iLine==4; tx=t4; thisText = 'Recovery';
%             end
%             line([tx,tx],thisYlim,'color','k','linewidth',4,'linestyle',':');
%             if iMeasure~=1
%                 %text(tx,thisYlim(2)+2,thisText,'fontsize',18)
%             else
%                 %text(tx,thisYlim(2)+.5,thisText,'fontsize',18)
%             end
%             
%         end
%         
%         %legend('Ice','Warm')
%         
%         if iOrder==5
%             xlabel('Time (s)','fontsize',24)
%         end
%         ylabel(thisTitle1,'fontsize',24)
%         
%         % add title at top
%         if iOrder==1
%             th = title(thisTitle,'fontsize',24);
%             %th = title('test');
%             titlePos = get(th,'position');
%             if iMeasure~=1
%                 set(th,'position',titlePos+2)
%             else
%                 set(th,'position',titlePos)
%             end
%         end
%         
%         %         % add T1, T2 etc labels on left
%         %         if plotBlCorrectedPhysio==0
%         %             text(-15,80, ['T' num2str(iOrder)],'fontsize',18)
%         %         else
%         %             text(-15,00, ['T' num2str(iOrder)],'fontsize',18)
%         %         end
%         
%         % change aspect rati
%         pbaspect([4,1,1])
%         
%         
%     end
%     %
%     %     % save image
%     %     if plotBlCorrectedPhysio
%     %         saveas(h,[destDir '/' 'Physio_' thisTitle1 '.eps'],'epsc')
%     %     else
%     %         saveas(h,[destDir '/' 'Physio_Raw' thisTitle1 '.eps'],'epsc')
%     %     end
%     
% end
% 
% %    disp(['Displaying SjNum ' num2str(subjects(sjIdx))])
