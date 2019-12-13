% compile all subs bandpassed data

clear
close all

sourceDir='/home/bullock/BOSS/CPT_Adaptation/Time_Freq_Results_Band_IC_Label';
destDir = '/home/bullock/BOSS/CPT_Adaptation/Data_Compiled';

% if recompiling all subs data
subjects = CPT_SUBJECTS;

% if plotting individual subs [1 thru 34]
sjIdx = 1:34;

% recompile bandpass data
recompile=1;

if recompile
    for iSub=1:length(subjects)
        
        iSub
        sjNum=subjects(iSub);
        load([sourceDir '/' sprintf('sj%d_band.mat',sjNum)])
        
        for iSession=1:2
            for iEpoch=1:5
                
                alpha_all(iSub,iSession,iEpoch,:,:) = EEG_band(iSession).alpha(:,:,iEpoch);
                delta_all(iSub,iSession,iEpoch,:,:) = EEG_band(iSession).delta(:,:,iEpoch);
                theta_all(iSub,iSession,iEpoch,:,:) = EEG_band(iSession).theta(:,:,iEpoch);
                beta_all(iSub,iSession,iEpoch,:,:) = EEG_band(iSession).beta(:,:,iEpoch);
                
            end
        end
    end
    
    save([destDir '/' 'Time_Freq_Bandpassed_Data.mat'],'alpha_all','delta_all','theta_all','beta_all','chanlocs')
    
else
    
    load([destDir '/' 'Time_Freq_Bandpassed_Data.mat'])

end


% load a file to get chanlocs

% electrode region groups (split front to back in four sections)
frontal={'Fp1','Fp2','AF3','AF4','AF7','AF8','F7','F5','F3','F1','Fz','F2','F4','F6','F8'};
central={'FC5','FC3','FC1','FCz','FC2','FC4','FC6','C5','C3','C1','Cz','C2','C4','C6'};
parietal={'CP5','CP3','CP1','CPz','CP2','CP4','CP6','P7','P5','P3','P1','Pz','P2','P4','P6','P8'};
occipital={'PO7','PO3','POz','PO2','PO4','PO8','O1','Oz','O2'};

clear theseChans
theseChans=occipital


cnt=0;
for i=1:length(chanlocs)
   if  ismember(chanlocs(i).labels,theseChans) 
       cnt=cnt+1;
       chanIdx(cnt)=i;  
   end
end


close all
for thisFreq=1:4
    figure;
    if      thisFreq==1; theseData = delta_all; thisYlim=[-20,100]; thisTitle = 'Delta';
    elseif  thisFreq==2; theseData = theta_all; thisYlim=[-20,100]; thisTitle = 'Theta';
    elseif  thisFreq==3; theseData = alpha_all; thisYlim=[-20,100]; thisTitle = 'Alpha';
    elseif  thisFreq==4; theseData = beta_all; thisYlim=[-20,100]; thisTitle = 'Beta';
    end
    
    %elects=20;
    cnt=0;
    for iEpoch=1:5
        cnt=cnt+1;
        subplot(5,1,cnt)
        for iSession=1:2
            if iSession==1
                thisColor='c';
            else
                thisColor='r';
            end
            plot(squeeze(mean(mean(theseData(sjIdx,iSession,iEpoch,chanIdx,:),1),4))',...
                'color',thisColor,...
                'linewidth',3); hold on                 
        end
        set(gca,'ylim',thisYlim)
        
        % add lines
        t1=1; % start pre baseline ( 40 s)
        t2=40; % immersion period (position feet for immersion -25 s)
        t3=65; % start CPT (immerse feet - 90 s)
        t4=155; % recovery (feet out, start recovery baseline - 40 s)
        
        for iLine=1:4
            if iLine==1; tx=t1;thisText = 'Baseline';
            elseif iLine==2; tx=t2; thisText = 'Prep';
            elseif iLine==3; tx=t3; thisText = 'CPT';
            elseif iLine==4; tx=t4; thisText = 'Recovery';
            end
            line([tx,tx],thisYlim,'color','k','linewidth',2,'linestyle',':');
            %text(tx,35,thisText,'fontsize',18)
        end
        
        % do point by point t-tests
        if length(sjIdx)>1
        H=ttest(squeeze(mean(theseData(:,1,iEpoch,chanIdx,:),4)),squeeze(mean(theseData(:,2,iEpoch,chanIdx,:),4)));       
        for iTest=1:length(H)   
            if H(iTest)
                line(iTest:iTest+1,[-10,-10],'linewidth',6)
            end        
        end
        end
        % 
        
    end
    
