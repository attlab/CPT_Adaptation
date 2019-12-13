%{
ERSP_Compile
Author: Tom Bullock, UCSB Attention Lab
Date: 05.25.19
%}

function Time_Freq_Analysis_FFT_Compile

%% set dirs
sourceDir = '/home/bullock/BOSS/CPT_Adaptation/Spectra_Results_IC_Label';
destDir = '/home/bullock/BOSS/CPT_Adaptation/Data_Compiled';


%% select subjects
subjects = CPT_SUBJECTS;
disp(['Processing n=' num2str(length(subjects)) ' subjects'])

%% load subject event order
load([destDir '/' 'Task_Order.mat'])

%% compile individual ERSPs into one GRAND_ERSP [CHECK THIS - THINK OK NOW]
for iSub=1:length(subjects)
    sjNum=subjects(iSub)
    load([sourceDir '/' sprintf('sj%d_spectra.mat',sjNum)]);
    specMaster(iSub,:,:,:,:,:)=allSpec;
end
    
save([destDir '/' 'SPECTRA_MASTER.mat'],'specMaster','taskOrderStruct','chanlocs','freqs')
 
return