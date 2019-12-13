%{
ERSP_Compile
Author: Tom Bullock, UCSB Attention Lab
Date: 05.25.19
%}

function Time_Freq_Analysis_ERSP_Compile

for analysisType=1:2
    
    clear erspAll chanlocs times freqs
    
    sourceDir = '/home/bullock/BOSS/CPT_Adaptation/Time_Freq_Results_IC_Label';
    destDir = '/home/bullock/BOSS/CPT_Adaptation/Data_Compiled';
    
    
    %% select subjects
    subjects = CPT_SUBJECTS;
    disp(['Processing n=' num2str(length(subjects)) ' subjects'])
    
    %% load subject event order
    load([destDir '/' 'Task_Order.mat'])
    
    %% compile individual ERSPs into one GRAND_ERSP [CHECK THIS - THINK OK NOW]
    for iSub=1:length(subjects)
        sjNum=subjects(iSub)
        if analysisType==1
            load([sourceDir '/' sprintf('sj%d_ersp_30.mat',sjNum)])
        else
            load([sourceDir '/' sprintf('sj%d_ersp_100.mat',sjNum)])
        end
        erspAll(iSub,:,:,:,:,:) = ersp;
    end
    
    if analysisType==1
        save([destDir '/' 'GRAND_ERSP_1-30Hz.mat'],'erspAll','taskOrderStruct','chanlocs','times','freqs')
    else
        save([destDir '/' 'GRAND_ERSP_1-100Hz.mat'],'erspAll','taskOrderStruct','chanlocs','times','freqs')
        %%save([destDir '/' 'GRAND_ERSP_1-30Hz.mat'],'erspAll','taskOrderStruct')
    end
end

return