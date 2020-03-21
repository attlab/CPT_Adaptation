%{
Classify_Stress
Author: Tom Bullock
Date: 03.19.20

Classify stress state based on physio measures

1) Include all measures, do leave one subject (or one trial) out

%}

clear
close all

sourceDir = '/home/bullock/BOSS/CPT_Adaptation/Data_Compiled';
destDir = '/home/bullock/BOSS/CPT_Adaptation/Data_Compiled';

% load baseline corrected norm'd data
load([sourceDir '/' 'PHYSIO_Clean_Bl_Corr_Norm.mat'])

% create vectors of good subjects for each measure (bad subs are already
% removed from each of these)
goodSubjects_BP_TPR = setdiff(subjects,badSubjects_BP_TPR);
goodSubjects_CO_HR_LVET_PEP_SV = setdiff(subjects,badSubjects_CO_HR_LVET_PEP_SV);
goodSubjects_HF = setdiff(subjects,badSubjects_HF);

% identify and remove subs so all mats have same numbers of samples
badSubjectsAllMeasures = [120,123,133,140,151,157,161];

[~,idx] = setdiff(goodSubjects_BP_TPR,badSubjectsAllMeasures);
all_BP = all_BP(idx,:,:,:);
all_TPR = all_TPR(idx,:,:,:);
clear idx

[~,idx] = setdiff(goodSubjects_CO_HR_LVET_PEP_SV,badSubjectsAllMeasures);
all_CO = all_CO(idx,:,:,:);
all_HR = all_HR(idx,:,:,:);
all_LVET = all_LVET(idx,:,:,:);
all_PEP = all_PEP(idx,:,:,:);
all_SV = all_SV(idx,:,:,:);
clear idx

[~,idx] = setdiff(goodSubjects_HF,badSubjectsAllMeasures);
all_HF = all_HF(idx,:,:,:);



