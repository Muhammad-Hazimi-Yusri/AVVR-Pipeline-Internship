[RT60, DRR, C50, Cfs, EDT] = ...
iosr.acoustics.irStats("RIRs/Kitchen_BFormat.wav",'graph', true, 'spec', 'full')

% Calculating Mean Values
mean_RT60 = mean(RT60(3:8));
mean_EDT = mean(EDT(3:8));


disp('Mean RT60:');
disp(mean_RT60);

disp('Mean EDT:');
disp(mean_EDT);