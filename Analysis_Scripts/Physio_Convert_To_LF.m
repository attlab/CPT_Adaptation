%{
Physio_Convert_To_Long_Format
Author: Tom Bullock
Date: 02.19.20
%}

clear
close all

sourceDir = '/home/bullock/BOSS/CPT_Adaptation/Data_Compiled';
destDir = '/home/bullock/BOSS/CPT_Adaptation/Data_Compiled/LF_DATA';

whichData = 0; % 0=raw uncorrected, 1= baseline corrected norm'd

if whichData==0
    load([sourceDir '/' 'PHYSIO_Clean_Uncorr.mat'])
    dataType = 'raw';
elseif whichData==1
    load([sourceDir '/' 'PHYSIO_Clean_Bl_Corr_Norm.mat'])
    dataType = 'bln';
end
    

for d=1:8
    
    
    if d==1
        theseData = all_BP;
        dataID = 'BP';
        theseSubjects = setdiff(subjects, badSubjects_BP_TPR);
    elseif d==2
        theseData = all_TPR;
        dataID = 'TPR';
        theseSubjects = setdiff(subjects, badSubjects_BP_TPR);
    elseif d==3
        theseData = all_HF;
        dataID = 'HF';
        theseSubjects = setdiff(subjects, badSubjects_HF);
    elseif d==4
        theseData = all_CO;
        dataID = 'CO';
        theseSubjects = setdiff(subjects, badSubjects_CO_HR_LVET_PEP_SV);
    elseif d==5
        theseData = all_HR;
        dataID = 'HR';
        theseSubjects = setdiff(subjects, badSubjects_CO_HR_LVET_PEP_SV);
    elseif d==6
        theseData = all_LVET;
        dataID = 'LVET';
        theseSubjects = setdiff(subjects, badSubjects_CO_HR_LVET_PEP_SV);
    elseif d==7
        theseData = all_PEP;
        dataID = 'PEP';
        theseSubjects = setdiff(subjects, badSubjects_CO_HR_LVET_PEP_SV);
    elseif d==8
        theseData = all_SV;
        dataID = 'SV';
        theseSubjects = setdiff(subjects, badSubjects_CO_HR_LVET_PEP_SV);
    end
        
    for i=1:size(theseData,2) % trial loop
        for j=1:size(theseData,3) % session loop
            for k=1:size(theseData,4) % time loop
                
                k
                
                thisSample = theseData(:,i,j,k);
                
                dumTrial = repmat(i,[length(theseSubjects),1]);
                dumSession = repmat(j,[length(theseSubjects),1]);
                dumTime = repmat(k,[length(theseSubjects),1]);
                
                if i==1 && j==1 && k==1
                    theseDataLF(1:length(theseSubjects),1:5) = [theseSubjects',dumSession,dumTrial,dumTime,thisSample];
                else
                    m = size(theseDataLF,1);
                    n = size(theseData,1);
                    theseDataLF(m+1:m+n,1:5) = [theseSubjects',dumSession,dumTrial,dumTime,thisSample];
                end
                
            end
        end
    end
    
    % write LF data to csv
    csvwrite([destDir '/' 'Physio_' dataType '_' dataID '.csv'],theseDataLF)
    
    clear theseDataLF theseData theseSubjects dataID thisSample dumTime dumTrial dumSession i j k m n
    
    
end