for theseTimes=1:2
    % isolate specific chunk of time for classification and restructure data
    % (subjects/trials x measures)
    if theseTimes==1
        t=26:40;
    elseif theseTimes==2
        t = 81:140;
    end
    
    
    allData = [...
        reshape(nanmean(all_BP(:,:,:,t),4),[280,1]),...
        reshape(nanmean(all_CO(:,:,:,t),4),[280,1]),...
        reshape(nanmean(all_HR(:,:,:,t),4),[280,1]),...
        reshape(nanmean(all_LVET(:,:,:,t),4),[280,1]),...
        reshape(nanmean(all_PEP(:,:,:,t),4),[280,1]),...
        reshape(nanmean(all_SV(:,:,:,t),4),[280,1]),...
        reshape(nanmean(all_TPR(:,:,:,t),4),[280,1]),...
        ];
    
    % LEAVING OUT HF FOR NOW BECAUE NAN VALUES!?!
    %reshape(nanmean(all_HF(:,:,:,t),4),[280,1]),...
    
    
    
    % set number of trials
    
    % set original data
    originalData = allData;
    
    % run classifier (all subjects in, leave one trial out)
    
    for permuteLabels=1:2
        
        for iLeaveOutMeasure=1:7
            
            keepMeasure =1:7;
            keepMeasure(iLeaveOutMeasure)=[];
            
            allData = originalData(:,keepMeasure);
            
            % permute condition labels if requested
            % set condition labels
            condLabels=repmat([1,1,1,1,1,2,2,2,2,2]',[28,1]);
            nTrials = length(condLabels);
            
            
            
            
            % if permuting labels, then run xx iterations
            if permuteLabels==2
                nIter=1000;
            else
                nIter=1;
            end
            
            for iter=1:nIter
                
                iter
                
                if permuteLabels==2
                    for i=1:7
                        condLabels = condLabels(randperm(size(condLabels,1)));
                    end
                end
                
                
                correctTrials=0;
                for iTrial=1:nTrials
                    
                    testData = allData(iTrial,:);
                    testMember = condLabels(iTrial);
                    trainIdx = setdiff(1:nTrials,iTrial);
                    trainData = allData(trainIdx,:);
                    trainMember = condLabels(trainIdx);
                    
                    p=repmat(1/2,1,2);
                    
                    Labels=classify(testData,trainData,trainMember,'lin',p);
                    
                    if length(Labels)==1
                        if Labels==testMember
                            correctTrials=correctTrials+1;
                        end
                    else
                        correctTrials=correctTrials+length(find(Labels==testMember));
                    end
                    
                end
                
                % compute accuracy
                accData(iter,iLeaveOutMeasure)=correctTrials/nTrials;
                
            end
            
            clear allData
            
        end
        
        if permuteLabels==1
            classResults(theseTimes).real = accData;
        else
            classResults(theseTimes).perm = accData;
        end
        
        clear accData
        
    end
    
end

save([destDir '/' 'Classification_Results_LOA_All_Trials.mat'],'classResults')














% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
% 
% 
% 
% correctTrials=0;
% for iTrial=1:nTrials
%     
%     testData = thisData(iTrial,:);
%     testMember = condLabels(iTrial);
%     trainIdx = setdiff(1:10,iTrial);
%     trainData = thisData(trainIdx,:);
%     trainMember = condLabels(trainIdx);
%     p=repmat(1/2,1,2);
%     
%     Labels=classify(testData,trainData,trainMember,'lin',p);
%     
%     if length(Labels)==1
%         if Labels==testMember
%             correctTrials=correctTrials+1;
%         end
%     else
%         correctTrials=correctTrials+length(find(Labels==testMember));
%     end
%     
%     % create confusion matrix (do this later)
%     %confMtx(testMember,Labels)=confMtx(testMember,Labels)+1;
%     %classCtr(testMember)=classCtr(testMember)+1;
%     
%     
%     
% end
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
% 
% % loop through subjects and apply classifier (leave one subject out?? NOt correct?)
% for iSub=1:10:271
%     
%     allTrials = 1:280; % 28 subs x 10 trials per sub
%     testIdx = iSub:iSub+9;
%     allTrials(testIdx) = [];
%     trainIdx = allTrials;
%     
%     testData = allData(testIdx,:);
%     trainData = allData(trainIdx,:);
%     
%     testMember = condLabels(testIdx);
%     trainMember = condLabels(trainIdx);
%     
%     p=repmat(1/2,1,2);
%     
%     Labels=classify(testData,trainData,trainMember,'lin',p);
% 
% end
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
% % loop through permuted and real data classification
% for permuteLabels=0:1
%     
%     
%     % loop through subjects
%     for iMeasure=1:8
%         
%         
%         iMeasure
%         cntSub=0;
%         for iSub=1:size(grandMat,1)
%             
%             
%             
%             %try
%             
%             
%             clear sjMat
%             sjMat = squeeze(grandMat(iSub,:,:,35:190,iMeasure)); % just the exposure + recovery part of the trialn [EDIT THE FEATURES 1:8 GOING INTO CLASSIFIER HERE]
%             
%             runClassifier=1;
%             %     if isnan(sjMat)
%             %         runClassifier=0;
%             %     end
%             
%             if runClassifier
%                 
%                 
%                 
%                 
%                 
%                 
%                 
%                 cntSub=cntSub+1;
%                 
%                 for iTime=1:size(sjMat,3)
%                     
%                     % permute condition labels if requested
%                     if permuteLabels
%                         for i=1:7
%                             condLabels = condLabels(randperm(size(condLabels,2)));
%                         end
%                     end
%                     
%                     thisData = [squeeze(sjMat(:,1,iTime,:));squeeze(sjMat(:,2,iTime,:))];
%                     
%                     try
%                         correctTrials=0;
%                         for iTrial=1:nTrials
%                             
%                             testData = thisData(iTrial,:);
%                             testMember = condLabels(iTrial);
%                             trainIdx = setdiff(1:10,iTrial);
%                             trainData = thisData(trainIdx,:);
%                             trainMember = condLabels(trainIdx);
%                             p=repmat(1/2,1,2);
%                             
%                             Labels=classify(testData,trainData,trainMember,'lin',p);
%                             
%                             if length(Labels)==1
%                                 if Labels==testMember
%                                     correctTrials=correctTrials+1;
%                                 end
%                             else
%                                 correctTrials=correctTrials+length(find(Labels==testMember));
%                             end
%                             
%                             % create confusion matrix (do this later)
%                             %confMtx(testMember,Labels)=confMtx(testMember,Labels)+1;
%                             %classCtr(testMember)=classCtr(testMember)+1;
%                             
%                             
%                             
%                         end
%                         
%                         accData(cntSub, iTime)=correctTrials/nTrials;
%                         
%                         
%                     catch
%                         
%                         accData(cntSub,iTime) = nan;
%                         
%                         %disp('skip timepoint')
%                     end
%                     
%                     
%                     
%                     
%                     
%                 end
%                 
%             end
%             
%             
%             
%         end
%         
%         % add classification to structures
%         if permuteLabels==0
%             classStruct(iMeasure).accData = accData;
%         elseif permuteLabels==1
%             classStructPerm(iMeasure).accData = accData;
%         end
% 
%     end
% end
% 
% save([sourceDir '/' 'CLASSIFICATION_DATA.mat'],'classStruct','classStructPerm','grandMatHeaders')
% 
% 
% 
% 
% 
% 
% 
% 









        
        
        
% correctTrials=0;
% 
% for iTrial = 1:nTrials
%     
%     
%     
%     testData = thisData(iTrial,:);
%     testMember = trialLocs(iTrial);
%     trainIdx = setdiff(1:nTrials,iTrial);
%     trainData = thisData(trainIdx,:);
%     trainMember = trialLocs(trainIdx);
%     p=repmat(1/6,1,6);
%     
%     %force a uniform prior, to ensure that the classifier doesn't just merely use class frequency
%     %                   to determine the descriminant function. i.e.,
%     %
%     
%     % vanilla matlab classifier. the 'lin' flag specifies a linear
%     % classifier that fits a multivariate normal density to each group,
%     % with a pooled estimate of covariance. see lines 223-237 in
%     % classify.m. then the label for any given trial is determined by
%     % the density function that is closest to the test trial.
%     
%     Labels=classify(testData,trainData,trainMember,'lin',p);
%     
%     
%     if length(Labels)==1
%         if Labels==testMember
%             correctTrials=correctTrials+1;
%         end
%     else
%         correctTrials=correctTrials+length(find(Labels==testMember));
%     end
%     
%     % create confusion matrix
%     %confMtx(testMember,Labels)=confMtx(testMember,Labels)+1;
%     %classCtr(testMember)=classCtr(testMember)+1;
%     
%     
%     
%     
% end
% 
% % compute accuracy
% accData=correctTrials/nTrials;
% 
% %  conf matrix p
% pConfMtx=confMtx./classCtr'; % WHY rotate???
% 
% 
% 
% 
% 
% end
% end



