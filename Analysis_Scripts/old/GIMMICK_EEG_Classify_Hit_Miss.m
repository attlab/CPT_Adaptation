function EEG_Classify_Hit_Miss(sjNum,permuteLabels,timeLock)

%{
EEG_Classify_Hit_Miss
Author: Tom Bullock
Date: 03.07.20
%}

% set dirs
parentDir = '/home/bullock/Gimmick_Ball';

% set time lock (1=shot init, 2=shot release)
if timeLock==1
    sourceDir = [parentDir '/' '/EEG_Sync_Clean_ICA_Init'];
    destDir = [parentDir '/' 'Classify_Hit_Miss'];
elseif timeLock==2
    sourceDir = [parentDir '/' '/EEG_Sync_Clean_ICA_Release'];
    destDir = [parentDir '/' 'Classify_Hit_Miss_Release'];
end

% set channels (will need to reduce probs)
theseChans = [1:9,11:20,22:63];

% load data
load([sourceDir '/' sprintf('sj%02d_EEG_ica.mat',sjNum)])

clear accData

% loop through different freq bands
for f=1:3
    
    if f==1
        freqs = [4,7];
    elseif f==2
        freqs = [8,12];
    elseif f==3
        freqs = [13,30];
    end
    
    % isolate specific frequency band using butterworth filter
    filterorder = 3;
    type = 'bandpass';
    [z1,p1] = butter(filterorder, [freqs(1), freqs(2)]./(EEG.srate/2),type);
    %freqz(z1,p1,[],250)
    data = double(EEG.data);
    tempEEG = NaN(size(data,1),EEG.pnts,size(data,3));
    for x = 1:size(data,1)
        for y = 1:size(data,3)
            dataFilt1 = filtfilt(z1,p1,data(x,:,y)); % was filtfilt
            tempEEG(x,:,y) = dataFilt1; % tymp = chans x times x trials
        end
    end
    
    % apply hilbert to each channel and epoch in turn
    eegs = [];
    for j=1:size(tempEEG,1) % chan loop
        for i=1:size(tempEEG,3) % trial loop
            eegs(i,j,:) = hilbert(squeeze(tempEEG(j,:,i)));
        end
    end
    
    % convert eegs to total power
    eegs = abs(eegs).^2;
    
    % parse hit and miss trials
    clear cnt_hit cnt_miss
    cnt_hit=0;
    cnt_miss=0;
    for i=1:length(allShotsEEG)
        if allShotsEEG(i).scored==1
            cnt_hit=cnt_hit+1;
            eeg_hit(cnt_hit,:,:) = eegs(i,:,:);
        elseif allShotsEEG(i).scored==0
            cnt_miss=cnt_miss+1;
            eeg_miss(cnt_miss,:,:) = eegs(i,:,:);
        end
    end
    
    % iterate, drawing differnt subsamples of trials each time
    for iter=1:100
        
        % equate hits and misses and pull random sample from original eeg mats
        clear minTrials
        minTrials = min(size(eeg_hit,1),size(eeg_miss,1));
        minTrials = minTrials-1;
        
        clear eeg_hit_perm eeg_miss_perm
        eeg_hit_perm = eeg_hit(randperm(size(eeg_hit,1)),:,:);
        eeg_miss_perm = eeg_miss(randperm(size(eeg_miss,1)),:,:);
        
        eeg_hit_perm = eeg_hit_perm(1:minTrials,:,:);
        eeg_miss_perm = eeg_miss_perm(1:minTrials,:,:);
        
        % collapse data into a single mat for classification
        clear theseData
        theseData = [eeg_hit_perm;eeg_miss_perm];
        
        % create labels list
        theseLabels = [repmat(1,1,minTrials),repmat(2,1,minTrials)];
        
        if permuteLabels
            for i=1:7
                theseLabels=theseLabels(randperm(size(theseLabels,2)));
            end
        end
        
        % get number of trials
        nTrials=size(theseData,1);
        
        % downsample settings
        dsf=10;
        nTimes = size(theseData,3)/dsf;
        
        % loop through timepoints
        for t=1:nTimes
            
            t
            
            thisSample = mean(theseData(:,:,(t-1)*dsf+1:(t-1)*dsf+dsf),3);
            
            % loop through trials and classify
            testData = []; testMember = []; trainIdx = []; trainData = []; trainMember = []; p=[]; correctTrials=0;
            for iTrial=1:nTrials
                testData = thisSample(iTrial,:);
                testMember = theseLabels(iTrial);
                
                trainIdx = setdiff(1:nTrials,iTrial);
                trainData = thisSample(trainIdx,:);
                trainMember = theseLabels(trainIdx);
                p=repmat(1/2,1,2);
                
                Labels=classify(testData,trainData,trainMember,'lin',p);
                correctTrials=correctTrials+length(find(Labels==testMember));
                
            end
            
            accData(iter,f,t) = correctTrials/nTrials;
            
            clear thisSample 
            
        end
        
    end
    
