% Load data
cd('Y:\LossAversion\LH_tempSave\CLASE018\SprintEpochTable')
load("SPRINTepochs.mat")
%% Create tables
sprintTABLEOUT = table('Size', [540, 28], 'VariableTypes', {'double', 'char', 'char', 'double', ...
    'double', 'double', 'double','double','double','double','double', ...
    'double','double','double','double','double','double','double','double', ...
    'double','double','double','double','double','double','double','double', 'double'}, 'VariableNames', ...
    {'BlockNum', 'TrialEvName', 'GambleType', 'Money', ...
    'con1F_delta', 'con2F_delta', 'con1F_theta', 'con2F_theta', 'con1F_alpha', ...
    'con2F_alpha', 'con1F_beta', 'con2F_beta', 'con1F_lGamma', 'con2F_lGamma', ...
    'con1F_hGamma', 'con2F_hGamma', 'con1A_delta', 'con2A_delta', 'con1A_theta', ...
    'con2A_theta', 'con1A_alpha', 'con2A_alpha', 'con1A_beta', 'con2A_beta', ...
    'con1A_lGamma', 'con2A_lGamma','con1A_hGamma', 'con2A_hGamma'});

sprintTABLEOUT{:, "BlockNum"} = sprintEpochTABLE.BlockNum;
sprintTABLEOUT{:, "TrialEvName"} = sprintEpochTABLE.TrialEvName;
sprintTABLEOUT{:, "GambleType"} = sprintEpochTABLE.GambleType;
sprintTABLEOUT{:, "Money"} = sprintEpochTABLE.Money;
%%

numFreqTAB = table('Size', [540, 16], 'VariableTypes', {'double', 'char', ...
    'char','double','double', 'double', 'double', 'double', 'double', 'double', ...
    'double', 'double', 'double', 'double', 'double', 'double'}, ...
    'VariableNames', {'BlockNum', 'TrialEvName', 'GambleType', 'Money', ...
    'con1_delta', 'con2_delta', 'con1_theta', 'con2_theta', 'con1_alpha', ...
    'con2_alpha', 'con1_beta', 'con2_beta', 'con1_lGamma', 'con2_lGamma', ...
    'con1_hGamma', 'con2_hGamma'});

numFreqTAB{:,"BlockNum"} = sprintEpochTABLE.BlockNum;
numFreqTAB{:, "TrialEvName"} = sprintEpochTABLE.TrialEvName;
numFreqTAB{:, "GambleType"} = sprintEpochTABLE.GambleType;
numFreqTAB{:, "Money"} = sprintEpochTABLE.Money;

%%

