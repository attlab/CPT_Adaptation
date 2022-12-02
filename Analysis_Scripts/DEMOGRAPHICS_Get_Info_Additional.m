
allSubsInTable = [t.SjNum{2:end}];

allSubsCPT = [102,103,105,108,109,111,114,115,116,117,118,119,121,123,124,125,126,127,128,130,132,133,135,136,138,139,140,143,144,146,147,148,149,150,151,154,155,156,157,158,159,160,161];

[vals, idx] = setdiff(allSubsInTable,allSubsCPT);

% save original table under different name
t_orig = t;

% remove first row of table with descriptions (redundant)
t(1,:) = [];

% remove non-CPT subjects
t(idx,:) = [];

% save CPT ONLY Table
save(['/home/bullock/BOSS/CPT_Adaptation/Data_Compiled' '/' 'Questionnaire_Data_CPT_Subs_Only.mat'],'t')



% 9/Q434 - do you identify yourself as...
for i=1:height(t)
    if size(cell2mat(t{i,9}),2)==1
        ethnicity_mat(i) = str2double(cell2mat(t{i,9}));    
    end  
end

ethnic.white_caucasian = sum(ethnicity_mat==1);
ethnic.hispanic_latino_spanish = sum(ethnicity_mat==2);
ethnic.black_african_american = sum(ethnicity_mat==3);
ethnic.asian = sum(ethnicity_mat==4);
ethnic.american_indian_alaska_native = sum(ethnicity_mat==5);
ethnic.middle_eastern_north_african = sum(ethnicity_mat==6);
ethnic.hawaiian = sum(ethnicity_mat==8);
ethnic.other = sum(ethnicity_mat==9);
%manually added these
ethnic.white_hispanic = 3;
ethnic.white_asian = 1;
ethnic.hispanic_asian = 1;
ethnic.middle_eastern_north_african_other = 1;


% 10/Q435 - what is your current employment status? [manual]
employment_status.student = 18
employment_status.unemployed = 4 
employment_status.employed = 5
employment_status.student_employed = 11
employment_status.student_umemployed = 5


% 11/Q436 - what is the highest level of education you completed?
for i=1:height(t)
    if size(cell2mat(t{i,11}),2)==1
        education_mat(i) = cell2mat(t{i,11});    
    end  
end

education_level_highest.less_than_8th_grade = sum(education_mat==3);
education_level_highest.some_college = sum(education_mat==5);
education_level_highest.two_yr_college_degree = sum(education_mat==6);
education_level_highest.four_yr_college_degree = sum(education_mat==7);


% 14/Q438 - what is your combined total household income (annual)
% note I manually went through and edited the household income values to
% integer values.  NaNs represent no answers.
mean_income = nanmean(cell2mat(t{:,14}));

% categorize into different household income groups
cnt1=0;cnt2=0;cnt3=0;cnt4=0;cnt5=0;cnt6=0; cnt =0;
for i=1:height(t)
    
    this_income = cell2mat(t{i,14});
    
    if this_income <=20000 
        cnt1=cnt1+1;
    elseif this_income >20000 && this_income <= 34999
        cnt2=cnt2+1;
    elseif this_income >=35000 && this_income <= 49999
        cnt3=cnt3+1;
    elseif this_income >=50000 && this_income <=74999
        cnt4=cnt4+1;
    elseif this_income >=75000 && this_income <=100000
        cnt5=cnt5+1;
    elseif this_income >100000
        cnt6=cnt6+1;
    else
        i
    end
    
    cnt=cnt+1;
end








