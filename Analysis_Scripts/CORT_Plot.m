%{
Cortisol_Plot
Author: Tom Bullock, UCSB Attention Lab
Date:12.17.19

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
[~,subjects] = CPT_SUBJECTS
subjects(1)=[]; % get rid of 102;

% apply subs list
subIdx = ismember(cortisol_CPT(:,1)',subjects);
cortisol_CPT(~subIdx,:) = [];

% plot data
errorbar(mean(cortisol_CPT(:,4:6),1),std(cortisol_CPT(:,4:6),0,1)./sqrt(size(cortisol_CPT,1)),...
    'LineWidth',2.5,...
    'Color',[51,153,255]./255); hold on

% plot data
errorbar(mean(cortisol_CPT(:,7:9),1),std(cortisol_CPT(:,7:9),0,1)./sqrt(size(cortisol_CPT,1)),...
    'LineWidth',2.5,...
    'Color',[255,51,51]./255)

pbaspect([2,1,1])

set(gca,'LineWidth',1.5,...
    'fontsize',18,...
    'xlim',[0.8,3.2],...
    'box','off',...
    'xTick',[1,2,3],...
    'xTickLabel',{'Pre T1','Pre T3','Post T5'},...
    'ylim',[2,14])