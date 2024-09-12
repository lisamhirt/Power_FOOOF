% Load all data
% Load SPRiNT data
cd('Y:\LossAversion\Patient folders\CLASE018\NeuroPhys_Processed\SPRINT');
load('CLASE018_L_AMY.mat'); % loads as allSprintOut

% Behavior data
cd('Y:\LossAversion\Patient folders\CLASE018\Behavioral-data')
eventTab = load("clase_behavior_CLASE018_738812.7161.mat");

checkIndex = eventTab.subjdata.cs.ischecktrial;

% riskyloss < 0 = gain/loss trial :: either gain X or lose Y
% riskyloss == 0 = gain only :: either gain X or lose 0
% choice 1 = gamble, 0 = alternative

% Gain/loss trials - this measures loss aversion
gainLOSS_trials = eventTab.subjdata.cs.riskyLoss < 0 & ~checkIndex;
% Gain only trials - thsi measures risk aversion
gainONLY_trials = eventTab.subjdata.cs.riskyLoss == 0 & ~checkIndex;

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
altOUT(altOUT == 1) = 3;

gambleOUT_gain(gambleOUT_gain == 0) = altOUT(gambleOUT_gain == 0); % alternative is 3, gamble gain is 1, gamble loss is 0

allGambles = gambleOUT_gain; % copy variable

%% Builds on start code (v1). This section of code wants to break up trials by epoch again

% I want to pull out each trial by epoch now. So i need to create a table.
% the table should have trial number and epoch ID. then for each epoch ID i
% need to put the average amp, average power, per band. Then also maybe
% keep out the individual peaks too per band then average them too.

% lossPeaksFreq = [];
% gainPeaksFreq = [];
% altPeaksFreq = [];
%
% lossAmp = [];
% gainAmp = [];
% altAmp = [];

sprintEpochTABLE = table('Size', [540, 6], 'VariableTypes', {'double', 'char', 'char', 'double', 'struct', 'struct'}, 'VariableNames', ...
    {'BlockNum', 'TrialEvName', 'GambleType', 'Money', 'Freq', 'Amplitude'});

sprintEpochTABLE{:, "BlockNum"} = repelem(1:135, 4)';
sprintEpochTABLE{:, "TrialEvName"} = repmat({'Choice'; 'Reponse'; 'interTrial'; 'Outcome'}, 135,1);

fNames = {'Choice' 'Decision' 'ITI' 'Outcome'};

