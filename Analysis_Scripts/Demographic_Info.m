%{
Demographic_Info
Author: Tom Bullock, UCSB Attention Lab
Date: 12.27.19

%}

clear
close all

% load subject numbers for inclusion
[~,subjects] = CPT_SUBJECTS;
subjects(1)=[];

% load demographics
load('/home/bullock/BOSS/CPT_Adaptation/Data_Compiled/Subject_Log_Master_Updated.mat')

% isolate rows in subject log
for i=1:198
    sjIdx(i) = t.Subject_ID{i,1};
end
sjTableIdx = ismember(sjIdx,subjects);

% create table CPT subject info only
cpt_sjInfo = t(sjTableIdx,:);

% get number of males
maleCnt=0;
for i=1:height(cpt_sjInfo)
   if strcmp(cpt_sjInfo.Sex{i},'M')
      maleCnt=maleCnt+1;  
   end
end

clear ans sjIdx sjTableIdx t



% % get ages (from other sheet, presumably)
% clear t
% load('/home/bullock/BOSS/CPT_Adaptation/Data_Compiled/BOSS_Questionnaire_Data.mat')
% %t(1,:) = [];
% clear sjIdx_quaire
% for i=2:height(t)
%     sjIdx_quaire(i) = t.SjNum{i,1};
% end
% 
% % create table for CPET subs only (lost info on top row, will need to fix
% % eventually)!
% cpt_subs_qaire_only = ismember(sjIdx_quaire,subjects)
% cpt_quaire_info = t(cpt_subs_qaire_only,:);
% 
% for i=1:height(cpt_quaire_info)
%    ageMat(i) = cpt_quaire_info.Q433{i}
% end
% 
% meanAge = mean(ageMat);
% semAge = std(ageMat)/sqrt(size(ageMat,2));
% 
% clear ageMat cpt_subs_qaire_only i sjIdx_quaire t



% get VO2max scores
load('/home/bullock/BOSS/CPT_Adaptation/Data_Compiled/CPET_MASTER.mat')
cnt=0;
for i=1:length(allCPET)
    if ismember(allCPET(i).sjNum,subjects)
        cnt=cnt+1;
        cpetSjIdx(cnt)=i;
    end 
end
cpet_sjInfo = allCPET(cpetSjIdx);

% extract data
maleCnt=0;
femaleCnt=0;
clear maleStruct femaleStruct
for i=1:length(cpet_sjInfo)

   if strcmp(cpet_sjInfo(i).sjInfo.thisGender,'male')
       maleCnt=maleCnt+1;
       maleStruct(maleCnt) = cpet_sjInfo(i);
   elseif strcmp(cpet_sjInfo(i).sjInfo.thisGender,'female')
       femaleCnt=femaleCnt+1;
       femaleStruct(femaleCnt) = cpet_sjInfo(i);
   end
   
end

for i=1:length(maleStruct)
   males.age_mat(i) = maleStruct(i).sjInfo.thisAge;
   males.bmi_mat(i) = maleStruct(i).sjInfo.thisBMI;
   males.weight_mat(i) = maleStruct(i).sjInfo.thisWeight;
   males.vo2max_mat(i) = maleStruct(i).vo2max_orig;
end

for i=1:length(femaleStruct)
   females.age_mat(i) = femaleStruct(i).sjInfo.thisAge;
   females.bmi_mat(i) = femaleStruct(i).sjInfo.thisBMI;
   females.weight_mat(i) = femaleStruct(i).sjInfo.thisWeight;
   females.vo2max_mat(i) = femaleStruct(i).vo2max_orig;
end

males.n=length(maleStruct);
females.n = length(femaleStruct);

% get mean, sd, sem
males.mean.age = mean(males.age_mat);
males.mean.bmi = mean(males.bmi_mat);
males.mean.vo2max = mean(males.vo2max_mat);

males.sem.age = std(males.age_mat)/sqrt(length(males.age_mat));
males.sem.bmi = std(males.bmi_mat)/sqrt(length(males.bmi_mat));
males.sem.vo2max = std(males.vo2max_mat)/sqrt(length(males.vo2max_mat));

females.mean.age = mean(females.age_mat);
females.mean.bmi = mean(females.bmi_mat);
females.mean.vo2max = mean(females.vo2max_mat);

females.sem.age = std(females.age_mat)/sqrt(length(females.age_mat));
females.sem.bmi = std(females.bmi_mat)/sqrt(length(females.bmi_mat));
females.sem.vo2max = std(females.vo2max_mat)/sqrt(length(females.vo2max_mat));

both.sem.age = std([males.age_mat  females.age_mat])/sqrt(length([males.age_mat females.age_mat]));
both.sem.bmi = std([males.bmi_mat  females.bmi_mat])/sqrt(length([males.bmi_mat females.bmi_mat]));
both.sem.vo2 = std([males.vo2max_mat  females.vo2max_mat])/sqrt(length([males.vo2max_mat females.vo2max_mat]));


   vo2max_mat(i) = cpet_sjInfo(i).vo2max_orig;  
   bmi_mat(i) = cpet_sjInfo(i).sjInfo.thisBMI;

   
   meanVO2max = mean(vo2max_mat);
    semVO2max = std(vo2max_mat,0,2) /sqrt(length(cpet_sjInfo));






clear allCPET cnt cpetSjIdx i vo2max_mat




% get all subject info split by sex




