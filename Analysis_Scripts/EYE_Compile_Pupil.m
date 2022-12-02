%{
EYE_Compile_CPT_Pupil
Author: Tom Bullock, UCSB Attention Lab
Date: 09.16.18, updated 12.16.19
%}

clear
close all

%% set dirs
sourceDir = '/data/DATA_ANALYSIS/CPT/EYE_Processed'; % eye only (could set this to grab from MASTER struct if needed)
destDir = '/bigboss/BOSS/Projects/CPT_Adaptation/Data_Compiled';

%% get all CPT subjects (n=43)
[~,subjects] = CPT_SUBJECTS;

%% load subject task order
load([destDir '/' 'Task_Order.mat'])

%% loop through all subjects, sessions, tasks and grab eye data
for iSub=1:length(subjects)
    sjNum = subjects(iSub);
    disp(['Processing Subject ' num2str(sjNum)])
    
    for iSession=1:2 % 1=treatment,2=control
        
        % find the task order
        clear rowIndex thisTemporalTaskOrder
        rowIndex = find(taskOrderStruct.sjNums==sjNum);
        thisTemporalTaskOrder = squeeze(taskOrderStruct.allTaskOrder(rowIndex,iSession,:));
        
        for iTask=1:5
            
            % load data
            %load([sourceDir '/' sprintf('sj%d_se%02d_%s_ft_ev.mat',sjNum,iSession+1,thisTemporalTaskOrder{iTask+1})]);
            load([sourceDir '/' sprintf('sj%d_se%02d_%s.mat',sjNum,iSession+1,thisTemporalTaskOrder{iTask+1})]);
            
            % find start and end of whole CPT protocol
            thisStart = eyeMat.event.RMessages.time(1); % original
            thisEnd = thisStart + 195000;
            
            % rename stuff
            theseTimes = double(eyeMat.RawEdf.FSAMPLE.time);
            thesePA = double(eyeMat.RawEdf.FSAMPLE.pa);
            thesePA(thesePA == 0) = NaN; % replace blinks (0) with NaNs
            
            % find start timestamp index
            [c,startIndex] = min(abs(theseTimes - thisStart));
       
            % creater a grand matrix
            paMatAll(iSub,iSession,iTask,:,:) = thesePA(:,startIndex:startIndex+(195000/2));
            
        end
    end
end

% save grand matrix
save([destDir '/' 'CPT_EYE_Master.mat'],'paMatAll','subjects')