for i = 1:length(allGambles)

    tempRT = RTs(i); % temp reaction time per trial

    if allGambles(i) == 1 % gamble gain

        for ii = 1:height(allSprintOut{1,i})

            tempTrial = allSprintOut{1,i}{ii,1}.channel.peaks;
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

            tempConID = ['con' num2str(ii)];

            trialIDX = find(sprintEpochTABLE.BlockNum == i);
            sprintEpochTABLE{trialIDX,"GambleType"} = repmat({"Gain"}, length(trialIDX),1);
            sprintEpochTABLE{trialIDX,"Money"} = repmat(moneyTrial(i), length(trialIDX),1);

            for fi = 1:length(fNames)
                switch fNames{fi}
                    case 'Choice'

                        tempTIME = tempChoiceTime;
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


                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Delta.AvgF = deltaAvgF;
                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Delta.allF = tempFreq(tempDeltaE);
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Delta.AvgAmp = deltaAvgAmp;
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Delta.allAmp = tempAmp(tempDeltaE);

                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Theta.AvgF = thetaAvgF;
                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Theta.allF = tempFreq(tempThetaE);
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Theta.AvgAmp = thetaAvgAmp;
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Theta.allAmp = tempAmp(tempThetaE);

                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Alpha.AvgF = alphaAvgF;
                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Alpha.allF = tempFreq(tempAlphaE);
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Alpha.AvgAmp = alphaAvgAmp;
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Alpha.allAmp = tempAmp(tempAlphaE);

                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Beta.AvgF = betaAvgF;
                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Beta.allF = tempFreq(tempBetaE);
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Beta.AvgAmp = betaAvgAmp;
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Beta.allAmp = tempAmp(tempBetaE);

                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).lGamma.AvgF= lGammaAvgF;
                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).lGamma.allF = tempFreq(tempLGammaE);
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).lGamma.AvgAmp = lGammaAvgAmp;
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).lGamma.allAmp = tempAmp(tempLGammaE);

                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).hGamma.AvgF= hGammaAvgF;
                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).hGamma.allF = tempFreq(tempHGammaE);
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).hGamma.AvgAmp = hGammaAvgAmp;
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).hGamma.allAmp = tempAmp(tempHGammaE);

                    case 'Decision'
                        tempTIME = tempDecTime;
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


                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Delta.AvgF = deltaAvgF;
                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Delta.allF = tempFreq(tempDeltaE);
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Delta.AvgAmp = deltaAvgAmp;
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Delta.allAmp = tempAmp(tempDeltaE);

                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Theta.AvgF = thetaAvgF;
                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Theta.allF = tempFreq(tempThetaE);
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Theta.AvgAmp = thetaAvgAmp;
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Theta.allAmp = tempAmp(tempThetaE);

                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Alpha.AvgF = alphaAvgF;
                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Alpha.allF = tempFreq(tempAlphaE);
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Alpha.AvgAmp = alphaAvgAmp;
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Alpha.allAmp = tempAmp(tempAlphaE);

                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Beta.AvgF = betaAvgF;
                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Beta.allF = tempFreq(tempBetaE);
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Beta.AvgAmp = betaAvgAmp;
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Beta.allAmp = tempAmp(tempBetaE);

                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).lGamma.AvgF= lGammaAvgF;
                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).lGamma.allF = tempFreq(tempLGammaE);
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).lGamma.AvgAmp = lGammaAvgAmp;
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).lGamma.allAmp = tempAmp(tempLGammaE);

                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).hGamma.AvgF= hGammaAvgF;
                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).hGamma.allF = tempFreq(tempHGammaE);
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).hGamma.AvgAmp = hGammaAvgAmp;
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).hGamma.allAmp = tempAmp(tempHGammaE);

                    case 'ITI'
                        tempTIME = tempITItime;
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


                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Delta.AvgF = deltaAvgF;
                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Delta.allF = tempFreq(tempDeltaE);
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Delta.AvgAmp = deltaAvgAmp;
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Delta.allAmp = tempAmp(tempDeltaE);

                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Theta.AvgF = thetaAvgF;
                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Theta.allF = tempFreq(tempThetaE);
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Theta.AvgAmp = thetaAvgAmp;
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Theta.allAmp = tempAmp(tempThetaE);

                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Alpha.AvgF = alphaAvgF;
                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Alpha.allF = tempFreq(tempAlphaE);
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Alpha.AvgAmp = alphaAvgAmp;
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Alpha.allAmp = tempAmp(tempAlphaE);

                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Beta.AvgF = betaAvgF;
                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Beta.allF = tempFreq(tempBetaE);
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Beta.AvgAmp = betaAvgAmp;
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Beta.allAmp = tempAmp(tempBetaE);

                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).lGamma.AvgF= lGammaAvgF;
                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).lGamma.allF = tempFreq(tempLGammaE);
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).lGamma.AvgAmp = lGammaAvgAmp;
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).lGamma.allAmp = tempAmp(tempLGammaE);

                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).hGamma.AvgF= hGammaAvgF;
                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).hGamma.allF = tempFreq(tempHGammaE);
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).hGamma.AvgAmp = hGammaAvgAmp;
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).hGamma.allAmp = tempAmp(tempHGammaE);
                    case 'Outcome'
                        tempTIME = tempOutTime;
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


                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Delta.AvgF = deltaAvgF;
                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Delta.allF = tempFreq(tempDeltaE);
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Delta.AvgAmp = deltaAvgAmp;
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Delta.allAmp = tempAmp(tempDeltaE);

                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Theta.AvgF = thetaAvgF;
                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Theta.allF = tempFreq(tempThetaE);
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Theta.AvgAmp = thetaAvgAmp;
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Theta.allAmp = tempAmp(tempThetaE);

                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Alpha.AvgF = alphaAvgF;
                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Alpha.allF = tempFreq(tempAlphaE);
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Alpha.AvgAmp = alphaAvgAmp;
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Alpha.allAmp = tempAmp(tempAlphaE);

                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Beta.AvgF = betaAvgF;
                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Beta.allF = tempFreq(tempBetaE);
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Beta.AvgAmp = betaAvgAmp;
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Beta.allAmp = tempAmp(tempBetaE);

                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).lGamma.AvgF= lGammaAvgF;
                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).lGamma.allF = tempFreq(tempLGammaE);
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).lGamma.AvgAmp = lGammaAvgAmp;
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).lGamma.allAmp = tempAmp(tempLGammaE);

                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).hGamma.AvgF= hGammaAvgF;
                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).hGamma.allF = tempFreq(tempHGammaE);
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).hGamma.AvgAmp = hGammaAvgAmp;
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).hGamma.allAmp = tempAmp(tempHGammaE);

                end % switch

            end % for / fi
        end % for / ii


    elseif allGambles(i) == 0 % gamble loss

        for ii = 1:height(allSprintOut{1,i})

            tempTrial = allSprintOut{1,i}{1,1}.channel.peaks;
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

            tempConID = ['con' num2str(ii)];

            trialIDX = find(sprintEpochTABLE.BlockNum == i);
            sprintEpochTABLE{trialIDX,"GambleType"} = repmat({"Loss"}, length(trialIDX),1);
            sprintEpochTABLE{trialIDX,"Money"} = repmat(moneyTrial(i), length(trialIDX),1);

            for fi = 1:length(fNames)
                switch fNames{fi}
                    case 'Choice'

                        tempTIME = tempChoiceTime;
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


                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Delta.AvgF = deltaAvgF;
                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Delta.allF = tempFreq(tempDeltaE);
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Delta.AvgAmp = deltaAvgAmp;
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Delta.allAmp = tempAmp(tempDeltaE);

                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Theta.AvgF = thetaAvgF;
                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Theta.allF = tempFreq(tempThetaE);
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Theta.AvgAmp = thetaAvgAmp;
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Theta.allAmp = tempAmp(tempThetaE);

                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Alpha.AvgF = alphaAvgF;
                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Alpha.allF = tempFreq(tempAlphaE);
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Alpha.AvgAmp = alphaAvgAmp;
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Alpha.allAmp = tempAmp(tempAlphaE);

                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Beta.AvgF = betaAvgF;
                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Beta.allF = tempFreq(tempBetaE);
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Beta.AvgAmp = betaAvgAmp;
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Beta.allAmp = tempAmp(tempBetaE);

                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).lGamma.AvgF= lGammaAvgF;
                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).lGamma.allF = tempFreq(tempLGammaE);
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).lGamma.AvgAmp = lGammaAvgAmp;
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).lGamma.allAmp = tempAmp(tempLGammaE);

                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).hGamma.AvgF= hGammaAvgF;
                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).hGamma.allF = tempFreq(tempHGammaE);
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).hGamma.AvgAmp = hGammaAvgAmp;
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).hGamma.allAmp = tempAmp(tempHGammaE);


                    case 'Decision'
                        tempTIME = tempDecTime;
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

                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Delta.AvgF = deltaAvgF;
                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Delta.allF = tempFreq(tempDeltaE);
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Delta.AvgAmp = deltaAvgAmp;
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Delta.allAmp = tempAmp(tempDeltaE);

                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Theta.AvgF = thetaAvgF;
                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Theta.allF = tempFreq(tempThetaE);
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Theta.AvgAmp = thetaAvgAmp;
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Theta.allAmp = tempAmp(tempThetaE);

                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Alpha.AvgF = alphaAvgF;
                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Alpha.allF = tempFreq(tempAlphaE);
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Alpha.AvgAmp = alphaAvgAmp;
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Alpha.allAmp = tempAmp(tempAlphaE);

                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Beta.AvgF = betaAvgF;
                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Beta.allF = tempFreq(tempBetaE);
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Beta.AvgAmp = betaAvgAmp;
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Beta.allAmp = tempAmp(tempBetaE);

                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).lGamma.AvgF= lGammaAvgF;
                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).lGamma.allF = tempFreq(tempLGammaE);
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).lGamma.AvgAmp = lGammaAvgAmp;
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).lGamma.allAmp = tempAmp(tempLGammaE);

                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).hGamma.AvgF= hGammaAvgF;
                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).hGamma.allF = tempFreq(tempHGammaE);
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).hGamma.AvgAmp = hGammaAvgAmp;
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).hGamma.allAmp = tempAmp(tempHGammaE);

                    case 'ITI'
                        tempTIME = tempITItime;
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


                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Delta.AvgF = deltaAvgF;
                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Delta.allF = tempFreq(tempDeltaE);
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Delta.AvgAmp = deltaAvgAmp;
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Delta.allAmp = tempAmp(tempDeltaE);

                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Theta.AvgF = thetaAvgF;
                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Theta.allF = tempFreq(tempThetaE);
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Theta.AvgAmp = thetaAvgAmp;
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Theta.allAmp = tempAmp(tempThetaE);

                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Alpha.AvgF = alphaAvgF;
                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Alpha.allF = tempFreq(tempAlphaE);
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Alpha.AvgAmp = alphaAvgAmp;
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Alpha.allAmp = tempAmp(tempAlphaE);

                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Beta.AvgF = betaAvgF;
                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Beta.allF = tempFreq(tempBetaE);
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Beta.AvgAmp = betaAvgAmp;
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Beta.allAmp = tempAmp(tempBetaE);

                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).lGamma.AvgF= lGammaAvgF;
                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).lGamma.allF = tempFreq(tempLGammaE);
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).lGamma.AvgAmp = lGammaAvgAmp;
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).lGamma.allAmp = tempAmp(tempLGammaE);

                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).hGamma.AvgF= hGammaAvgF;
                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).hGamma.allF = tempFreq(tempHGammaE);
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).hGamma.AvgAmp = hGammaAvgAmp;
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).hGamma.allAmp = tempAmp(tempHGammaE);


                    case 'Outcome'
                        tempTIME = tempOutTime;
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


                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Delta.AvgF = deltaAvgF;
                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Delta.allF = tempFreq(tempDeltaE);
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Delta.AvgAmp = deltaAvgAmp;
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Delta.allAmp = tempAmp(tempDeltaE);

                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Theta.AvgF = thetaAvgF;
                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Theta.allF = tempFreq(tempThetaE);
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Theta.AvgAmp = thetaAvgAmp;
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Theta.allAmp = tempAmp(tempThetaE);

                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Alpha.AvgF = alphaAvgF;
                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Alpha.allF = tempFreq(tempAlphaE);
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Alpha.AvgAmp = alphaAvgAmp;
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Alpha.allAmp = tempAmp(tempAlphaE);

                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Beta.AvgF = betaAvgF;
                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Beta.allF = tempFreq(tempBetaE);
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Beta.AvgAmp = betaAvgAmp;
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Beta.allAmp = tempAmp(tempBetaE);

                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).lGamma.AvgF= lGammaAvgF;
                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).lGamma.allF = tempFreq(tempLGammaE);
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).lGamma.AvgAmp = lGammaAvgAmp;
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).lGamma.allAmp = tempAmp(tempLGammaE);

                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).hGamma.AvgF= hGammaAvgF;
                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).hGamma.allF = tempFreq(tempHGammaE);
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).hGamma.AvgAmp = hGammaAvgAmp;
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).hGamma.allAmp = tempAmp(tempHGammaE);


                end % switch

            end % for / fi

        end % for/ ii


    else allGambles(i) == 3; % alternative

        for ii = 1:height(allSprintOut{1,i})

            tempTrial = allSprintOut{1,i}{1,1}.channel.peaks;
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

            tempConID = ['con' num2str(ii)];

            trialIDX = find(sprintEpochTABLE.BlockNum == i);
            sprintEpochTABLE{trialIDX,"GambleType"} = repmat({"Alt"}, length(trialIDX),1);
            sprintEpochTABLE{trialIDX,"Money"} = repmat(moneyTrial(i), length(trialIDX),1);

            for fi = 1:length(fNames)
                switch fNames{fi}
                    case 'Choice'

                        tempTIME = tempChoiceTime;
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

                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Delta.AvgF = deltaAvgF;
                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Delta.allF = tempFreq(tempDeltaE);
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Delta.AvgAmp = deltaAvgAmp;
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Delta.allAmp = tempAmp(tempDeltaE);

                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Theta.AvgF = thetaAvgF;
                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Theta.allF = tempFreq(tempThetaE);
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Theta.AvgAmp = thetaAvgAmp;
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Theta.allAmp = tempAmp(tempThetaE);

                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Alpha.AvgF = alphaAvgF;
                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Alpha.allF = tempFreq(tempAlphaE);
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Alpha.AvgAmp = alphaAvgAmp;
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Alpha.allAmp = tempAmp(tempAlphaE);

                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Beta.AvgF = betaAvgF;
                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Beta.allF = tempFreq(tempBetaE);
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Beta.AvgAmp = betaAvgAmp;
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Beta.allAmp = tempAmp(tempBetaE);

                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).lGamma.AvgF= lGammaAvgF;
                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).lGamma.allF = tempFreq(tempLGammaE);
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).lGamma.AvgAmp = lGammaAvgAmp;
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).lGamma.allAmp = tempAmp(tempLGammaE);

                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).hGamma.AvgF= hGammaAvgF;
                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).hGamma.allF = tempFreq(tempHGammaE);
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).hGamma.AvgAmp = hGammaAvgAmp;
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).hGamma.allAmp = tempAmp(tempHGammaE);

                    case 'Decision'
                        tempTIME = tempDecTime;
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


                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Delta.AvgF = deltaAvgF;
                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Delta.allF = tempFreq(tempDeltaE);
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Delta.AvgAmp = deltaAvgAmp;
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Delta.allAmp = tempAmp(tempDeltaE);

                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Theta.AvgF = thetaAvgF;
                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Theta.allF = tempFreq(tempThetaE);
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Theta.AvgAmp = thetaAvgAmp;
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Theta.allAmp = tempAmp(tempThetaE);

                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Alpha.AvgF = alphaAvgF;
                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Alpha.allF = tempFreq(tempAlphaE);
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Alpha.AvgAmp = alphaAvgAmp;
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Alpha.allAmp = tempAmp(tempAlphaE);

                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Beta.AvgF = betaAvgF;
                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Beta.allF = tempFreq(tempBetaE);
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Beta.AvgAmp = betaAvgAmp;
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Beta.allAmp = tempAmp(tempBetaE);

                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).lGamma.AvgF= lGammaAvgF;
                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).lGamma.allF = tempFreq(tempLGammaE);
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).lGamma.AvgAmp = lGammaAvgAmp;
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).lGamma.allAmp = tempAmp(tempLGammaE);

                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).hGamma.AvgF= hGammaAvgF;
                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).hGamma.allF = tempFreq(tempHGammaE);
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).hGamma.AvgAmp = hGammaAvgAmp;
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).hGamma.allAmp = tempAmp(tempHGammaE);

                    case 'ITI'
                        tempTIME = tempITItime;
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

                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Delta.AvgF = deltaAvgF;
                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Delta.allF = tempFreq(tempDeltaE);
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Delta.AvgAmp = deltaAvgAmp;
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Delta.allAmp = tempAmp(tempDeltaE);

                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Theta.AvgF = thetaAvgF;
                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Theta.allF = tempFreq(tempThetaE);
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Theta.AvgAmp = thetaAvgAmp;
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Theta.allAmp = tempAmp(tempThetaE);

                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Alpha.AvgF = alphaAvgF;
                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Alpha.allF = tempFreq(tempAlphaE);
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Alpha.AvgAmp = alphaAvgAmp;
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Alpha.allAmp = tempAmp(tempAlphaE);

                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Beta.AvgF = betaAvgF;
                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Beta.allF = tempFreq(tempBetaE);
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Beta.AvgAmp = betaAvgAmp;
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Beta.allAmp = tempAmp(tempBetaE);

                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).lGamma.AvgF= lGammaAvgF;
                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).lGamma.allF = tempFreq(tempLGammaE);
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).lGamma.AvgAmp = lGammaAvgAmp;
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).lGamma.allAmp = tempAmp(tempLGammaE);

                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).hGamma.AvgF= hGammaAvgF;
                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).hGamma.allF = tempFreq(tempHGammaE);
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).hGamma.AvgAmp = hGammaAvgAmp;
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).hGamma.allAmp = tempAmp(tempHGammaE);

                    case 'Outcome'
                        tempTIME = tempOutTime;
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


                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Delta.AvgF = deltaAvgF;
                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Delta.allF = tempFreq(tempDeltaE);
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Delta.AvgAmp = deltaAvgAmp;
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Delta.allAmp = tempAmp(tempDeltaE);

                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Theta.AvgF = thetaAvgF;
                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Theta.allF = tempFreq(tempThetaE);
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Theta.AvgAmp = thetaAvgAmp;
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Theta.allAmp = tempAmp(tempThetaE);

                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Alpha.AvgF = alphaAvgF;
                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Alpha.allF = tempFreq(tempAlphaE);
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Alpha.AvgAmp = alphaAvgAmp;
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Alpha.allAmp = tempAmp(tempAlphaE);

                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Beta.AvgF = betaAvgF;
                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).Beta.allF = tempFreq(tempBetaE);
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Beta.AvgAmp = betaAvgAmp;
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).Beta.allAmp = tempAmp(tempBetaE);

                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).lGamma.AvgF= lGammaAvgF;
                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).lGamma.allF = tempFreq(tempLGammaE);
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).lGamma.AvgAmp = lGammaAvgAmp;
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).lGamma.allAmp = tempAmp(tempLGammaE);

                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).hGamma.AvgF= hGammaAvgF;
                        sprintEpochTABLE.Freq(trialIDX(fi),1).(tempConID).hGamma.allF = tempFreq(tempHGammaE);
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).hGamma.AvgAmp = hGammaAvgAmp;
                        sprintEpochTABLE.Amplitude(trialIDX(fi),1).(tempConID).hGamma.allAmp = tempAmp(tempHGammaE);


                end % switch

            end % for / fi

        end % for / ii

    end % if else

