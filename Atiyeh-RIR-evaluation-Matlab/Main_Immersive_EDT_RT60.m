clear all 
close all

addpath 'RIRs' 'IoSR Toolbox' 'octave'

%% GDP rooms
% KT
[LS2_sweep, fs2] = audioread("sounds/KT_GDP/RIR_KT_Unity_bf.wav");
[sweep, fsst] = audioread("sounds/KT_GDP/sine_sweep_16bit.wav");
[RT60, DRR, C50, Cfs, EDT] = ...
iosr.acoustics.irStats("sounds/KT_GDP/RIR_KT_Unity_bf.wav",'graph', true, 'spec', 'full', 'y_fit', [-5 -35]);
% LR
%[LS2_sweep, fs2] = audioread("sounds/LR_GDP/RIR_LR_Unity_bf.wav");
%[sweep, fsst] = audioread("sounds/LR_GDP/sine_sweep_16bit.wav");
%[RT60, DRR, C50, Cfs, EDT] = ...
%iosr.acoustics.irStats("sounds/LR_GDP/RIR_LR_Unity_bf.wav",'graph', true, 'spec', 'full', 'y_fit', [-5 -35]);
% MR
%[LS2_sweep, fs2] = audioread("sounds/MR_GDP/RIR_MR_Unity_bf.wav");
%[sweep, fsst] = audioread("sounds/MR_GDP/sine_sweep_16bit.wav");
%[RT60, DRR, C50, Cfs, EDT] = ...
%iosr.acoustics.irStats("sounds/MR_GDP/RIR_MR_Unity_bf.wav",'graph', true, 'spec', 'full', 'y_fit', [-5 -47.5]);
% ST
%[LS2_sweep, fs2] = audioread("sounds/ST_GDP/RIR_ST_Unity_bf.wav");
%[sweep, fsst] = audioread("sounds/ST_GDP/sine_sweep_16bit.wav");
%[RT60, DRR, C50, Cfs, EDT] = ... % -5 to -30 as RT25 was found to be sweet spot for ST, thus using RT25 for all, though tbh others works fine with RT30
%iosr.acoustics.irStats("sounds/ST_GDP/RIR_ST_Unity_bf.wav",'graph', true, 'spec', 'full', 'y_fit', [-5 -30]);
%
%% 

% Calculating Mean Values
mean_RT60 = mean(RT60(3:8));
mean_EDT = mean(EDT(3:8));

t2 = 0:1/fs2:((length(LS2_sweep)-1)/fs2);

figure; 

plot(t2,LS2_sweep(:,1).'); xlabel("time [s]"); ylabel("Amplitude"); title("RIR from sweep");

% Display Mean Values
%disp('Mean RT30:');
%disp(mean_RT30);

%disp('Estimated Mean RT60:');
disp('Mean RT60:');
disp(mean_RT60);

disp('Mean EDT:');
disp(mean_EDT);
%..........................................................................
%..........................................................................


% Print RT60 and EDT for each octave band contributing to the mean
disp('RT60 and EDT for each contributing octave band:');
disp('Frequency (Hz) | RT60 (s) | EDT (s)');
disp('----------------------------------------');
for i = 3:8
    fprintf('%13d | %8.2f | %7.2f\n', Cfs(i), RT60(i), EDT(i));
end