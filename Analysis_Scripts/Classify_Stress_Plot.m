%{
Classify_Stress_Plot
Author: Tom Bullock
Date: 01.04.20

%}

clear
close all


% load data
sourceDir = '/home/bullock/BOSS/CPT_Adaptation/Data_Compiled';
load([sourceDir '/' 'CLASSIFICATION_DATA.mat'])
load([sourceDir '/' 'GRAND_MATS_ALL_DATA.mat'])


%% SINGLE PLOT

% generate plot
statLineYpos=.43;
for iPlot=1:8
    
     % determine color      
    if      iPlot==1; thisColor = [255,0,0]; %BP (red)
    elseif  iPlot==2; thisColor = [252,226,5]; %HF (yellow)
    elseif  iPlot==3; thisColor = [255,192,203]; %HR (pink)
    elseif  iPlot==4; thisColor = [0,255,0]; %LVET (green)
    elseif  iPlot==5; thisColor = [255,140,0]; %PEP (orange)
    elseif  iPlot==6; thisColor = [255,0,255]; %SV (purple)
    elseif  iPlot==7; thisColor = [0,0,255]; %PUPIL (blue)
    elseif  iPlot==8; thisColor = [0,0,0]; %EEG (black)
    end
    
    clear accData accDataPerm
    accData=classStruct(iPlot).accData;
    accDataPerm = classStructPerm(iPlot).accData;
    
    cnt=0;
    for i=1:size(accData,1)
        if nansum(accData(i,:))>0
            cnt=cnt+1;
            classData(cnt,:) = accData(i,:);
        end
    end
    
    cnt=0;
    for i=1:size(accDataPerm,1)
        if nansum(accDataPerm(i,:))>0
            cnt=cnt+1;
            classDataPerm(cnt,:) = accDataPerm(i,:);
        end
    end
   
    % plot real data
    plot(35:190,smooth(nanmean(classData,1),10),...
        'linewidth',5,...
        'color',thisColor./255); hold on
    
    % plot t-stat real vs. perm
    clear hResults
    hResults=ttest(classData,classDataPerm);
    
    % add lines for t-test results
    statLineYpos = statLineYpos-.01;
    for s=1:length(hResults)
        if hResults(s)==1
            line([s+35,s+1+35],[statLineYpos,statLineYpos],'linewidth',6,'color',thisColor./255);
        end
    end
    
    
    
end

%legend(grandMatHeaders{1:8},'location','north')


% set axis properties
set(gca,'linewidth',1.5,...
    'FontSize',24',...
    'xlim',[35,190],...
    'xTick',[40,65,95,125,155,190],...
    'ylim',[.33,.85],...
    'ytick',[.4,.5,.6,.7,.8],...
    'box','off')

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
    line([tx,tx],[.33,.85],'color','k','linewidth',4,'linestyle',':');
    %text(tx,35,thisText,'fontsize',18)
end





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