end


% plot averaged topos for each period
for thisFreq=1:4
   figure
    if      thisFreq==1; theseData = delta_all; thisYlim= 'maxmin'; %[0,60];
    elseif  thisFreq==2; theseData = theta_all; thisYlim= 'maxmin'; %[0,15];
    elseif  thisFreq==3; theseData = alpha_all; thisYlim= 'maxmin'; %[0,40];
    elseif  thisFreq==4; theseData = beta_all; thisYlim= 'maxmin'; %[0,50];
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


%% calculate alpha assymetry

electPair=[11,12]; % F7 - F8
%electPair=[3,4]; % F3 - F4

% plot over time
figure;
for iEpoch=1:5
    subplot(5,1,iEpoch);
    for iSession=1:2
        if      iSession==1; thisColor='c';
        elseif  iSession==2; thisColor='r';
        end
        plot(mean(squeeze(alpha_all(sjIdx,iSession,iEpoch,electPair(1),:)-alpha_all(sjIdx,iSession,iEpoch,electPair(2),:)),1),'Color',thisColor); hold on
    end
end

% plot avgs for baseline, during, recovery
%figure;
clear ass_base ass_during ass_recovery
for iEpoch=1:5
    subplot(5,1,iEpoch);
    for iSession=1:2
        if      iSession==1; thisColor='c';
        elseif  iSession==2; thisColor='r';
        end
       
        ass_base(:,iSession,iEpoch)=  squeeze(mean(alpha_all(sjIdx,iSession,iEpoch,electPair(1),25:40),5) - mean(alpha_all(sjIdx,iSession,iEpoch,electPair(2),25:40),5));         
        ass_during(:,iSession,iEpoch)=  squeeze(mean(alpha_all(sjIdx,iSession,iEpoch,electPair(1),80:155),5) - mean(alpha_all(sjIdx,iSession,iEpoch,electPair(2),80:155),5));
        ass_recovery(:,iSession,iEpoch)=  squeeze(mean(alpha_all(sjIdx,iSession,iEpoch,electPair(1),175:190),5) - mean(alpha_all(sjIdx,iSession,iEpoch,electPair(2),175:190),5));
    end
end

figure;
for iEpoch=1:5
    subplot(5,1,iEpoch);
    for iSession=1:2
        if      iSession==1; thisColor='c';
        elseif  iSession==2; thisColor='r';
        end       
%         plot([ass_base(iSession,iEpoch),ass_during(iSession,iEpoch),ass_recovery(iSession,iEpoch)],...
%             'color',thisColor,...
%             'linestyle','none','Marker','o'); hold on
        
        theseDataMeans = [mean(ass_base(:,iSession,iEpoch)),mean(ass_during(:,iSession,iEpoch)),mean(ass_recovery(:,iSession,iEpoch))];
        theseDataSEMs = [std(ass_base(:,iSession,iEpoch))./sqrt(length(ass_base)),std(ass_during(:,iSession,iEpoch))./sqrt(length(ass_base)),std(ass_recovery(:,iSession,iEpoch))./sqrt(length(ass_base))];
        
        if length(sjIdx)>1
            errorbar(theseDataMeans,theseDataSEMs,...
                'color',thisColor,...
                'linestyle','none','Marker','o'); hold on
        else
            plot(theseDataMeans,...
                'color',thisColor,...
                'linestyle','none','Marker','o'); hold on
        end
        
    end
    
    set(gca,'xlim',[0.5,3.5],'ylim',[-8,4])
end




