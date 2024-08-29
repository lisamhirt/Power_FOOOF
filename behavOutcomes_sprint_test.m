% do amp next 
% Behavior data
cd('X:\LossAversion\Patient folders\CLASE018\Behavioral-data')
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

gamblesLA = all(gainLOSS_trials & gamble_trials, 2);
gambleOUT_gain = all(gamblesLA & outcomeGain, 2);
% gambleOUT_loss = all(gamblesLA & outcomeLoss, 2);

% altTrial = rand(135, 1)<0.5;

lossPeaks = [];
gainPeaks = [];

for i = 1:length(gambleOUT_gain)
    if gambleOUT_gain(i) == 1
        tempTrial = allSprintOut{1,i}{1,1}.channel.peaks;
        tempTrialTAB = struct2table(tempTrial);
        tempFreq = tempTrialTAB.center_frequency;

        deltaIDX = find(tempFreq >= 1 & tempFreq <= 4);
        deltaAVG = mean(tempFreq(deltaIDX));

        thetaIDX = find(tempFreq > 4.01 & tempFreq <= 8);
        thetaAVG = mean(tempFreq(thetaIDX));

        alphaIDX = find(tempFreq > 8.01 & tempFreq <= 12);
        alphaAVG = mean(tempFreq(alphaIDX));

        betaIDX = find(tempFreq > 12.01 & tempFreq <= 30);
        betaAVG = mean(tempFreq(betaIDX));

        LowGammaIDX = find(tempFreq >= 30.01 & tempFreq <= 50);
        LowGammaAvg = mean(tempFreq(LowGammaIDX));

        HighGammaIDX = find(tempFreq >= 50);
        HighGammaAvg = mean(HighGammaIDX);

        lossPeaks = [lossPeaks; deltaAVG; thetaAVG;alphaAVG;betaAVG;LowGammaAvg;HighGammaAvg];

        % lossPeaks = [lossPeaks; tempFreq];

    else
        tempTrial = allSprintOut{1,i}{1,1}.channel.peaks;
        tempTrialTAB = struct2table(tempTrial);
        tempFreq = tempTrialTAB.center_frequency;

          deltaIDX = find(tempFreq >= 1 & tempFreq <= 4);
        deltaAVG = mean(tempFreq(deltaIDX));

        thetaIDX = find(tempFreq > 4.01 & tempFreq <= 8);
        thetaAVG = mean(tempFreq(thetaIDX));

        alphaIDX = find(tempFreq > 8.01 & tempFreq <= 12);
        alphaAVG = mean(tempFreq(alphaIDX));

        betaIDX = find(tempFreq > 12.01 & tempFreq <= 30);
        betaAVG = mean(tempFreq(betaIDX));

        LowGammaIDX = find(tempFreq >= 30.01 & tempFreq <= 50);
        LowGammaAvg = mean(tempFreq(LowGammaIDX));

        HighGammaIDX = find(tempFreq >= 50);
        HighGammaAvg = mean(HighGammaIDX);

        gainPeaks =  [gainPeaks; deltaAVG; thetaAVG;alphaAVG;betaAVG;LowGammaAvg;HighGammaAvg];
        % gainPeaks = [gainPeaks; tempFreq];

    end % if else 

end % for / i 

sw1 = swarmchart(zeros(length(lossPeaks),1),lossPeaks,20,"magenta", "filled")
sw1.XJitter = "rand";
sw1.XJitterWidth = 0.2;

hold on 

sw2 = swarmchart(ones(length(gainPeaks),1),gainPeaks,20,"blue", "filled")
sw2.XJitter = "rand";
sw2.XJitterWidth = 0.2;

namedian(lossPeaks)

[a,b,c] = kstest2(lossPeaks, gainPeaks);

ranksum(gainPeaks, lossPeaks);