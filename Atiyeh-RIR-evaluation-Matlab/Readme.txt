

% To evaluate the metrics using irStats function in IoSR Toolbox use the m file
Matlab files/IoSR Toolbox/+iosr/+acoustics/irStats.m
[RT, DRR, C50, Cfc, EDT] = iosr.acoustics.irStats('rir_record.wav','spec', 'full');
% Notice that RT & EDT outputs with 'spec' : 'mean' (defult) are the mean of the 500 Hz & 1 kHz bands.
% With 'spec': 'full', the function returns the RT & EDT as calculated for each octave band in Cfc

