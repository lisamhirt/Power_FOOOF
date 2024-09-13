% T1 = readtable("CLASE007_L_AMY_SPRiNT.csv");
% T2 = readtable("CLASE007_R_AMY_SPRiNT.csv");
% 
% combineT = vertcat(T1,T2);

%%
function [] = csvCombineSPRINT(PartID)
% Inputs
% PartID = 'CLASE007'

patLOC = ['Y:\LossAversion\Patient folders\', PartID,'\NeuroPhys_Processed\SPRiNT_Epochs'];
cd(patLOC)

% Load SPRiNT csv files
csvDirA = dir('*.csv');
csvDirB = string({csvDirA.name});


for i = 1:length(csvDirB)

    tempfile = csvDirB(i);
    tempTab = readtable(tempfile);

    if i == 1
        T1 = tempTab;

    elseif i == 2 
        T2 = tempTab;

    elseif i == 3
        T3 = tempTab;

    else i == 4;
        T4 = tempTab;
    end % if else 
 
end % for / i

if length(csvDirB) == 1
    combineT = T1;
elseif length(csvDirB) == 2
    combineT = vertcat(T1,T2);
elseif length(csvDirB) == 3
    combineT = vertcat(T1,T2,T3);
else length(csvDirB) == 4
    combineT = vertcat(T1,T2,T3,T4);
end 

cd('Y:\LossAversion\LH_Data\SPRiNT_output')
saveName = [PartID, '_','sprint.csv'];

writetable(combineT, saveName);

end % function 