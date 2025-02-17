% do amp next 
% Load SPRiNT data
cd('X:\LossAversion\Patient folders\CLASE018\NeuroPhys_Processed\SPRINT');
load('CLASE018_L_AMY.mat'); % loads as allSprintOut

% Behavior data
cd('X:\LossAversion\Patient folders\CLASE018\Behavioral-data')
eventTab = load("clase_behavior_CLASE018_738812.7161.mat");

checkIndex = eventTab.subjdata.cs.ischecktrial;

% riskyloss < 0 = gain/loss trial :: eithclcer gain X or lose Y
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
gambleOUT_gain = double(gambleOUT_gain);

altLA = all(gainLOSS_trials & alternative_trials,2);
altOUT = all(altLA & outcomeNeutral, 2);
altOUT = double(altOUT);
altOUT(altOUT == 1) = 3;

gambleOUT_gain(gambleOUT_gain == 0) = altOUT(gambleOUT_gain == 0); % alternative is 3, gamble gain is 1, gamble loss is 0


% gambleOUT_loss = all(gamblesLA & outcomeLoss, 2);

% altTrial = rand(135, 1)<0.5;

lossPeaks = [];
gainPeaks = [];
altPeaks = [];

for i = 1:length(gambleOUT_gain)
    if gambleOUT_gain(i) == 1
        tempTrial = allSprintOut{1,i}{1,1}.channel.peaks;
        tempTrialTAB = struct2table(tempTrial);
        % tempFreq = tempTrialTAB.center_frequency;
        tempFreq = tempTrialTAB.amplitude;

        % deltaIDX = find(tempFreq >= 1 & tempFreq <= 4);
        % deltaAVG = mean(tempFreq(deltaIDX));
        % 
        % thetaIDX = find(tempFreq > 4.01 & tempFreq <= 8);
        % thetaAVG = mean(tempFreq(thetaIDX));
        % 
        % alphaIDX = find(tempFreq > 8.01 & tempFreq <= 12);
        % alphaAVG = mean(tempFreq(alphaIDX));
        % 
        % betaIDX = find(tempFreq > 12.01 & tempFreq <= 30);
        % betaAVG = mean(tempFreq(betaIDX));
        % 
        % LowGammaIDX = find(tempFreq >= 30.01 & tempFreq <= 50);
        % LowGammaAvg = mean(tempFreq(LowGammaIDX));
        % 
        % HighGammaIDX = find(tempFreq >= 50);
        % HighGammaAvg = mean(HighGammaIDX);

        % lossPeaks = [lossPeaks; deltaAVG; thetaAVG;alphaAVG;betaAVG;LowGammaAvg;HighGammaAvg];

        lossPeaks = [lossPeaks; tempFreq];

    else
        tempTrial = allSprintOut{1,i}{1,1}.channel.peaks;
        tempTrialTAB = struct2table(tempTrial);
        % tempFreq = tempTrialTAB.center_frequency;
        tempFreq = tempTrialTAB.amplitude;


        % deltaIDX = find(tempFreq >= 1 & tempFreq <= 4);
        % deltaAVG = mean(tempFreq(deltaIDX));
        % 
        % thetaIDX = find(tempFreq > 4.01 & tempFreq <= 8);
        % thetaAVG = mean(tempFreq(thetaIDX));
        % 
        % alphaIDX = find(tempFreq > 8.01 & tempFreq <= 12);
        % alphaAVG = mean(tempFreq(alphaIDX));
        % 
        % betaIDX = find(tempFreq > 12.01 & tempFreq <= 30);
        % betaAVG = mean(tempFreq(betaIDX));
        % 
        % LowGammaIDX = find(tempFreq >= 30.01 & tempFreq <= 50);
        % LowGammaAvg = mean(tempFreq(LowGammaIDX));
        % 
        % HighGammaIDX = find(tempFreq >= 50);
        % HighGammaAvg = mean(HighGammaIDX);

        % gainPeaks =  [gainPeaks; deltaAVG; thetaAVG;alphaAVG;betaAVG;LowGammaAvg;HighGammaAvg];
        gainPeaks = [gainPeaks; tempFreq];

    end % if else 

end % for / i 

normLAGain = normalize(gainPeaks,'range');
normLALoss =  normalize(lossPeaks,'range');

logLAGain = log(gainPeaks);
logLALoss = log(lossPeaks);

sw1 = swarmchart(zeros(length(logLALoss),1),logLALoss,20,"magenta", "filled")
sw1.XJitter = "rand";
sw1.XJitterWidth = 0.2;

hold on 

sw2 = swarmchart(ones(length(logLAGain),1),logLAGain,20,"blue", "filled")
sw2.XJitter = "rand";
sw2.XJitterWidth = 0.2;

namedian(lossPeaks)

[a,b,c] = kstest2(logLALoss, logLAGain);

ranksum(gainPeaks, lossPeaks);