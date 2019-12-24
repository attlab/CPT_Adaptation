%{
ERSP_Compile
Author: Tom Bullock, UCSB Attention Lab
Date: 05.25.19
%}

function Time_Freq_Analysis_ERSP_Compile


analysisType=2;

clear erspAll chanlocs times freqs

if analysisType==0
    sourceDir = '/home/bullock/BOSS/CPT_Adaptation/Time_Freq_Results_1-500Hz';
    destDir = '/home/bullock/BOSS/CPT_Adaptation/Data_Compiled';
elseif analysisType==1
    sourceDir = '/home/bullock/BOSS/CPT_Adaptation/Time_Freq_Results_1-100Hz';
    destDir = '/home/bullock/BOSS/CPT_Adaptation/Data_Compiled';
elseif analysisType==2
    sourceDir = '/home/bullock/BOSS/CPT_Adaptation/Time_Freq_Results_1-30Hz_ICA_Occ_Rej';
    destDir = '/home/bullock/BOSS/CPT_Adaptation/Data_Compiled';
elseif analysisType==3
    sourceDir = '/home/bullock/BOSS/CPT_Adaptation/Time_Freq_Results_1-30Hz_ICA_Brain_80';
    destDir = '/home/bullock/BOSS/CPT_Adaptation/Data_Compiled';
elseif analysisType==4
    sourceDir = '/home/bullock/BOSS/CPT_Adaptation/Time_Freq_Results_1-30Hz_ICA_Brain_60';
    destDir = '/home/bullock/BOSS/CPT_Adaptation/Data_Compiled';
elseif analysisType==5
    sourceDir = '/home/bullock/BOSS/CPT_Adaptation/Time_Freq_Results_1-30Hz_ICA_Brain_Other_Top';
    destDir = '/home/bullock/BOSS/CPT_Adaptation/Data_Compiled';
end




%% select subjects
subjects = CPT_SUBJECTS;
disp(['Processing n=' num2str(length(subjects)) ' subjects'])

%% load subject event order
load([destDir '/' 'Task_Order.mat'])

%% compile individual ERSPs into one GRAND_ERSP [CHECK THIS - THINK OK NOW]
for iSub=1:length(subjects)
    sjNum=subjects(iSub)
    if analysisType==0
        load([sourceDir '/' sprintf('sj%d_ersp_1-500Hz.mat',sjNum)])
    elseif analysisType==1
        load([sourceDir '/' sprintf('sj%d_ersp_1-100Hz.mat',sjNum)])
    elseif analysisType>1
        load([sourceDir '/' sprintf('sj%d_ersp_1-30Hz.mat',sjNum)])
    end
    erspAll(iSub,:,:,:,:,:) = ersp;
end

if analysisType==0
    save([destDir '/' 'GRAND_ERSP_1-500Hz.mat'],'erspAll','taskOrderStruct','chanlocs','times','freqs')
elseif analysisType==1
    save([destDir '/' 'GRAND_ERSP_1-100Hz.mat'],'erspAll','taskOrderStruct','chanlocs','times','freqs')
elseif analysisType==2
    save([destDir '/' 'GRAND_ERSP_1-30Hz_ICA_Occ_Rej.mat'],'erspAll','taskOrderStruct','chanlocs','times','freqs')
elseif analysisType==3
    save([destDir '/' 'GRAND_ERSP_1-30Hz_ICA_Brain_80.mat'],'erspAll','taskOrderStruct','chanlocs','times','freqs')
elseif analysisType==4
    save([destDir '/' 'GRAND_ERSP_1-30Hz_ICA_Brain_60.mat'],'erspAll','taskOrderStruct','chanlocs','times','freqs')
elseif analysisType==5
    save([destDir '/' 'GRAND_ERSP_1-30Hz_ICA_Brain_Other_Top.mat'],'erspAll','taskOrderStruct','chanlocs','times','freqs')
end

% if analysisType==1
%     save([destDir '/' 'GRAND_ERSP_1-30Hz.mat'],'erspAll','taskOrderStruct','chanlocs','times','freqs')
% else
%     save([destDir '/' 'GRAND_ERSP_1-100Hz.mat'],'erspAll','taskOrderStruct','chanlocs','times','freqs')
%     %%save([destDir '/' 'GRAND_ERSP_1-30Hz.mat'],'erspAll','taskOrderStruct')
% end


return