%% if the ephys behav table isn't made yet follow these scripts 

addpath('L:\GitKraken\BehavTable_Create');
addpath('L:\GitKraken\Aim1Start_GammaPower');

%%
% From JAT - creates the behavior table 
% addpath('L:\GitKraken\BehavTable_Create');
processLA_behav_v3(subjID , ttlStyle, ttlID, NWBdir, NWBname , behDIRsave) 
% Use processLA_behav_INFO.mat for the inputs 
% 
% subID = 'CLASE026';
% nwbDi = 'Y:\LossAversion\Patient folders\CLASE026\NWB-processing\2023-11-03_12-16-35\NWB_Data';
% nwbN = 'MW26_s2_Session_1_filter.nwb';
% behD = 'Y:\LossAversion\Patient folders\CLASE026\Behavioral-data\EventBehavior';
% ttlID = 'XXXXX';
% ttlS = 3; % instead of 1 put 3 
% processLA_behav_v3(subID , ttlS ,ttlID , nwbDi, nwbN , behD)

%% then use ephys2behavTable_v1 to modify the table from JAT 

% addpath('L:\GitKraken\Aim1Start_GammaPower')

% ephys2behavTable_v1(ptID, hemi, sBA, numCon, std_thresh)
ephys2behavTable_v1('CLASE022', 'R', 'AH', 1:2, 2)

%% Concatente all individual epochs per trial into one trial. 
% add things to path 
addpath('L:\GitKraken\BehavTable_Create')
addpath('L:\GitKraken\Power_FOOOF')

%%  Trial Tab
% This takes the ephys behavioral table and combines all epochs. Will be
% saved in TrialTABLE folder 
% addpath('L:\GitKraken\BehavTable_Create')
% sprintBehavTAB_v1(partID)
sprintBehavTAB_v1('CLASE019', 'R_AH')

%% Run SPRiNT on Table 

% getLFPPSD_Sprint(tmpSUB , Hemi , saveLOC)
getLFPPSD_Sprint_v3('CLASE026' , 'R_AMY' , 'Y:\LossAversion\Patient folders\CLASE026\NeuroPhys_Processed\SPRINT')

%% 
% sprint2Epochs_v1(partID, Hemi)
sprint2Epochs_v1('CLASE026', 'L_AH')

% partID = 'CLASE018';
% Hemi = 'L_AMY';

%% Make an csv file from the SPRiNT output 

% SPRiNT_epoch_tab(PtID, Hemi)
SPRiNT_epoch_tab('CLASE026', 'L_AH')

%% combine all csvs per participant 
% csvCombineSPRINT(PartID)
csvCombineSPRINT('CLASE026')