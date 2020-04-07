%{
ERSP_Compile
Author: Tom Bullock, UCSB Attention Lab
Date: 05.25.19
%}

function Time_Freq_Analysis_ERSP_Compile(analysisType)


%analysisType=2;

clear erspAll chanlocs times freqs

if analysisType==0
    sourceDir = '/home/bullock/BOSS/CPT_Adaptation/Time_Freq_Results_1-500Hz';
elseif analysisType==1
    sourceDir = '/home/bullock/BOSS/CPT_Adaptation/Time_Freq_Results_1-100Hz';
elseif analysisType==2
    sourceDir = '/home/bullock/BOSS/CPT_Adaptation/Time_Freq_Results_1-30Hz_ICA_Occ_Rej';
elseif analysisType==3
    sourceDir = '/home/bullock/BOSS/CPT_Adaptation/Time_Freq_Results_1-30Hz_ICA_Brain_80';
elseif analysisType==4
    sourceDir = '/home/bullock/BOSS/CPT_Adaptation/Time_Freq_Results_1-30Hz_ICA_Brain_60';
elseif analysisType==5
    sourceDir = '/home/bullock/BOSS/CPT_Adaptation/Time_Freq_Results_1-30Hz_ICA_Brain_Other_Top';
elseif analysisType==6
    sourceDir = '/home/bullock/BOSS/CPT_Adaptation/Time_Freq_results_1-30Hz_ICLabel_Dipfit';
end

destDir = '/home/bullock/BOSS/CPT_Adaptation/Data_Compiled';


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
    save([destDir '/' 'GRAND_ERSP_1-100Hz.mat'],'erspAll','taskOrderStruct','chanlocs','times','freqs','-v7.3')
elseif analysisType==2
    save([destDir '/' 'GRAND_ERSP_1-30Hz_ICA_Occ_Rej.mat'],'erspAll','taskOrderStruct','chanlocs','times','freqs')
elseif analysisType==3
    save([destDir '/' 'GRAND_ERSP_1-30Hz_ICA_Brain_80.mat'],'erspAll','taskOrderStruct','chanlocs','times','freqs')
elseif analysisType==4
    save([destDir '/' 'GRAND_ERSP_1-30Hz_ICA_Brain_60.mat'],'erspAll','taskOrderStruct','chanlocs','times','freqs')
elseif analysisType==5
    save([destDir '/' 'GRAND_ERSP_1-30Hz_ICA_Brain_Other_Top.mat'],'erspAll','taskOrderStruct','chanlocs','times','freqs')
elseif analysisType==6
    save([destDir '/' 'GRAND_ERSP_1-30Hz_ICA_ICLabel_Dipfit_50HzLP.mat'],'erspAll','taskOrderStruct','chanlocs','times','freqs')
end

% if analysisType==1
%     save([destDir '/' 'GRAND_ERSP_1-30Hz.mat'],'erspAll','taskOrderStruct','chanlocs','times','freqs')
% else
%     save([destDir '/' 'GRAND_ERSP_1-100Hz.mat'],'erspAll','taskOrderStruct','chanlocs','times','freqs')
%     %%save([destDir '/' 'GRAND_ERSP_1-30Hz.mat'],'erspAll','taskOrderStruct')
% end


return