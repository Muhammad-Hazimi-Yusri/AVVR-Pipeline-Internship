[audio, fs] = audioread("sounds/ST_GDP/RIR_ST_Unity_bf.wav");
t = (0:length(audio)-1)/fs;
plot(t, audio);
xlabel('Time (s)');
ylabel('Amplitude');
title('Impulse Response');

ir_energy = cumsum(audio.^2);
ir_energy_db = 10*log10(ir_energy/max(ir_energy));
plot(t, ir_energy_db);
xlabel('Time (s)');
ylabel('Energy (dB)');
title('Energy Decay Curve');
ylim([-60 0]);

disp(['Length of IR: ' num2str(length(audio)/fs) ' seconds']);
disp(['Max amplitude: ' num2str(max(abs(audio)))]);

noise_floor = mean(audio(end-1000:end).^2);
signal_power = max(audio.^2);
snr = 10*log10(signal_power/noise_floor);
disp(['Estimated SNR: ' num2str(snr) ' dB']);

% Reverse the audio signal
audio_reversed = flipud(audio);

% Calculate energy decay curve for reversed signal
ir_energy_rev = cumsum(audio_reversed.^2);
ir_energy_db_rev = 10*log10(ir_energy_rev/max(ir_energy_rev));

% Plot the reversed signal's energy decay curve
figure;
plot(t, ir_energy_db_rev);
xlabel('Time (s)'); ylabel('Energy (dB)');
title('Energy Decay Curve (Reversed)');
ylim([-60 0]);

% Manual calculation of RT30 for reversed signal
idx_5db_rev = find(ir_energy_db_rev <= -5, 1);
idx_35db_rev = find(ir_energy_db_rev <= -35, 1);

if ~isempty(idx_5db_rev) && ~isempty(idx_35db_rev)
    rt30_manual_rev = 2 * (t(idx_35db_rev) - t(idx_5db_rev));
    disp(['Manual RT30 calculation (reversed): ', num2str(rt30_manual_rev), ' s']);
else
    disp('Could not calculate RT30 manually for reversed signal. Check if the decay reaches -35 dB.');
end

% Manual calculation of EDT for reversed signal
idx_10db_rev = find(ir_energy_db_rev <= -10, 1);
if ~isempty(idx_10db_rev)
    edt_manual_rev = 6 * (t(idx_10db_rev) - t(1));
    disp(['Manual EDT calculation (reversed): ', num2str(edt_manual_rev), ' s']);
else
    disp('Could not calculate EDT manually for reversed signal. Check if the decay reaches -10 dB.');
end