end

% save data
if permuteLabels==0
    save([destDir '/' sprintf('sj%02d_classify_hit_miss.mat',sjNum)],'accData','minTrials')
else
    save([destDir '/' sprintf('sj%02d_classify_hit_miss_perm.mat',sjNum)],'accData','minTrials')
end
    









% 
% 
%     for iTrial = 1:nTrials
%         
%         %disp(['Processing Trial ' num2str(iTrial)]);
%         
%         %disp( ['the sample ' num2str(iTrial) ' is cross-validatory'])
%         testData = thisData(iTrial,:);
%         testMember = allMem(iTrial);
%         trainIdx = setdiff(1:nTrials,iTrial);
%         trainData = thisData(trainIdx,:);
%         trainMember = allMem(trainIdx);
%         p=repmat(1/2,1,2);
%         
%         %         T = lda_final(trainData,trainMember,p,1); %%% replace with your pattern classifier function
%         %         testResp = testData * T';
%         %         trainResp = trainData * T';
%         %     A_bothTest(iTrial)=testResp;
%         %     A_bothTrain(iTrial,:)=trainResp';
%         %     A_testMember(iTrial)=testMember;
%         %     A_trainMember(iTrial,:)=trainMember;
%         
%         Labels=classify(testData,trainData,trainMember,'lin',p);
%         correctTrials=correctTrials+length(find(Labels==testMember));
%         
%     end
%     
%     accData(iPermute,iFreqs,iIterate) = correctTrials/nTrials;
%     
%     
%     
%     
% end
% 
% 
% 
% 
% 
% thisSig = 'Feat'; %'Snr' or 'Ori'
% 
% rankElectrodesByPower=0;
% 
% % define channels
% frontalChans = [4, 37, 38, 39];
% centralChans = [12, 47, 48, 49];
% parietalChans = [20, 31, 57];
% occipitalChans = [26, 27, 29, 30, 63, 64];
% 
% % define some other stuff
% %whichFreqs = 8:13; % must by e.g 8:13 OR single discrete freq e.g. 30
% theseChans = [occipitalChans parietalChans];
% myFeat = 'Pwr'; %'PwrPhase'; % Pwr or Phase or PwrPhase or Coeff
% nIterations = 10; %% SET TO 1000!
% sourceFolder = '/home/bullock/CTET/Spectra_Classification';
% %thisClass  = 'Classify_4secs_Pretarget';
% destFolder = '/home/bullock/CTET/Classify_Hit_Miss_4sec_FFT';
% 
% % %% FEED THESE IN WITH JOB FUNCTION
% % thisSj = 2;
% % iVer = 0;
% 
% % define and load file
% thisFile = ([sprintf('spectra_sj%02d_ver%02d.mat',thisSj,iVer)]);
% dataStruct = [];
% dataStruct = load([sourceFolder '/' thisFile]);
% myFreqs = dataStruct.myFreqs;
% 
% % isolate standard trials
% trialDataStdsIdx = [];
% trialDataStdsIdx = find(dataStruct.trialData(:,8)==0);
% trialDataStds = dataStruct.trialData(trialDataStdsIdx,:);
% spectraStds = dataStruct.spectra(trialDataStdsIdx,:,:);
% 
% 
% % isolate target trials
% trialDataTargets = [];
% trialDataTargetsIdx = find(dataStruct.trialData(:,8)==1);
% trialData = dataStruct.trialData(trialDataTargetsIdx,:);
% spectra = dataStruct.spectra(trialDataTargetsIdx,:,:);
% 
% trialDataCorrDetectionsIdx = find(trialData(:,10)==1); % correct detections
% trialDataMissIdx = find(trialData(:,10)==0); % misses
% trialDataCorrDiscriminationsIdx = find(trialData(:,11)==1); % correct discriminations
% 
% spectraCorrDetections = spectra(trialDataCorrDetectionsIdx,:,:);
% spectraMisses = spectra(trialDataMissIdx,:,:);
% spectraCorrDiscriminations = spectra(trialDataCorrDiscriminationsIdx,:,:);
% 
% % clear some vars
% accData = [];
% 
% % real vs. permuted data
% for iPermute=1:2
%     if iPermute == 1
%         permuteLabels = 0;
%         %permuteStr = 'obs';
%     elseif iPermute ==2
%         permuteLabels = 1;
%         %permuteStr = 'null';
%     end
%     
%     % loop through iterations
%     for iIterate=1:nIterations
%         
%         iIterate
%         
%         
%         
%         
%         % clear a bunch of stuff to ensure to no overlap
%         allData = []; allMem = [];tmpMem1 = [];tmpMem2=[]; thisData = [];
%         allDataRank = []; testData = []; testMember = []; trainIdx = [];
%         trainData = []; trainMember = []; p=[]; Labels = []; correctTrials = [];
%         allDataThisIteration = [];
%         
%         rng('Shuffle')
%         
%         %equate hits and misses and pull random sample
%         minTrials = min([size(spectraCorrDetections,1),size(spectraMisses,1)]);
%         minTrials = minTrials-1;
%         
%         %thisRandHits = randi(size(spectraHits,1),minTrials,1); %%%CHECK
%         %THIS %%%
%         thisSpectraHits = spectraCorrDetections(randi(size(spectraCorrDetections,1),1,minTrials),:,:);
%         thisSpectraMisses = spectraMisses(randi(size(spectraMisses,1),1,minTrials),:,:);
%         
%         %get trial labels
%         tmpMem1=[]; tmpMem2=[];
%         tmpMem1(1:size(thisSpectraHits,1)) = 1;
%         tmpMem2(1:size(thisSpectraMisses,1)) = 2;
%         
%         % collapse hits/misses data and labels
%         allDataThisIteration = [thisSpectraHits;thisSpectraMisses];
%         allMem = [tmpMem1,tmpMem2]';
%         
%         % real or perm run?
%         if permuteLabels==1
%             for i=1:7
%                 allMem=allMem(randperm(size(allMem,1)));
%             end
%         end
%         
%         % define nTrial
%         nTrials = size(allDataThisIteration,1);
% 
%         %                     allData = allData(:,rankedElecs(1:nElecsMax(iSj)));
%         %                    allData = allData(:,rankedElecs(1:(round(nElecsMax(iSj)/2))));
%         %allData = allData(:,incChansIndices);
%         %         size(incChansIndices)
%         
%         
%         %which freqs/chans to do classification on???
%         
%         % convert the freqs inputted above to freq index measures
%         %classFreqs =  find(myFreqs==iFreqs)):find(dataStruct.myFreqs==whichFreqs(end));
%         
%         %allData = squeeze(mean(allData(:,theseChans,classFreqs),3));
%         
%         % loop through freqs
%         for iFreqs=1:100
%             
%             allData = squeeze(allDataThisIteration(:,theseChans,iFreqs));
%             
%             % now I've averaged over freqs, rank my elects by power so that
%             % I can put the top XX into the classifier (trials x chans)
%             if rankElectrodesByPower==1
%                 
%                 %calculate power
%                 allDataRank = abs(allData);
%                 allDataRank = allDataRank.^2;
%                 
%                 %average over all trials
%                 allDataRank = mean(allDataRank,1);
%                 
%                 %sort trials to find largest values
%                 [allDataRank, powerIndex] = sort(allDataRank,2,'descend');
%                 
%                 %clear allDataRank (only interested in power index now)
%                 allDataRank = [];
%                 
%             end
%             
%             
%             
%             
%             if strcmp(thisSig,'Snr');
%                 thisData = real(allData);
%             else
%                 if strcmp(myFeat,'Pwr')
%                     thisData = abs(allData);
%                     thisData = thisData.^2;
%                 elseif strcmp(myFeat,'Phase')
%                     thisData = angle(allData);
%                     
%                 elseif strcmp(myFeat,'PwrPhase');
%                     thisData = abs(allData);
%                     thisData = thisData.^2;
%                     temp=angle(allData);
%                     thisData = cat(2,thisData,temp);
%                 elseif strcmp(myFeat,'Coeff')
%                     thisData = allData;
%                 end
%             end
%             %                 thisData = thisData(:,rankedElecs(1:nElecsMax(iSj)));
%             
%             %restrict to ranked electrodes
%             if rankElectrodesByPower==1
%                 disp('Rank Elects by Power!!!')
%                 thisData = thisData(:,powerIndex(1:10)); %rank according to power determined earlier
%             end
%             
%             
%             
%             testData = [];testMember=[];trainIdx=[];trainData=[];trainMember=[];p=[];
%                     correctTrials=0;
%             for iTrial = 1:nTrials
%                 
%                 %disp(['Processing Trial ' num2str(iTrial)]);
%                 
%                 %disp( ['the sample ' num2str(iTrial) ' is cross-validatory'])
%                 testData = thisData(iTrial,:);
%                 testMember = allMem(iTrial);
%                 trainIdx = setdiff(1:nTrials,iTrial);
%                 trainData = thisData(trainIdx,:);
%                 trainMember = allMem(trainIdx);
%                 p=repmat(1/2,1,2);
%                 
%                 %         T = lda_final(trainData,trainMember,p,1); %%% replace with your pattern classifier function
%                 %         testResp = testData * T';
%                 %         trainResp = trainData * T';
%                 %     A_bothTest(iTrial)=testResp;
%                 %     A_bothTrain(iTrial,:)=trainResp';
%                 %     A_testMember(iTrial)=testMember;
%                 %     A_trainMember(iTrial,:)=trainMember;
%                 
%                 Labels=classify(testData,trainData,trainMember,'lin',p);
%                 correctTrials=correctTrials+length(find(Labels==testMember));
%                 
%             end
%             
%             accData(iPermute,iFreqs,iIterate) = correctTrials/nTrials;
%             
%             
%             %             % store a single vector for both hits and misses for topo
%             %             % plotting purposes (also convert to power)
%             %             specHit_Topo(iIterate,:,iVer+1) = mean(mean(dataStruct.specHit(:,:,classFreqs),1),3);
%             %             specMiss_Topo(iIterate,:,iVer+1) = mean(mean(dataStruct.specMiss(:,:,classFreqs),1),3);
%             
%             
%         end % freqs
%         
%         if iPermute==1
%             specHit_Topo(iIterate,:,:,:) = thisSpectraHits;
%             specMiss_Topo(iIterate,:,:,:) = thisSpectraMisses;
%             specStd_Topo(iIterate,:,:,:) = spectraStds;
%         end
%         
%     end % iter
%     
% end % perms
% 
% % average topo plotting stuff over iterations for memory reasons
% specHit_Topo = squeeze(mean(specHit_Topo,1));
% specMiss_Topo = squeeze(mean(specMiss_Topo,1));
% specStd_Topo = squeeze(mean(mean(specStd_Topo,1),2)); % ALSO COLLAPSE OVER TRIALS
% 
% save([destFolder '/' sprintf('sj%02d_ver%02d_',thisSj,iVer) 'class_' myFeat '.mat'],...
%     'accData','nTrials','specHit_Topo','specMiss_Topo','specStd_Topo');
% 
% return
% 
% 
% 


