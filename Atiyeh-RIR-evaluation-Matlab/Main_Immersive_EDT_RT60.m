addpath 'RIRs' 'IoSR Toolbox' 'octave'

%% GDP rooms
% KT
%[LS2_sweep, fs2] = audioread("sounds/KT_GDP/RIR_KT_Unity_bf.wav");
%[sweep, fsst] = audioread("sounds/KT_GDP/sine_sweep_16bit.wav");
%[RT60, DRR, C50, Cfs, EDT] = ...
%iosr.acoustics.irStats("sounds/KT_GDP/RIR_KT_Unity_bf.wav",'graph', true, 'spec', 'full');
% LR
%[LS2_sweep, fs2] = audioread("sounds/LR_GDP/RIR_LR_Unity_bf.wav");
%[sweep, fsst] = audioread("sounds/LR_GDP/sine_sweep_16bit.wav");
%[RT30, DRR, C50, Cfs, EDT] = ...
%iosr.acoustics.irStats("sounds/LR_GDP/RIR_LR_Unity_bf.wav",'graph', true, 'spec', 'full', 'y_fit', [-5 -35]);
% MR
[LS2_sweep, fs2] = audioread("sounds/MR_GDP/RIR_MR_Unity_bf.wav");
[sweep, fsst] = audioread("sounds/MR_GDP/sine_sweep_16bit.wav");
[RT42_5, DRR, C50, Cfs, EDT] = ...
iosr.acoustics.irStats("sounds/MR_GDP/RIR_MR_Unity_bf.wav",'graph', true, 'spec', 'full', 'y_fit', [-5 -47.5]);
% ST
%[LS2_sweep, fs2] = audioread("sounds/ST_GDP/RIR_ST_Unity_bf.wav");
%[sweep, fsst] = audioread("sounds/ST_GDP/sine_sweep_16bit.wav");
%[RT25, DRR, C50, Cfs, EDT] = ... % -5 to -30 as RT25 was found to be sweet spot for ST, thus using RT25 for all, though tbh others works fine with RT30
%iosr.acoustics.irStats("sounds/ST_GDP/RIR_ST_Unity_bf.wav",'graph', true, 'spec', 'full', 'y_fit', [-5 -30]);
%
%% 

% MR room
%[LS2_sweep, fs2] = audioread("sounds/MR_MDBNet/RIR_MR_Unity_bf.wav");

% KT room
%[LS2_sweep, fs2] = audioread("sounds/KT_MDBNet/RIR_KT_Unity_bf.wav");
%[LS2_sweep, fs2] = audioread("sounds/KT_MDBNet/RIR_KT_gun_Unity_ch1_v2.wav");

% UL room
%[LS2_sweep, fs2] = audioread("sounds/UL_MDBNet/RIR_UL_Unity_bf.wav");

% ST room
%[LS2_sweep, fs2] = audioread("sounds/ST_MDBNet/RIR_ST_Unity_bf.wav");
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%[sweep, fsst] = audioread("sounds/MR_MDBNet/sine_sweep_16bit.wav");
%[sweep, fsst] = audioread("sounds/KT_MDBNet/Gunshot-Mono.wav");
%[sweep, fsst] = audioread("sounds/KT_MDBNet/sine_sweep_16bit.wav");
%[sweep, fsst] = audioread("sounds/UL_MDBNet/sine_sweep_16bit.wav");
%[sweep, fsst] = audioread("sounds/ST_MDBNet/sine_sweep_16bit.wav");
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% MR room
%[RT, DRR, C50, Cfs, EDT] = ...
%iosr.acoustics.irStats("sounds/MR_MDBNet/RIR_MR_Unity_bf.wav",'graph', true, 'spec', 'full');

% KT room
%[RT, DRR, C50, Cfs, EDT] = ...
%iosr.acoustics.irStats("sounds/KT_MDBNet/RIR_KT_Unity_bf.wav",'graph', true, 'spec', 'full');
%[RT, DRR, C50, Cfs, EDT] = ...
%iosr.acoustics.irStats("sounds/KT_MDBNet/RIR_KT_gun_Unity_ch1_v2.wav",'graph', true, 'spec', 'full');

% UL room
%[RT, DRR, C50, Cfs, EDT] = ...
%iosr.acoustics.irStats("sounds/UL_MDBNet/RIR_UL_Unity_bf.wav",'graph', true, 'spec', 'full');

% ST room
%[RT, DRR, C50, Cfs, EDT] = ...
%iosr.acoustics.irStats("sounds/ST_MDBNet/RIR_ST_Unity_bf.wav",'graph', true, 'spec', 'full');

% Calculating Mean Values
%mean_RT30 = mean(RT30(3:8));
mean_RT42_5 = mean(RT42_5(3:8));
%mean_RT60 = mean(RT60(3:8));
mean_EDT = mean(EDT(3:8));

% Estimate RT60 from different RTs
%mean_RT60 = mean_RT30 * 2;
mean_RT60 = mean_RT42_5 * 60/42.5;


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