end % for / i


%% Start code (v1)
% This divides the all trials up by either gamble gain, gamble loss, or
% alternative. Then it looks at the average power and amplitude by
% frequency band (alpha, beta, etc.) per trial type.

% Load SPRiNT data
cd('Y:\LossAversion\Patient folders\CLASE018\NeuroPhys_Processed\SPRINT');
load('CLASE018_L_AMY.mat'); % loads as allSprintOut

% Behavior data
cd('Y:\LossAversion\Patient folders\CLASE018\Behavioral-data')
eventTab = load("clase_behavior_CLASE018_738812.7161.mat");

checkIndex = eventTab.subjdata.cs.ischecktrial;

% riskyloss < 0 = gain/loss trial :: either gain X or lose Y
% riskyloss == 0 = gain only :: either gain X or lose 0
% choice 1 = gamble, 0 = alternative

% Gain/loss trials - this measures loss aversion
gainLOSS_trials = eventTab.subjdata.cs.riskyLoss < 0 & ~checkIndex;
% Gain only trials - thsi measures risk aversion
gainONLY_trials = eventTab.subjdata.cs.riskyLoss == 0 & ~checkIndex;

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
% moneyTrial = eventTab.subjdata.cs.outcome;

% Reaction times
RTs = eventTab.subjdata.cs.RTs;


