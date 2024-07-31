addpath 'RIRs' 'IoSR Toolbox' 'octave'

% Calculate RT30
[RT30, DRR30, C50_30, Cfs, EDT30] = ...
iosr.acoustics.irStats("sounds/ST_GDP/RIR_ST_Unity_bf.wav", 'graph', true, 'spec', 'full', 'y_fit', [-5 -35]);

% Calculate RT60
[RT60, DRR60, C50_60, ~, EDT60] = ...
iosr.acoustics.irStats("sounds/ST_GDP/RIR_ST_Unity_bf.wav", 'graph', true, 'spec', 'full', 'y_fit', [0 -60]);

% Estimate RT60 from RT30
RT60_est = RT30 * 2;

% Calculating Mean Values
mean_RT30 = mean(RT30(3:8));
mean_RT60 = mean(RT60(3:8));
mean_RT60_est = mean(RT60_est(3:8));
mean_EDT30 = mean(EDT30(3:8));
mean_EDT60 = mean(EDT60(3:8));

% Display Mean Values
disp('Mean RT30:');
disp(mean_RT30);

disp('Mean RT60 (directly calculated):');
disp(mean_RT60);

disp('Mean RT60 (estimated from RT30):');
disp(mean_RT60_est);

disp('Mean EDT (from RT30 calculation):');
disp(mean_EDT30);

disp('Mean EDT (from RT60 calculation):');
disp(mean_EDT60);

% Plot RT30, RT60, and estimated RT60
figure;
semilogx(Cfs, RT30, 'b-o', Cfs, RT60, 'r-s', Cfs, RT60_est, 'g-^');
xlabel('Frequency (Hz)');
ylabel('Reverberation Time (s)');
title('RT30, RT60, and Estimated RT60');
legend('RT30', 'RT60 (direct)', 'RT60 (estimated from RT30)');
grid on;

% Plot EDTs
figure;
semilogx(Cfs, EDT30, 'b-o', Cfs, EDT60, 'r-s');
xlabel('Frequency (Hz)');
ylabel('Early Decay Time (s)');
title('EDT from RT30 and RT60 calculations');
legend('EDT (RT30 calc)', 'EDT (RT60 calc)');
grid on;

[audio, fs] = audioread("sounds/ST_GDP/RIR_ST_Unity_bf.wav");
ir_energy = cumsum(audio.^2);
ir_energy_db = 10*log10(ir_energy/max(ir_energy));
t = (0:length(audio)-1)/fs;

% Find -5 dB and -35 dB points
idx_5db = find(ir_energy_db <= -5, 1);
idx_35db = find(ir_energy_db <= -35, 1);

if ~isempty(idx_5db) && ~isempty(idx_35db)
    rt30_manual = 2 * (t(idx_35db) - t(idx_5db));
    disp(['Manual RT30 calculation: ', num2str(rt30_manual), ' s']);
else
    disp('Could not calculate RT30 manually. Check if the decay reaches -35 dB.');
end



disp(['Length of audio: ' num2str(length(audio)) ' samples']);
disp(['Non-zero samples: ' num2str(sum(audio ~= 0))]);
disp(['First non-zero sample: ' num2str(find(audio ~= 0, 1))]);
disp(['Last non-zero sample: ' num2str(find(audio ~= 0, 1, 'last'))]);

figure;
plot(t, audio);
xlabel('Time (s)');
ylabel('Amplitude');
title('Raw Audio Signal');

figure;
spectrogram(audio, hann(1024), 512, 1024, fs, 'yaxis');
title('Spectrogram of the Impulse Response');