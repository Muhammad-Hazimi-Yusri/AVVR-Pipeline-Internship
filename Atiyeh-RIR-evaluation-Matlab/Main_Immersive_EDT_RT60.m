addpath 'RIRs' 'IoSR Toolbox' 'octave'

%% GDP rooms
% KT
%[LS2_sweep, fs2] = audioread("sounds/KT_GDP/RIR_KT_Unity_bf.wav");
%[sweep, fsst] = audioread("sounds/KT_GDP/sine_sweep_16bit.wav");
%[RT, DRR, C50, Cfs, EDT] = ...
%iosr.acoustics.irStats("sounds/KT_GDP/RIR_KT_Unity_bf.wav",'graph', true, 'spec', 'full');
% MR
%[LS2_sweep, fs2] = audioread("sounds/MR_GDP/RIR_MR_Unity_bf.wav");
%[sweep, fsst] = audioread("sounds/MR_GDP/sine_sweep_16bit.wav");
%[RT, DRR, C50, Cfs, EDT] = ...
%iosr.acoustics.irStats("sounds/MR_GDP/RIR_MR_Unity_bf.wav",'graph', true, 'spec', 'full');
% ST
[LS2_sweep, fs2] = audioread("sounds/ST_GDP/RIR_ST_Unity_bf.wav");
[sweep, fsst] = audioread("sounds/ST_GDP/sine_sweep_16bit.wav");
[RT, DRR, C50, Cfs, EDT] = ...
iosr.acoustics.irStats("sounds/ST_GDP/RIR_ST_Unity_bf.wav",'graph', true, 'spec', 'full');

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
mean_RT = mean(RT(3:8));
mean_EDT = mean(EDT(3:8));



t2 = 0:1/fs2:((length(LS2_sweep)-1)/fs2);

figure; 

plot(t2,LS2_sweep(:,1).'); xlabel("time [s]"); ylabel("Amplitude"); title("RIR from sweep");

% Display Mean Values
disp('Mean RT60:');
disp(mean_RT);

disp('Mean EDT:');
disp(mean_EDT);
%..........................................................................
%..........................................................................