%
%
%             %%%%%%%%%%%%%%%%%%%%%%
%
%
%
%
% %             if length(tmpMem1)>minTrials
% %                 thisRand=randi(size(spectraHits,1),minTrials,1);
% %                 dataStruct.specHit = dataStruct.specHit(randi(size(dataStruct.specHit,1),1,minTrials),:,:);
% %                 tmpMem1 = tmpMem1(1:minTrials);
% %             elseif length(tmpMem2)>minTrials
% %                 dataStruct.specMiss = dataStruct.specMiss(randi(size(dataStruct.specMiss,1),1,minTrials),:,:);
% %                 tmpMem2 = tmpMem2(1:minTrials);
% %             end
%
%
%
%
%
%
%
%
%
%
%     accData =[];
%     specHit_Topo = [];
%     specMiss_Topo = [];
%
%
%
%         for iVer = 0:2 % exp version
%             disp(['Processing Version: ' num2str(iVer)]);
%
%
%
%
%
%
%
%
%
%                 for iIterate=1:nIterations
%
%                     rng('Shuffle')
%
%                     % clear a bunch of stuff to ensure to no overlap
%                     allData = []; allMem = [];tmpMem1 = [];tmpMem2=[]; thisData = [];
%                     allDataRank = []; testData = []; testMember = []; trainIdx = [];
%                     trainData = []; trainMember = []; p=[]; Labels = []; correctTrials = [];
%
%
%
%
%                     % isolate target trials
%
%
%
%
%
%
%
%
%                     % rename vars
%                     tmpMem1(1:size(dataStruct.specHit,1)) = 1;
%                     tmpMem2(1:size(dataStruct.specMiss,1)) = 2;
%
%
%                     %equate hits and misses and pull random sample
%                     minTrials = min([size(dataStruct.specHit,1),size(dataStruct.specMiss,1)]);
%
%                     if length(tmpMem1)>minTrials
%
%                         thisRand=randi(size(dataStruct.specHit,1),minTrials,1);
%                         dataStruct.specHit = dataStruct.specHit(randi(size(dataStruct.specHit,1),1,minTrials),:,:);
%                         tmpMem1 = tmpMem1(1:minTrials);
%
%                     elseif length(tmpMem2)>minTrials
%
%                         dataStruct.specMiss = dataStruct.specMiss(randi(size(dataStruct.specMiss,1),1,minTrials),:,:);
%                         tmpMem2 = tmpMem2(1:minTrials);
%
%                     end
%
%
%
%                     if size(dataStruct.specHit,1)~=size(dataStruct.specMiss,1)
%                         disp('UNEQUAL SIZES')
%                         break
%                     elseif size(tmpMem1)~=size(tmpMem2)
%                         disp('UNEQUAL SIZES')
%                         break
%                     end
%
%
%                     allData = [dataStruct.specHit;dataStruct.specMiss];
%
%
%                     allMem = [tmpMem1,tmpMem2]';
%
%
%
%
%                     if permuteLabels==1
%                         for i=1:7
%                             allMem=allMem(randperm(size(allMem,1)));
%                         end
%                     end
%
%
%
%                     nTrials = size(allData,1);
%                     correctTrials=0;
%                     %                     allData = allData(:,rankedElecs(1:nElecsMax(iSj)));
%                     %                    allData = allData(:,rankedElecs(1:(round(nElecsMax(iSj)/2))));
%                     %allData = allData(:,incChansIndices);
%                     %         size(incChansIndices)
%
%
%                     %which freqs/chans to do classification on???
%
%                     % convert the freqs inputted above to freq index measures
%                     classFreqs =  find(dataStruct.myFreqs==whichFreqs(1)):find(dataStruct.myFreqs==whichFreqs(end));
%
%                     allData = squeeze(mean(allData(:,theseChans,classFreqs),3));
%
%
%
%                     % now I've averaged over freqs, rank my elects by power so that
%                     % I can put the top XX into the classifier (trials x chans)
%                     if rankElectrodesByPower==1
%
%                         %calculate power
%                         allDataRank = abs(allData);
%                         allDataRank = allDataRank.^2;
%
%                         %average over all trials
%                         allDataRank = mean(allDataRank,1);
%
%                         %sort trials to find largest values
%                         [allDataRank, powerIndex] = sort(allDataRank,2,'descend');
%
%                         %clear allDataRank (only interested in power index now)
%                         allDataRank = [];
%
%                     end
%
%
%
%
%                     if strcmp(thisSig,'Snr');
%                         thisData = real(allData);
%                     else
%                         if strcmp(myFeat,'Pwr')
%                             thisData = abs(allData);
%                             thisData = thisData.^2;
%                         elseif strcmp(myFeat,'Phase')
%                             thisData = angle(allData);
%
%                         elseif strcmp(myFeat,'PwrPhase');
%                             thisData = abs(allData);
%                             thisData = thisData.^2;
%                             temp=angle(allData);
%                             thisData = cat(2,thisData,temp);
%                         elseif strcmp(myFeat,'Coeff')
%                             thisData = allData;
%                         end
%                     end
%                     %                 thisData = thisData(:,rankedElecs(1:nElecsMax(iSj)));
%
%                     %restrict to ranked electrodes
%                     if rankElectrodesByPower==1
%                         disp('Rank Elects by Power!!!')
%                         thisData = thisData(:,powerIndex(1:10)); %rank according to power determined earlier
%                     end
%
%
%
%
%
%                     for iTrial = 1:nTrials
%
%                         %disp(['Processing Trial ' num2str(iTrial)]);
%
%                         %disp( ['the sample ' num2str(iTrial) ' is cross-validatory'])
%                         testData = thisData(iTrial,:);
%                         testMember = allMem(iTrial);
%                         trainIdx = setdiff(1:nTrials,iTrial);
%                         trainData = thisData(trainIdx,:);
%                         trainMember = allMem(trainIdx);
%                         p=repmat(1/2,1,2);
%
%                         %         T = lda_final(trainData,trainMember,p,1); %%% replace with your pattern classifier function
%                         %         testResp = testData * T';
%                         %         trainResp = trainData * T';
%                         %     A_bothTest(iTrial)=testResp;
%                         %     A_bothTrain(iTrial,:)=trainResp';
%                         %     A_testMember(iTrial)=testMember;
%                         %     A_trainMember(iTrial,:)=trainMember;
%
%                         Labels=classify(testData,trainData,trainMember,'lin',p);
%                         correctTrials=correctTrials+length(find(Labels==testMember));
%
%                     end
%
%                     accData(iIterate,iVer+1) = correctTrials/nTrials;
%
%
%                     % store a single vector for both hits and misses for topo
%                     % plotting purposes (also convert to power)
%                     specHit_Topo(iIterate,:,iVer+1) = mean(mean(dataStruct.specHit(:,:,classFreqs),1),3);
%                     specMiss_Topo(iIterate,:,iVer+1) = mean(mean(dataStruct.specMiss(:,:,classFreqs),1),3);
%
%
%
%
%
%
%
%
%
%                     %         %add acc data to appropriate matrix
%                     %         if iHalf==1
%                     %             accDataT1(:,iVer+1) = correctTrials/nTrials;
%                     %         elseif iHalf==2
%                     %             accDataT2(:,iVer+1) = correctTrials/nTrials;
%                     %         end
%                     %
%                     %         allData = []; allMem = [];
%                     %
%                     %
%                     %
%                 end %end iIterate
%
%             end % freqs
%         end % expVersion
%     end % permute
% end % subs
%
%         parsave([destFolder '/' sprintf('sj%02d_',thisSj) 'class_' myFeat '_' permuteStr  '.mat'],accData,specHit_Topo,specMiss_Topo);
%
%         %parsave('CLASSIFICATION_DATA.mat',accDataT1,accDataT2);
%
%
%
%
%
%
%



