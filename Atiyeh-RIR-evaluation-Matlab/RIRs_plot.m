% Script files to plot the RIRs of the rooms in time domain

cd RIRs\

WavFiles =dir('*.wav');
N = length(WavFiles);

for i = 1:N
Filename = WavFiles(i).name;
[rir, fs] = audioread(Filename);
t = (1:length(rir))/fs;
% Let's check the RIR up to t=0.3 second (to zoom)
% zoom = 1*fs; 
zoom = 0.3*fs;
figure; plot(t(1:zoom),rir(1:zoom,1));
%figure;  plot(t,rir(:,1));
title(['RIR of ' Filename(1:end-12)])
xlabel('t [s]')
end

cd ..