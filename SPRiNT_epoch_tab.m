function [] = SPRiNT_epoch_tab(PtID, Hemi)

% Inputs 
% PtID = 'CLASE007';
% Hemi = 'L_AMY';

HemiSplit = split(Hemi, '_');
HemiTab = HemiSplit(1);
BAtab = HemiSplit(2);

% CD to patient data 
patLOC = ['Y:\LossAversion\Patient folders\', PtID,'\NeuroPhys_Processed\SPRiNT_Epochs'];
cd(patLOC)

% Load SPRiNT table
matDirA = dir('*.mat');
matDirB = string({matDirA.name});

tempFileLoad = matDirB{contains(matDirB,Hemi)};

load(tempFileLoad); % loads as sprintEpochTABLE

% Create tables
sprintTABLEOUT = table('Size', [540, 25], 'VariableTypes', {'char','char', 'char', ...
    'double', 'char', 'char', 'double', ...
    'double', 'double', 'double','double','double','double','double', ...
    'double','double','double','double','double','double','double','double', ... 
    'double','double','double'}, 'VariableNames', ...
    {'PartID','Hemi','BrainArea','BlockNum', 'TrialEvName', 'GambleType', 'Money', ...
    'Delta_f', 'Theta_f', 'Alpha_f', 'Beta_f', 'lGamma_f', ...
    'hGamma_f', 'Delta_a', 'Theta_a', 'Alpha_a', 'Beta_a', ...
    'lGamma_a','hGamma_a','Delta_len', 'Theta_len', 'Alpha_len', ...
    'Beta_len', 'lGamma_len', 'hGamma_len'});

sprintTABLEOUT(:, "PartID") = repmat({PtID}, height(sprintEpochTABLE),1);
sprintTABLEOUT{:, "Hemi"} = repmat({HemiTab}, height(sprintEpochTABLE),1);
sprintTABLEOUT{:, "BrainArea"} = repmat({BAtab}, height(sprintEpochTABLE),1);
sprintTABLEOUT{:, "BlockNum"} = sprintEpochTABLE.BlockNum;
sprintTABLEOUT{:, "TrialEvName"} = sprintEpochTABLE.TrialEvName;
sprintTABLEOUT{:, "GambleType"} = sprintEpochTABLE.GambleType;
sprintTABLEOUT{:, "Money"} = sprintEpochTABLE.Money;



for i = 1:height(sprintEpochTABLE)

    % Frequency %
    sprintTABLEOUT{i,"Delta_f"} = sprintEpochTABLE.Freq(i,1).Delta.AvgF;
    sprintTABLEOUT{i,"Theta_f"} = sprintEpochTABLE.Freq(i,1).Theta.AvgF;
    sprintTABLEOUT{i,"Alpha_f"} = sprintEpochTABLE.Freq(i,1).Alpha.AvgF;
    sprintTABLEOUT{i,"Beta_f"} = sprintEpochTABLE.Freq(i,1).Beta.AvgF;
    sprintTABLEOUT{i,"lGamma_f"} = sprintEpochTABLE.Freq(i,1).lGamma.AvgF;
    sprintTABLEOUT{i,"hGamma_f"} = sprintEpochTABLE.Freq(i,1).hGamma.AvgF;

    % Amplitude %
    sprintTABLEOUT{i,"Delta_a"} = sprintEpochTABLE.Amplitude(i,1).Delta.AvgAmp;
    sprintTABLEOUT{i,"Theta_a"} = sprintEpochTABLE.Amplitude(i,1).Theta.AvgAmp;
    sprintTABLEOUT{i,"Alpha_a"} = sprintEpochTABLE.Amplitude(i,1).Alpha.AvgAmp;
    sprintTABLEOUT{i,"Beta_a"} = sprintEpochTABLE.Amplitude(i,1).Beta.AvgAmp;
    sprintTABLEOUT{i,"lGamma_a"} = sprintEpochTABLE.Amplitude(i,1).lGamma.AvgAmp;
    sprintTABLEOUT{i,"hGamma_a"} = sprintEpochTABLE.Amplitude(i,1).hGamma.AvgAmp;

    % Num of freq
    sprintTABLEOUT{i, 'Delta_len'} = height(sprintEpochTABLE.Amplitude(i,1).Delta.allAmp);
    sprintTABLEOUT{i, 'Theta_len'} = height(sprintEpochTABLE.Amplitude(i,1).Theta.allAmp);
    sprintTABLEOUT{i, 'Alpha_len'} = height(sprintEpochTABLE.Amplitude(i,1).Alpha.allAmp);
    sprintTABLEOUT{i, 'Beta_len'} = height(sprintEpochTABLE.Amplitude(i,1).Beta.allAmp);
    sprintTABLEOUT{i, 'lGamma_len'} = height(sprintEpochTABLE.Amplitude(i,1).lGamma.allAmp);
    sprintTABLEOUT{i, 'hGamma_len'} = height(sprintEpochTABLE.Amplitude(i,1).hGamma.allAmp);

end % for / i 

% Save
cd(patLOC) % save in same folder 
saveNameSplit = split(tempFileLoad, '.');
saveName = [saveNameSplit{1} '.csv'];

writetable(sprintTABLEOUT, saveName);

end % function 