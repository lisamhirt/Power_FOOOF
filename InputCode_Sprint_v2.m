%

% getLFPPSD_Sprint(tmpSUB , Hemi , saveLOC)

getLFPPSD_Sprint_v2('CLASE018' , 'L_AMY' , 'Y:\LossAversion\Patient folders\CLASE018\NeuroPhys_Processed\SPRINT')


%% 

% for my decision screen it is less than 1 second so I will have to loop 
% through the vector of that epoch. 

% Take sampling rate (500) and divide that by the number of samples in the
% vector (eg: 222). 

% The entire length of trial 1 for CLASE018 is 2585 samples long. Divide
% this by 500 to get the time of trial in seconds 
% 2585/ 500 = 5.17 seconds long