gamblesLA = all(gainLOSS_trials & gamble_trials, 2);
gambleOUT_gain = all(gamblesLA & outcomeGain, 2);
gambleOUT_gain = double(gambleOUT_gain);

altLA = all(gainLOSS_trials & alternative_trials,2);
altOUT = all(altLA & outcomeNeutral, 2);
altOUT = double(altOUT);
altOUT(altOUT == 1) = 3;

gambleOUT_gain(gambleOUT_gain == 0) = altOUT(gambleOUT_gain == 0); % alternative is 3, gamble gain is 1, gamble loss is 0

%%
gambleOUT_loss = all(gamblesLA & outcomeLoss, 2);

% altTrial = rand(135, 1)<0.5;

lossPeaksFreq = [];
gainPeaksFreq = [];
altPeaksFreq = [];

lossAmp = [];
gainAmp = [];
altAmp = [];

for i = 1:length(gambleOUT_gain)
    if gambleOUT_gain(i) == 1 % gamble gain
        tempTrial = allSprintOut{1,i}{1,1}.channel.peaks;
        tempTrialTAB = struct2table(tempTrial);
        tempFreq = tempTrialTAB.center_frequency;
        tempAmp = tempTrialTAB.amplitude;

        deltaIDX = find(tempFreq >= 1 & tempFreq <= 4);
        deltaAVG = mean(tempFreq(deltaIDX));
        deltaAMP = mean(tempAmp(deltaIDX));

        thetaIDX = find(tempFreq > 4.01 & tempFreq <= 8);
        thetaAVG = mean(tempFreq(thetaIDX));
        thetaAMP = mean(tempAmp(thetaIDX));

        alphaIDX = find(tempFreq > 8.01 & tempFreq <= 12);
        alphaAVG = mean(tempFreq(alphaIDX));
        alphaAMP = mean(tempAmp(alphaIDX));

        betaIDX = find(tempFreq > 12.01 & tempFreq <= 30);
        betaAVG = mean(tempFreq(betaIDX));
        betaAmp = mean(tempAmp(betaIDX));

        LowGammaIDX = find(tempFreq >= 30.01 & tempFreq <= 50);
        LowGammaAvg = mean(tempFreq(LowGammaIDX));
        LowGammaAMP = mean(tempAmp(LowGammaIDX));

        HighGammaIDX = find(tempFreq >= 50);
        HighGammaAvg = mean(tempFreq(HighGammaIDX));
        HighGammaAMP = mean(tempAmp(HighGammaIDX));

        lossPeaksFreq = [lossPeaksFreq; deltaAVG; thetaAVG;alphaAVG;betaAVG;LowGammaAvg;HighGammaAvg];
        lossAmp = [lossAmp; deltaAMP;thetaAMP;alphaAMP;betaAmp;LowGammaAMP;HighGammaAMP];

        % lossPeaksFreq = [lossPeaksFreq; tempAmp];

    elseif gambleOUT_gain(i) == 0 % gamble loss
        tempTrial = allSprintOut{1,i}{1,1}.channel.peaks;
        tempTrialTAB = struct2table(tempTrial);
        tempFreq = tempTrialTAB.center_frequency;
        tempAmp = tempTrialTAB.amplitude;

        deltaIDX = find(tempFreq >= 1 & tempFreq <= 4);
        deltaAVG = mean(tempFreq(deltaIDX));
        deltaAMP = mean(tempAmp(deltaIDX));

        thetaIDX = find(tempFreq > 4.01 & tempFreq <= 8);
        thetaAVG = mean(tempFreq(thetaIDX));
        thetaAMP = mean(tempAmp(thetaIDX));

        alphaIDX = find(tempFreq > 8.01 & tempFreq <= 12);
        alphaAVG = mean(tempFreq(alphaIDX));
        alphaAMP = mean(tempAmp(alphaIDX));

        betaIDX = find(tempFreq > 12.01 & tempFreq <= 30);
        betaAVG = mean(tempFreq(betaIDX));
        betaAmp = mean(tempAmp(betaIDX));

        LowGammaIDX = find(tempFreq >= 30.01 & tempFreq <= 50);
        LowGammaAvg = mean(tempFreq(LowGammaIDX));
        LowGammaAMP = mean(tempAmp(LowGammaIDX));

        HighGammaIDX = find(tempFreq >= 50);
        HighGammaAvg = mean(tempFreq(HighGammaIDX));
        HighGammaAMP = mean(tempAmp(HighGammaIDX));

        gainPeaksFreq =  [gainPeaksFreq; deltaAVG; thetaAVG;alphaAVG;betaAVG;LowGammaAvg;HighGammaAvg];
        gainAmp = [gainAmp; deltaAMP;thetaAMP;alphaAMP;betaAmp;LowGammaAMP;HighGammaAMP];
        % gainPeaksFreq = [gainPeaksFreq; tempAmp];

    else gambleOUT_gain(i) == 3; % alternative

        tempTrial = allSprintOut{1,i}{1,1}.channel.peaks;
        tempTrialTAB = struct2table(tempTrial);
        tempFreq = tempTrialTAB.center_frequency;
        tempAmp = tempTrialTAB.amplitude;

        deltaIDX = find(tempFreq >= 1 & tempFreq <= 4);
        deltaAVG = mean(tempFreq(deltaIDX));
        deltaAMP = mean(tempAmp(deltaIDX));

        thetaIDX = find(tempFreq > 4.01 & tempFreq <= 8);
        thetaAVG = mean(tempFreq(thetaIDX));
        thetaAMP = mean(tempAmp(thetaIDX));

        alphaIDX = find(tempFreq > 8.01 & tempFreq <= 12);
        alphaAVG = mean(tempFreq(alphaIDX));
        alphaAMP = mean(tempAmp(alphaIDX));

        betaIDX = find(tempFreq > 12.01 & tempFreq <= 30);
        betaAVG = mean(tempFreq(betaIDX));
        betaAmp = mean(tempAmp(betaIDX));

        LowGammaIDX = find(tempFreq >= 30.01 & tempFreq <= 50);
        LowGammaAvg = mean(tempFreq(LowGammaIDX));
        LowGammaAMP = mean(tempAmp(LowGammaIDX));

        HighGammaIDX = find(tempFreq >= 50);
        HighGammaAvg = mean(tempFreq(HighGammaIDX));
        HighGammaAMP = mean(tempAmp(HighGammaIDX));

        altPeaksFreq =  [altPeaksFreq; deltaAVG; thetaAVG;alphaAVG;betaAVG;LowGammaAvg;HighGammaAvg];
        altAmp = [altAmp; deltaAMP;thetaAMP;alphaAMP;betaAmp;LowGammaAMP;HighGammaAMP];

    end % if else

