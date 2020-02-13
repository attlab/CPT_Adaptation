%{
EEG_ICLabel_Get_Classification_Stats
Author: Tom Bullock, UCSB Attention Lab
Date: 07.01.20

Calculate the proportion of each component class present in each dataset,
average and then

%}

sourceDir = '/home/bullock/BOSS/CPT_Adaptation/EEG_ICA_Notch_IC_Label';

subjects = CPT_SUBJECTS;

clear classCount

for iSub=1:length(subjects)
    
    sjNum=subjects(iSub)
    
    for iSession=1:2
        
        load([sourceDir '/' sprintf('sj%d_se%02d_EEG_clean_ica.mat',sjNum,iSession+1)])
        
        clear x
        [~,x]=max(EEG.etc.ic_classification.ICLabel.classifications');
        
        for bin=1:7   
            classCount(iSub,iSession,bin)=numel(find(x==bin))./length(x);         
        end
        
    end
    
end

labels = EEG.etc.ic_classification.ICLabel.classes

classMeans = [squeeze(mean(classCount(:,1,:),1)),squeeze(mean(classCount(:,2,:),1))]'

[h,p,~,stats] = ttest(squeeze(classCount(:,1,:)),squeeze(classCount(:,2,:)));
h





