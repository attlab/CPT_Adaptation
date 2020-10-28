%{
Cortisol_Stats_Resample_TOD
Author: Tom Bullock
Date: 07.25.20

Run a mixed ANOVA (with TOD as between subjects factor)

%}


clear
close all

% set dirs
sourceDir = '/home/bullock/BOSS/CPT_Adaptation/Data_Compiled';

% add plotting functions to path
addpath(genpath('/home/bullock/matlab_2016b/TOOLBOXES/plotSpread'))

% load data
load([sourceDir '/' 'Cortisol_CPT_Master.mat'])

% load subs list
[~,subjects] = CPT_SUBJECTS;
subjects(1)=[]; % get rid of 102;

% apply subs list
subIdx = ismember(cortisol_CPT(:,1)',subjects);
cortisol_CPT(~subIdx,:) = [];

% rearrange matrix for subject
dataMat(:,:,1) = cortisol_CPT(:,4:6);
dataMat(:,:,2) = cortisol_CPT(:,7:9);

% creates between factors vector
between_factors = cortisol_CPT(:,10);

% create factor names
within_factor_names = {'Sample','Condition'};
between_factor_names = {'TOD'};

% run ANOVA with TOD as a between subs factor
tbl = simple_mixed_anova(dataMat,between_factors,within_factor_names,between_factor_names)

% run ANOVA with just within subjects factors
%tbl = simple_mixed_anova(dataMat,[],within_factor_names,[])


% tbl = simple_mixed_anova(datamat, between_factors, {'Time', 'Exp_cond'},
% {'Gender', 'Age_group'})