end % for / i
%%

normLAGainFreq = normalize(gainPeaksFreq,'range');
normLALossFreq =  normalize(lossPeaksFreq,'range');
normLAAltFreq = normalize(altPeaksFreq, 'range');

normLAGainAmp = normalize(gainAmp, 'range');
normLALossAmp = normalize(lossAmp, 'range');
normLAAltAmp = normalize(altAmp, 'range');

logLAGain = log(gainPeaksFreq);
logLALoss = log(lossPeaksFreq);
logLAAlt = log(altPeaksFreq);

% sw1 = swarmchart(zeros(length(logLALoss),1),logLALoss,20,"magenta", "filled")
sw1 = swarmchart(zeros(length(normLALossFreq),1),normLALossFreq,20,"magenta", "filled")
sw1.XJitter = "rand";
sw1.XJitterWidth = 0.2;

hold on

% sw2 = swarmchart(ones(length(logLAGain),1),logLAGain,20,"blue", "filled")
sw2 = swarmchart(ones(length(normLAGainAmp),1),normLAGainAmp,20,"blue", "filled")
sw2.XJitter = "rand";
sw2.XJitterWidth = 0.2;

hold on

% sw3 = swarmchart(2*ones(length(logLAAlt),1),logLAAlt, 20, 'green', 'filled')
sw3 = swarmchart(2*ones(length(normLAAltAmp),1),normLAAltAmp, 20, 'green', 'filled')
sw3.XJitter = 'rand';
sw3.XJitterWidth = 0.2;

