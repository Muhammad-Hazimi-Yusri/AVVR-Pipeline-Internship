[audio, fs] = audioread("sounds/KT_GDP/RIR_KT_Unity_bf.wav");
disp(['Sampling rate: ' num2str(fs) ' Hz']);

[audio, fs] = audioread("RIR_Mona_Test.wav");
disp(['Sampling rate: ' num2str(fs) ' Hz']);

[audio, fs] = audioread("sounds/KT_GDP/RIR_48kHz.wav");
disp(['Sampling rate: ' num2str(fs) ' Hz']);