%{
Extract_Timestamps_CPT_Exposures
Author: Tom Bullock
Date:04.29.22
%}

clear
close all

% set dirs
Parent_dir = '/home/bullock/BOSS/CPT_Adaptation/';
EEGraw_dir = [Parent_dir 'EEG_CPT_Prepro/'];
taskOrder_dir = [Parent_dir 'Data_Compiled/'];

% get subjects
subjects = CPT_SUBJECTS;

for iSub=1:length(subjects)
    subject=subjects(iSub)
    for session = 1:2
        
        % load data for all 5 trials and merge into a single file
        load([taskOrder_dir 'Task_Order.mat']);
        rowIndex = find(taskOrderStruct.sjNums==subject);
        thisTemporalTaskOrder = squeeze(taskOrderStruct.allTaskOrder(rowIndex,session,:));
        for iTask=1:5
            load([EEGraw_dir '/' sprintf('sj%d_se%02d_%s.mat',subject,session+1,thisTemporalTaskOrder{iTask+1}) ])
            all_datetime(iSub,session,iTask) = EEG.dateTime;
            clear EEG
        end
        
    end
end

%save([taskOrder_dir, 'CPT_Exposure_Timestamps.mat'],'all_datetime')


for i=1:length(all_datetime)
    for j=1:2
        all_inter_dip_intervals(i,j,1) = all_datetime(i,j,2) - all_datetime(i,j,1);
        all_inter_dip_intervals(i,j,2) = all_datetime(i,j,3) - all_datetime(i,j,2);
        all_inter_dip_intervals(i,j,3) = all_datetime(i,j,4) - all_datetime(i,j,3);
        all_inter_dip_intervals(i,j,4) = all_datetime(i,j,5) - all_datetime(i,j,4);
    end
end

inter_dip_summary.total_mean = mean(mean(mean(all_inter_dip_intervals,1),2),3);
inter_dip_summary.total_sd = mean(mean(std(all_inter_dip_intervals),2),3);
inter_dip_summary.total_max = max(max(max(all_inter_dip_intervals)));
inter_dip_summary.total_min = min(min(min(all_inter_dip_intervals)));

save([taskOrder_dir, 'CPT_Exposure_Timestamps.mat'],'all_datetime','inter_dip_summary','subjects')