namedian(lossPeaksFreq)

[a,b,c] = kstest2(normLAGainAmp, normLALossFreq);

[a2,b2,c2] = kstest2(normLALossFreq, altPeaksFreq);


ranksum(gainPeaksFreq, lossPeaksFreq);


%%
sprintEpochTABLE.Freq(i,1).(tempConID).Delta.AvgF = deltaAvgF;
sprintEpochTABLE.Freq(i,1).(tempConID).Delta.allF = tempFreq(tempDeltaE);
sprintEpochTABLE.Amplitude(i,1).(tempConID).Delta.AvgAmp = deltaAvgAmp;
sprintEpochTABLE.Amplitude(i,1).(tempConID).Delta.allAmp = tempAmp(tempDeltaE);

sprintEpochTABLE.Freq(i,1).(tempConID).Theta.AvgF = thetaAvgF;
sprintEpochTABLE.Freq(i,1).(tempConID).Theta.allF = tempFreq(tempThetaE);
sprintEpochTABLE.Amplitude(i,1).(tempConID).Theta.AvgAmp = thetaAvgAmp;
sprintEpochTABLE.Amplitude(i,1).(tempConID).Theta.allAmp = tempAmp(tempThetaE);

sprintEpochTABLE.Freq(i,1).(tempConID).Alpha.AvgF = alphaAvgF;
sprintEpochTABLE.Freq(i,1).(tempConID).Alpha.allF = tempFreq(tempAlphaE);
sprintEpochTABLE.Amplitude(i,1).(tempConID).Alpha.AvgAmp = alphaAvgAmp;
sprintEpochTABLE.Amplitude(i,1).(tempConID).Alpha.allAmp = tempAmp(tempAlphaE);

