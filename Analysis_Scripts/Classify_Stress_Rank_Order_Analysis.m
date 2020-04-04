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

for iMeasure=1:8
    
    iMeasure
    
    if iMeasure==1
        theseData = all_BP;
    elseif iMeasure==2
        theseData = all_CO;
    elseif iMeasure==3
        theseData = all_HF;
    elseif iMeasure==4
        theseData = all_HR;
    elseif iMeasure==5
        theseData = all_LVET;
    elseif iMeasure==6
        theseData = all_PEP;
    elseif iMeasure==7
        theseData = all_SV;
    elseif iMeasure==8
        theseData = all_TPR;
    end
    
    
    % do rank order analysis for all 5 trials within subs
    for iSub=1:28
        
        for t=1:size(theseData,4)
            
            thisSubData = squeeze(theseData(iSub,:,:,t));
            
            correctTrials=0;
            for iTrial=1:5
                if thisSubData(iTrial,1)>thisSubData(iTrial,2)
                    correctTrials=correctTrials+1;
                end
            end
            allCorrectTrials(iMeasure,iSub,t)=correctTrials/5;
            
            % flip correct trials for some measures
            if ismember(iMeasure,[3,5,7,8,6])
                allCorrectTrials(iMeasure,iSub,t) = 1- allCorrectTrials(iMeasure,iSub,t) ;
            end
            
        end
        
    end
    
    
    % do rank order analysis for all 5 trials within subs [PERMUTED]
    for perm=1:1000
        perm;
        for iSub=1:28
            
            for t=1:size(theseData,4)
                
                clear thisSubData
                
                thisSubData = squeeze(theseData(iSub,:,:,t));
                
                % permute sub data
                for i=1:5
                    randIdx = randperm(2);
                    thisSubData(i,:) = thisSubData(i,randIdx);
                end
                
                %thisSubData
                
                correctTrials=0;
                for iTrial=1:5
                    if thisSubData(iTrial,1)>thisSubData(iTrial,2)
                        correctTrials=correctTrials+1;
                    end
                end
                allCorrectTrialsPerm(iMeasure,iSub,t,perm)=correctTrials/5;
                
                % flip correct trials for some measures
                if ismember(iMeasure,[3,5,7,8,6])
                    allCorrectTrialsPerm(iMeasure,iSub,t,perm) = 1- allCorrectTrialsPerm(iMeasure,iSub,t,perm) ;
                end
                
            end
            
        end
    end
    
    
    
    
    
    
    % do rank order analyses for each trial separately
    for iSub=1:28
        for t=1:size(theseData,4)
            
            thisSubData = squeeze(theseData(iSub,:,:,t));
            
            for iTrial=1:5
                correctTrials=0;
                
                
                if ismember(iMeasure,[1,2,4])
                    
                    if thisSubData(iTrial,1)>thisSubData(iTrial,2)
                        allCorrectTrialsByDip(iMeasure,iSub,iTrial,t)=correctTrials+1;
                    else
                        allCorrectTrialsByDip(iMeasure,iSub,iTrial,t)=correctTrials;
                    end
                    
                else
                    
                    if thisSubData(iTrial,1)>thisSubData(iTrial,2)
                        allCorrectTrialsByDip(iMeasure,iSub,iTrial,t)=correctTrials+1;
                    else
                        allCorrectTrialsByDip(iMeasure,iSub,iTrial,t)=correctTrials;
                    end
                    
                end
                
            end
            
%             % flip correct trials for some measures
%             if ismember(iMeasure,[3,5,7,8,6])
%                 allCorrectTrialsByDip(iMeasure,iSub,iTrial,t) = 1- allCorrectTrialsByDip(iMeasure,iSub,t) ;
%             end
        
        end        
    end
    
    
    
    
    % do rank order analyses for each trial separately [PERMUTED]
    for perm=1:1000
        for iSub=1:28
            for t=1:size(theseData,4)
                
                thisSubData = squeeze(theseData(iSub,:,:,t));
                
                %permute sub data
                for i=1:5
                    randIdx = randperm(2);
                    thisSubData(i,:) = thisSubData(i,randIdx);
                end
                
                for iTrial=1:5
                    correctTrials=0;
                    
                    if ismember(iMeasure,[1,2,4])
                        
                        if thisSubData(iTrial,1)>thisSubData(iTrial,2)
                            allCorrectTrialsByDipPerm(iMeasure,iSub,iTrial,t,perm)=correctTrials+1;
                        else
                            allCorrectTrialsByDipPerm(iMeasure,iSub,iTrial,t,perm)=correctTrials;
                        end
                        
                    else
                        
                        if thisSubData(iTrial,1)>thisSubData(iTrial,2)
                            allCorrectTrialsByDipPerm(iMeasure,iSub,iTrial,t,perm)=correctTrials+1;
                        else
                            allCorrectTrialsByDipPerm(iMeasure,iSub,iTrial,t,perm)=correctTrials;
                        end
                        
                    end
                    
                end
                
                %             % flip correct trials for some measures
                %             if ismember(iMeasure,[3,5,7,8,6])
                %                 allCorrectTrialsByDip(iMeasure,iSub,iTrial,t) = 1- allCorrectTrialsByDip(iMeasure,iSub,t) ;
                %             end
                
            end
        end
    end
    
    
    
    
    
end

allCorrectTrialsPerm=squeeze(mean(allCorrectTrialsPerm,4));
allCorrectTrialsByDipPerm = squeeze(mean(allCorrectTrialsByDipPerm,5));

save([destDir '/' 'Classify_Stress_Rank_Order.mat'],'allCorrectTrials','allCorrectTrialsPerm','allCorrectTrialsByDip','allCorrectTrialsByDipPerm');