%{
Correlate_VO2max_with_Stress_Measures
Author: Tom Bullock
Date: 01.03.19

Nothing there, really
%}

clear 
close all

sourceDir = '/home/bullock/BOSS/CPT_Adaptation/Data_Compiled';

load([sourceDir '/' 'GRAND_MATS_ALL_DATA.mat'])

for j=1:5
    allMeasures = squeeze(grandMatSingle(:,j,1:9));
    vo2Measure = squeeze(grandMatSingle(:,j,10));
    
    figure;
    for i=1:9
        subplot(3,3,i)
        [rho,p]=corr(allMeasures(:,i),vo2Measure,'rows','complete')
        scatter(allMeasures(:,i),vo2Measure)
        lsline
        title([num2str(rho) '  -  ' num2str(p)])
        ylabel('VO2max')
        xlabel(grandMatHeaders(i))
    end
    
end