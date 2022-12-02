%{
Classify_Stress_Plot
Author: Tom Bullock
Date: 01.04.20


%% CREATE PERMUTED RANK ORDER DATASET THEN COMPARE REAL AND PERM W/T-TESTS
Remember to explain that some measures are flipped so warm>cold =correct
(need to explain this in paper wrt figs2/3
ALSO need to do this for non-baselined data (PEP ftw)

%}

clear
close all

% load data
sourceDir = '/home/bullock/BOSS/CPT_Adaptation/Data_Compiled';
plotDir = '/home/bullock/BOSS/CPT_Adaptation/Plots';

load([sourceDir '/' 'Classify_Stress_Rank_Order.mat'])

h=figure('units','normalized','outerposition',[0 0 1.3 .8]);

%% SINGLE PLOT

% add lines
t2=40; % immersion period (position feet for immersion -25 s)
t3=65; % start CPT (immerse feet - 90 s)
t4=155; % recovery (feet out, start recovery baseline - 40 s)

for iLine=2:4
    if iLine==1; tx=t1;thisText = 'Baseline';
    elseif iLine==2; tx=t2; thisText = 'Prep';
    elseif iLine==3; tx=t3; thisText = 'CPT';
    elseif iLine==4; tx=t4; thisText = 'Recovery';
    end
    line([tx,tx],[.2,.9],'color','k','linewidth',4,'linestyle',':');
end

% add horizontal line
line([5,190],[.5,.5],'color','k','linewidth',4,'linestyle',':');

hold on

% generate plot
statLineYpos = .2;

for iPlot=8:-1:1
    
    
    % select color for line
    if      iPlot==1; thisColor = [255,0,0]; thisTitle = 'BP'; % (red)
    elseif  iPlot==2; thisColor = [255,140,0]; thisTitle = 'CO'; % (orange)
    elseif  iPlot==3; thisColor = [252,226,5]; thisTitle = 'HF'; % (yellow)
    elseif  iPlot==4; thisColor = [0,255,0]; thisTitle = 'HR'; % (green)
    elseif  iPlot==5; thisColor = [0,0,255]; thisTitle = 'LVET'; % (blue)
    elseif  iPlot==6; thisColor = [29,0,52]; thisTitle = 'PEP'; %(indigo)
    elseif  iPlot==7; thisColor = [238,130,238]; thisTitle = 'SV'; % (violet)
    elseif  iPlot==8; thisColor = [128,128,128]; thisTitle = 'TPR'; % (gray)
    end
    
    theseLabels{iPlot} = thisTitle;
    
    
    % plot real data
    hPlot(iPlot) = plot(5:190,smooth(squeeze(nanmean(allCorrectTrials(iPlot,:,5:190),2)),10),...
        'linewidth',5,...
        'color',thisColor./255); hold on
    
    % remove HF 1-35 secs because data nonsensical
    if iPlot==3
        hPlot(3).YData(1:35) = NaN;
        %hPlot(3).YData(191:195) = NaN;
    end
    
    % plot t-stat real vs. perm
    clear hResults
    hResults=squeeze(ttest(allCorrectTrials(iPlot,:,:),mean(allCorrectTrialsPerm(iPlot,:,:,:),4)));
    
    % add lines for t-test results
    statLineYpos = statLineYpos+.01;
    for s=1:length(hResults)
        if hResults(s)==1
            line([s,s+1],[statLineYpos,statLineYpos],'linewidth',6,'color',thisColor./255);
        end
    end
    
end



% set axis properties
set(gca,'linewidth',1.5,...
    'FontSize',24',...
    'xlim',[5,190],...
    'xTick',[40,65,95,125,155,190],...
    'ylim',[.2,.9],...
    'ytick',.2:.1:.9,...
    'box','off')

pbaspect([3,1,1])




% add legend
%legend(hPlot,theseLabels,'location','northwest','fontsize',20)

saveas(h,[plotDir '/' 'Classify_Stress_Rank_Order_All_Trials.eps'],'epsc')



% %% PLOT FEATURES ON SEPARATE PLOTS
% 
% % generate plot
% for iPlot=1:8
%     
%      % determine color      
%     if      iPlot==1; thisColor = [255,0,0];
%     elseif  iPlot==2; thisColor = [252,226,5];
%     elseif  iPlot==3; thisColor = [255,192,203];
%     elseif  iPlot==4; thisColor = [0,255,0];
%     elseif  iPlot==5; thisColor = [255,140,0];
%     elseif  iPlot==6; thisColor = [255,0,255];
%     elseif  iPlot==7; thisColor = [0,0,255];
%     elseif  iPlot==8; thisColor = [0,0,0];
%     end
%     
%     clear accData
%     accData=classStruct(iPlot).accData;
%     
%     cnt=0;
%     for i=1:size(accData,1)
%         if nansum(accData(i,:))>0
%             cnt=cnt+1;
%             classData(cnt,:) = accData(i,:);
%         end
%     end
%    
%     plot(35:190,smooth(nanmean(classData,1),5),...
%         'linewidth',3,...
%         'color',thisColor./255); hold on
%     
% end
% 
% % set axis properties
% set(gca,'linewidth',1.5,...
%     'FontSize',24',...
%     'xlim',[35,190],...
%     'xTick',[40,65,95,125,155,190],...
%     'ylim',[.4,.85],...
%     'ytick',[.4,.5,.6,.7,.8],...
%     'box','off')
% 
% % add lines
% t2=40; % immersion period (position feet for immersion -25 s)
% t3=65; % start CPT (immerse feet - 90 s)
% t4=155; % recovery (feet out, start recovery baseline - 40 s)
% 
% 
% for iLine=2:4
%     if iLine==1; tx=t1;thisText = 'Baseline';
%     elseif iLine==2; tx=t2; thisText = 'Prep';
%     elseif iLine==3; tx=t3; thisText = 'CPT';
%     elseif iLine==4; tx=t4; thisText = 'Recovery';
%     end
%     line([tx,tx],[.4,.85],'color','k','linewidth',4,'linestyle',':');
%     %text(tx,35,thisText,'fontsize',18)
% end
% 
% legend(grandMatHeaders{1:8},'location','north')