sprintEpochTABLE.Freq(i,1).(tempConID).Beta.AvgF = betaAvgF;
sprintEpochTABLE.Freq(i,1).(tempConID).Beta.allF = tempFreq(tempBetaE);
sprintEpochTABLE.Amplitude(i,1).(tempConID).Beta.AvgAmp = betaAvgAmp;
sprintEpochTABLE.Amplitude(i,1).(tempConID).Beta.allAmp = tempAmp(tempBetaE);

sprintEpochTABLE.Freq(i,1).(tempConID).lGamma.AvgF= lGammaAvgF;
sprintEpochTABLE.Freq(i,1).(tempConID).lGamma.allF = tempFreq(tempLGammaE);
sprintEpochTABLE.Amplitude(i,1).(tempConID).lGamma.AvgAmp = lGammaAvgAmp;
sprintEpochTABLE.Amplitude(i,1).(tempConID).lGamma.allAmp = tempAmp(tempLGammaE);

sprintEpochTABLE.Freq(i,1).(tempConID).hGamma.AvgF= hGammaAvgF;
sprintEpochTABLE.Freq(i,1).(tempConID).hGamma.allF = tempFreq(tempHGammaE);
sprintEpochTABLE.Amplitude(i,1).(tempConID).hGamma.AvgAmp = hGammaAvgAmp;
sprintEpochTABLE.Amplitude(i,1).(tempConID).hGamma.allAmp = tempAmp(tempHGammaE);