for i = 1:height(sprintEpochTABLE)

    % if ~isempty(sprintEpochTABLE.Freq(i,1).con1)

        % Frequency %
        % Delta
        sprintTABLEOUT{i,"con1F_delta"} = sprintEpochTABLE.Freq(i,1).con1.Delta.AvgF;
        sprintTABLEOUT{i,"con2F_delta"} = sprintEpochTABLE.Freq(i,1).con2.Delta.AvgF;
        % Theta
        sprintTABLEOUT{i,"con1F_theta"} = sprintEpochTABLE.Freq(i,1).con1.Theta.AvgF;
        sprintTABLEOUT{i,"con2F_theta"} = sprintEpochTABLE.Freq(i,1).con2.Theta.AvgF;
        % Alpha
        sprintTABLEOUT{i,"con1F_alpha"} = sprintEpochTABLE.Freq(i,1).con1.Alpha.AvgF;
        sprintTABLEOUT{i,"con2F_alpha"} = sprintEpochTABLE.Freq(i,1).con2.Alpha.AvgF;
        % Beta
        sprintTABLEOUT{i,"con1F_beta"} = sprintEpochTABLE.Freq(i,1).con1.Beta.AvgF;
        sprintTABLEOUT{i,"con2F_beta"} = sprintEpochTABLE.Freq(i,1).con2.Beta.AvgF;
        % Low Gamma
        sprintTABLEOUT{i,"con1F_lGamma"} = sprintEpochTABLE.Freq(i,1).con1.lGamma.AvgF;
        sprintTABLEOUT{i,"con2F_lGamma"} = sprintEpochTABLE.Freq(i,1).con2.lGamma.AvgF;
        % High Gamma
        sprintTABLEOUT{i,"con1F_hGamma"} = sprintEpochTABLE.Freq(i,1).con1.hGamma.AvgF;
        sprintTABLEOUT{i,"con2F_hGamma"} = sprintEpochTABLE.Freq(i,1).con2.hGamma.AvgF;

        % Amplitude %
        % Delta
        sprintTABLEOUT{i,"con1A_delta"} = sprintEpochTABLE.Amplitude(i,1).con1.Delta.AvgAmp;
        sprintTABLEOUT{i,"con2A_delta"} = sprintEpochTABLE.Amplitude(i,1).con2.Delta.AvgAmp;
        % Theta
        sprintTABLEOUT{i,"con1A_theta"} = sprintEpochTABLE.Amplitude(i,1).con1.Theta.AvgAmp;
        sprintTABLEOUT{i,"con2A_theta"} = sprintEpochTABLE.Amplitude(i,1).con2.Theta.AvgAmp;
        % Alpha
        sprintTABLEOUT{i,"con1A_alpha"} = sprintEpochTABLE.Amplitude(i,1).con1.Alpha.AvgAmp;
        sprintTABLEOUT{i,"con2A_alpha"} = sprintEpochTABLE.Amplitude(i,1).con2.Alpha.AvgAmp;
        % Beta
        sprintTABLEOUT{i,"con1A_beta"} = sprintEpochTABLE.Amplitude(i,1).con1.Beta.AvgAmp;
        sprintTABLEOUT{i,"con2A_beta"} = sprintEpochTABLE.Amplitude(i,1).con2.Beta.AvgAmp;
        % Low Gamma
        sprintTABLEOUT{i,"con1A_lGamma"} = sprintEpochTABLE.Amplitude(i,1).con1.lGamma.AvgAmp;
        sprintTABLEOUT{i,"con2A_lGamma"} = sprintEpochTABLE.Amplitude(i,1).con2.lGamma.AvgAmp;
        % High Gamma
        sprintTABLEOUT{i,"con1A_hGamma"} = sprintEpochTABLE.Amplitude(i,1).con1.hGamma.AvgAmp;
        sprintTABLEOUT{i,"con2A_hGamma"} = sprintEpochTABLE.Amplitude(i,1).con2.hGamma.AvgAmp;

    % else ~isempty(sprintEpochTABLE.Freq(i,1).con1)

        % % Frequency %
        % % Delta
        % sprintTABLEOUT{i,"con1F_delta"} = NaN;
        % sprintTABLEOUT{i,"con2F_delta"} = NaN;
        % % Theta
        % sprintTABLEOUT{i,"con1F_theta"} = NaN;
        % sprintTABLEOUT{i,"con2F_theta"} = NaN;
        % % Alpha
        % sprintTABLEOUT{i,"con1F_alpha"} = NaN;
        % sprintTABLEOUT{i,"con2F_alpha"} = NaN;
        % % Beta
        % sprintTABLEOUT{i,"con1F_beta"} = NaN;
        % sprintTABLEOUT{i,"con2F_beta"} = NaN;
        % % Low Gamma
        % sprintTABLEOUT{i,"con1F_lGamma"} = NaN;
        % sprintTABLEOUT{i,"con2F_lGamma"} = NaN;
        % % High Gamma
        % sprintTABLEOUT{i,"con1F_hGamma"} = NaN;
        % sprintTABLEOUT{i,"con2F_hGamma"} = NaN;
        % 
        % % Amplitude %
        % % Delta
        % sprintTABLEOUT{i,"con1A_delta"} = NaN;
        % sprintTABLEOUT{i,"con2A_delta"} = NaN;
        % % Theta
        % sprintTABLEOUT{i,"con1A_theta"} = NaN;
        % sprintTABLEOUT{i,"con2A_theta"} = NaN;
        % % Alpha
        % sprintTABLEOUT{i,"con1A_alpha"} = NaN;
        % sprintTABLEOUT{i,"con2A_alpha"} = NaN;
        % % Beta
        % sprintTABLEOUT{i,"con1A_beta"} = NaN;
        % sprintTABLEOUT{i,"con2A_beta"} = NaN;
        % % Low Gamma
        % sprintTABLEOUT{i,"con1A_lGamma"} = NaN;
        % sprintTABLEOUT{i,"con2A_lGamma"} = NaN;
        % % High Gamma
        % sprintTABLEOUT{i,"con1A_hGamma"} = NaN;
        % sprintTABLEOUT{i,"con2A_hGamma"} = NaN;
    % end % if else

end % i / for



%%
for ii = 1:height(sprintEpochTABLE)

    % Delta
    numFreqTAB{ii, 'con1_delta'} = height(sprintEpochTABLE.Amplitude(ii,1).con1.Delta.allAmp);
    numFreqTAB{ii, 'con2_delta'} = height(sprintEpochTABLE.Amplitude(ii,1).con2.Delta.allAmp);
    % Theta
    numFreqTAB{ii, 'con1_theta'} = height(sprintEpochTABLE.Amplitude(ii,1).con1.Theta.allAmp);
    numFreqTAB{ii, 'con2_theta'} = height(sprintEpochTABLE.Amplitude(ii,1).con2.Theta.allAmp);
    % Alpha
    numFreqTAB{ii, 'con1_alpha'} = height(sprintEpochTABLE.Amplitude(ii,1).con1.Alpha.allAmp);
    numFreqTAB{ii, 'con2_alpha'} = height(sprintEpochTABLE.Amplitude(ii,1).con2.Alpha.allAmp);
    % Beta
    numFreqTAB{ii, 'con1_beta'} = height(sprintEpochTABLE.Amplitude(ii,1).con1.Beta.allAmp);
    numFreqTAB{ii, 'con2_beta'} = height(sprintEpochTABLE.Amplitude(ii,1).con2.Beta.allAmp);
    % Low Gamma
    numFreqTAB{ii, 'con1_lGamma'} = height(sprintEpochTABLE.Amplitude(ii,1).con1.lGamma.allAmp);
    numFreqTAB{ii, 'con2_lGamma'} = height(sprintEpochTABLE.Amplitude(ii,1).con2.lGamma.allAmp);
    % High Gamma
    numFreqTAB{ii, 'con1_hGamma'} = height(sprintEpochTABLE.Amplitude(ii,1).con1.hGamma.allAmp);
    numFreqTAB{ii, 'con2_hGamma'} = height(sprintEpochTABLE.Amplitude(ii,1).con2.hGamma.allAmp);


end % For / ii





