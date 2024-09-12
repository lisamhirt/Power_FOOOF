function [] = sprint2Epochs_v1(partID, Hemi)

% partID = 'CLASE018';
% Hemi = 'L_AMY';

% Load all data %
% Load SPRiNT data
folderLOC = ['Y:\LossAversion\Patient folders\' ,  partID, '\NeuroPhys_Processed\SPRINT\'];
cd(folderLOC)

matDirA = dir('*.mat');
matDirB = {matDirA.name};

tempFile = matDirB{contains(matDirB,Hemi)};

load(tempFile) % gets loaded as allSprintOut

% Behavior data
BehavLoc = ['Y:\LossAversion\Patient folders\', partID, '\Behavioral-data'];
cd(BehavLoc)

matDirBehav = dir('*.mat');
matDirBehav2 = string({matDirBehav.name});
eventTab = load(matDirBehav2);

% Pull out LA/RA trials. And win/loss/alt trials
checkIndex = eventTab.subjdata.cs.ischecktrial;

% riskyloss < 0 = gain/loss trial :: either gain X or lose Y
% riskyloss == 0 = gain only :: either gain X or lose 0
% choice 1 = gamble, 0 = alternative

% Gain/loss trials - this measures loss aversion
gainLOSS_trials = eventTab.subjdata.cs.riskyLoss < 0 & ~checkIndex;
% Gain only trials - thsi measures risk aversion
% gainONLY_trials = eventTab.subjdata.cs.riskyLoss == 0 & ~checkIndex;

% Gamble
gamble_trials = eventTab.subjdata.cs.choice == 1 & ~checkIndex;
% Alternative
alternative_trials = eventTab.subjdata.cs.choice == 0 & ~checkIndex;
% Outcome Loss
outcomeLoss = eventTab.subjdata.cs.outcome < 0 & ~checkIndex;
% Outcome no change
outcomeNeutral = eventTab.subjdata.cs.outcome == 0 & ~checkIndex;
% Outcome gain
outcomeGain = eventTab.subjdata.cs.outcome > 0 & ~checkIndex;

% Get the money values
moneyTrial = eventTab.subjdata.cs.outcome;

% Reaction times
RTs = eventTab.subjdata.cs.RTs;

% Get out loss aversion / gambles / alternative trials
gamblesLA = all(gainLOSS_trials & gamble_trials, 2);
gambleOUT_gain = all(gamblesLA & outcomeGain, 2);
gambleOUT_gain = double(gambleOUT_gain);

altLA = all(gainLOSS_trials & alternative_trials,2);
altOUT = all(altLA & outcomeNeutral, 2);
altOUT = double(altOUT);
altOUT(altOUT == 1) = 2;

gambleOUT_gain(gambleOUT_gain == 0) = altOUT(gambleOUT_gain == 0); % alternative is 2, gamble gain is 1, gamble loss is 0

allGambles = gambleOUT_gain; % copy variable

% Ephys and trials %

% Create table
sprintEpochTABLE = table('Size', [540, 6], 'VariableTypes', {'double', 'char', 'char', 'double', 'struct', 'struct'}, 'VariableNames', ...
    {'BlockNum', 'TrialEvName', 'GambleType', 'Money', 'Freq', 'Amplitude'});

sprintEpochTABLE{:, "BlockNum"} = repelem(1:135, 4)';
sprintEpochTABLE{:, "TrialEvName"} = repmat({'Choice'; 'Reponse'; 'interTrial'; 'Outcome'}, 135,1);

fNames = {'Choice' 'Decision' 'ITI' 'Outcome'};

for i = 1:length(allGambles)
    tempRT = RTs(i); % temp reaction time per trial

    if allGambles(i) == 1 % gamble gain

        tempTrial = allSprintOut{1,i}.channel.peaks;
        tempTrialTAB = struct2table(tempTrial);
        tempFreq = tempTrialTAB.center_frequency;
        tempAmp = tempTrialTAB.amplitude;

        tempChoiceTime = tempTrialTAB.time <= 2;
        tempDecTime = tempTrialTAB.time >= 2 & tempTrialTAB.time <= 2+tempRT;
        tempITItime = tempTrialTAB.time >= 2+tempRT & tempTrialTAB.time <= 2+tempRT+1;
        tempOutTime = tempTrialTAB.time >= 2+tempRT+1;

        deltaIDX = tempFreq >= 1 & tempFreq <= 4;
        thetaIDX = tempFreq > 4.01 & tempFreq <= 8;
        alphaIDX = tempFreq > 8.01 & tempFreq <= 12;
        betaIDX = tempFreq > 12.01 & tempFreq <= 30;
        LowGammaIDX = tempFreq >= 30.01 & tempFreq <= 50;
        HighGammaIDX = tempFreq >= 50;

        trialIDX = find(sprintEpochTABLE.BlockNum == i);
        sprintEpochTABLE{trialIDX,"GambleType"} = repmat({"Gain"}, length(trialIDX),1);
        sprintEpochTABLE{trialIDX,"Money"} = repmat(moneyTrial(i), length(trialIDX),1);

        for fi = 1:length(fNames)
            switch fNames{fi}
                case 'Choice'
                    [sprintEpochTABLE]   = powerPerEpoch(tempChoiceTime, sprintEpochTABLE, trialIDX, ...
                        fi, tempFreq, tempAmp,deltaIDX,thetaIDX, alphaIDX, betaIDX,LowGammaIDX, HighGammaIDX);
                case 'Decision'
                    [sprintEpochTABLE]   = powerPerEpoch(tempDecTime, sprintEpochTABLE, trialIDX, ...
                        fi, tempFreq, tempAmp,deltaIDX,thetaIDX, alphaIDX, betaIDX,LowGammaIDX, HighGammaIDX);
                case 'ITI'
                    [sprintEpochTABLE]   = powerPerEpoch(tempITItime, sprintEpochTABLE, trialIDX, ...
                        fi, tempFreq, tempAmp,deltaIDX,thetaIDX, alphaIDX, betaIDX,LowGammaIDX, HighGammaIDX);
                case 'Outcome'
                    [sprintEpochTABLE]   = powerPerEpoch(tempOutTime, sprintEpochTABLE, trialIDX, ...
                        fi, tempFreq, tempAmp,deltaIDX,thetaIDX, alphaIDX, betaIDX,LowGammaIDX, HighGammaIDX);
            end % switch
        end % for / fi

    elseif allGambles(i) == 0 % gamble loss

        tempTrial = allSprintOut{1,i}.channel.peaks;
        tempTrialTAB = struct2table(tempTrial);
        tempFreq = tempTrialTAB.center_frequency;
        tempAmp = tempTrialTAB.amplitude;

        tempChoiceTime = tempTrialTAB.time <= 2;
        tempDecTime = tempTrialTAB.time >= 2 & tempTrialTAB.time <= 2+tempRT;
        tempITItime = tempTrialTAB.time >= 2+tempRT & tempTrialTAB.time <= 2+tempRT+1;
        tempOutTime = tempTrialTAB.time >= 2+tempRT+1;

        deltaIDX = tempFreq >= 1 & tempFreq <= 4;
        thetaIDX = tempFreq > 4.01 & tempFreq <= 8;
        alphaIDX = tempFreq > 8.01 & tempFreq <= 12;
        betaIDX = tempFreq > 12.01 & tempFreq <= 30;
        LowGammaIDX = tempFreq >= 30.01 & tempFreq <= 50;
        HighGammaIDX = tempFreq >= 50;

        trialIDX = find(sprintEpochTABLE.BlockNum == i);
        sprintEpochTABLE{trialIDX,"GambleType"} = repmat({"Loss"}, length(trialIDX),1);
        sprintEpochTABLE{trialIDX,"Money"} = repmat(moneyTrial(i), length(trialIDX),1);

        for fi = 1:length(fNames)
            switch fNames{fi}
                case 'Choice'
                    [sprintEpochTABLE]   = powerPerEpoch(tempChoiceTime, sprintEpochTABLE, trialIDX, ...
                        fi, tempFreq, tempAmp,deltaIDX,thetaIDX, alphaIDX, betaIDX,LowGammaIDX, HighGammaIDX);
                case 'Decision'
                    [sprintEpochTABLE]   = powerPerEpoch(tempDecTime, sprintEpochTABLE, trialIDX, ...
                        fi, tempFreq, tempAmp,deltaIDX,thetaIDX, alphaIDX, betaIDX,LowGammaIDX, HighGammaIDX);
                case 'ITI'
                    [sprintEpochTABLE]   = powerPerEpoch(tempITItime, sprintEpochTABLE, trialIDX, ...
                        fi, tempFreq, tempAmp,deltaIDX,thetaIDX, alphaIDX, betaIDX,LowGammaIDX, HighGammaIDX);
                case 'Outcome'
                    [sprintEpochTABLE]   = powerPerEpoch(tempOutTime, sprintEpochTABLE, trialIDX, ...
                        fi, tempFreq, tempAmp,deltaIDX,thetaIDX, alphaIDX, betaIDX,LowGammaIDX, HighGammaIDX);
            end % switch
        end % for / fi

    else allGambles(i) == 2; % alternative

        tempTrial = allSprintOut{1,i}.channel.peaks;
        tempTrialTAB = struct2table(tempTrial);
        tempFreq = tempTrialTAB.center_frequency;
        tempAmp = tempTrialTAB.amplitude;

        tempChoiceTime = tempTrialTAB.time <= 2;
        tempDecTime = tempTrialTAB.time >= 2 & tempTrialTAB.time <= 2+tempRT;
        tempITItime = tempTrialTAB.time >= 2+tempRT & tempTrialTAB.time <= 2+tempRT+1;
        tempOutTime = tempTrialTAB.time >= 2+tempRT+1;

        deltaIDX = tempFreq >= 1 & tempFreq <= 4;
        thetaIDX = tempFreq > 4.01 & tempFreq <= 8;
        alphaIDX = tempFreq > 8.01 & tempFreq <= 12;
        betaIDX = tempFreq > 12.01 & tempFreq <= 30;
        LowGammaIDX = tempFreq >= 30.01 & tempFreq <= 50;
        HighGammaIDX = tempFreq >= 50;

        trialIDX = find(sprintEpochTABLE.BlockNum == i);
        sprintEpochTABLE{trialIDX,"GambleType"} = repmat({"Alt"}, length(trialIDX),1);
        sprintEpochTABLE{trialIDX,"Money"} = repmat(moneyTrial(i), length(trialIDX),1);

        for fi = 1:length(fNames)
            switch fNames{fi}
                case 'Choice'
                    [sprintEpochTABLE]   = powerPerEpoch(tempChoiceTime, sprintEpochTABLE, trialIDX, ...
                        fi, tempFreq, tempAmp,deltaIDX,thetaIDX, alphaIDX, betaIDX,LowGammaIDX, HighGammaIDX);
                case 'Decision'
                    [sprintEpochTABLE]   = powerPerEpoch(tempDecTime, sprintEpochTABLE, trialIDX, ...
                        fi, tempFreq, tempAmp,deltaIDX,thetaIDX, alphaIDX, betaIDX,LowGammaIDX, HighGammaIDX);
                case 'ITI'
                    [sprintEpochTABLE]   = powerPerEpoch(tempITItime, sprintEpochTABLE, trialIDX, ...
                        fi, tempFreq, tempAmp,deltaIDX,thetaIDX, alphaIDX, betaIDX,LowGammaIDX, HighGammaIDX);
                case 'Outcome'
                    [sprintEpochTABLE]   = powerPerEpoch(tempOutTime, sprintEpochTABLE, trialIDX, ...
                        fi, tempFreq, tempAmp,deltaIDX,thetaIDX, alphaIDX, betaIDX,LowGammaIDX, HighGammaIDX);
            end % switch
        end % for / fi
    end % if else / allGambles

end % For / i / all gambles

% Save 

saveLoc = ['Y:\LossAversion\Patient folders\',partID,'\NeuroPhys_Processed\SPRiNT_Epochs'];
cd(saveLoc)

saveName = [partID, '_', Hemi,'_', 'SPRiNT.mat'];

save(saveName, "sprintEpochTABLE")


end % function /sprint2epochs



function[sprintTAB] = powerPerEpoch(tempTIME, sprintTAB, trialIDX, fi, tempFreq, ...
    tempAmp, deltaIDX,thetaIDX, alphaIDX, betaIDX,LowGammaIDX, HighGammaIDX)

tempDeltaE = find(tempTIME & deltaIDX);
deltaAvgF = mean(tempFreq(tempDeltaE));
deltaAvgAmp = mean(tempAmp(tempDeltaE));

tempThetaE = find(tempTIME & thetaIDX);
thetaAvgF = mean(tempFreq(tempThetaE));
thetaAvgAmp = mean(tempAmp(tempThetaE));

tempAlphaE = find(tempTIME & alphaIDX);
alphaAvgF = mean(tempFreq(tempAlphaE));
alphaAvgAmp = mean(tempAmp(tempAlphaE));

tempBetaE = find(tempTIME & betaIDX);
betaAvgF = mean(tempFreq(tempBetaE));
betaAvgAmp = mean(tempAmp(tempBetaE));

tempLGammaE = find(tempTIME & LowGammaIDX);
lGammaAvgF = mean(tempFreq(tempLGammaE));
lGammaAvgAmp = mean(tempAmp(tempLGammaE));

tempHGammaE = find(tempTIME & HighGammaIDX);
hGammaAvgF = mean(tempFreq(tempHGammaE));
hGammaAvgAmp = mean(tempAmp(tempHGammaE));

sprintTAB.Freq(trialIDX(fi),1).Delta.AvgF = deltaAvgF;
sprintTAB.Freq(trialIDX(fi),1).Delta.allF = tempFreq(tempDeltaE);
sprintTAB.Amplitude(trialIDX(fi),1).Delta.AvgAmp = deltaAvgAmp;
sprintTAB.Amplitude(trialIDX(fi),1).Delta.allAmp = tempAmp(tempDeltaE);

sprintTAB.Freq(trialIDX(fi),1).Theta.AvgF = thetaAvgF;
sprintTAB.Freq(trialIDX(fi),1).Theta.allF = tempFreq(tempThetaE);
sprintTAB.Amplitude(trialIDX(fi),1).Theta.AvgAmp = thetaAvgAmp;
sprintTAB.Amplitude(trialIDX(fi),1).Theta.allAmp = tempAmp(tempThetaE);

sprintTAB.Freq(trialIDX(fi),1).Alpha.AvgF = alphaAvgF;
sprintTAB.Freq(trialIDX(fi),1).Alpha.allF = tempFreq(tempAlphaE);
sprintTAB.Amplitude(trialIDX(fi),1).Alpha.AvgAmp = alphaAvgAmp;
sprintTAB.Amplitude(trialIDX(fi),1).Alpha.allAmp = tempAmp(tempAlphaE);

sprintTAB.Freq(trialIDX(fi),1).Beta.AvgF = betaAvgF;
sprintTAB.Freq(trialIDX(fi),1).Beta.allF = tempFreq(tempBetaE);
sprintTAB.Amplitude(trialIDX(fi),1).Beta.AvgAmp = betaAvgAmp;
sprintTAB.Amplitude(trialIDX(fi),1).Beta.allAmp = tempAmp(tempBetaE);

sprintTAB.Freq(trialIDX(fi),1).lGamma.AvgF= lGammaAvgF;
sprintTAB.Freq(trialIDX(fi),1).lGamma.allF = tempFreq(tempLGammaE);
sprintTAB.Amplitude(trialIDX(fi),1).lGamma.AvgAmp = lGammaAvgAmp;
sprintTAB.Amplitude(trialIDX(fi),1).lGamma.allAmp = tempAmp(tempLGammaE);

sprintTAB.Freq(trialIDX(fi),1).hGamma.AvgF= hGammaAvgF;
sprintTAB.Freq(trialIDX(fi),1).hGamma.allF = tempFreq(tempHGammaE);
sprintTAB.Amplitude(trialIDX(fi),1).hGamma.AvgAmp = hGammaAvgAmp;
sprintTAB.Amplitude(trialIDX(fi),1).hGamma.allAmp = tempAmp(tempHGammaE);


end % function / powerPerEpoch