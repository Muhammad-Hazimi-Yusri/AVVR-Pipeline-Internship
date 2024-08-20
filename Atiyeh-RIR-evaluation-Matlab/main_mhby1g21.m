% Parameters
fs = 48000;  % Sample rate
T = 30;      % Duration in seconds
t = 0:1/fs:T-1/fs;

% Generate a simple linear chirp
f0 = 20;     % Start frequency
f1 = 20000;  % End frequency
sweep = chirp(t, f0, T, f1, 'linear');

% Generate inverse filter (time-reversed sweep with amplitude modulation)
inv_filter = flip(sweep) .* linspace(1, 0.1, length(sweep));

% Normalize both signals
sweep = sweep / max(abs(sweep));
inv_filter = inv_filter / max(abs(inv_filter));

% Convolve sweep with inverse filter (this should give us a delta function)
rir = conv(sweep, inv_filter, 'same');

% Normalize RIR
rir = rir / max(abs(rir));

% Plot the sweep and inverse filter
figure;
subplot(2,1,1);
plot(t, sweep);
xlabel('Time (s)');
ylabel('Amplitude');
title('Sweep Signal');
xlim([0 T]);

subplot(2,1,2);
plot(t, inv_filter);
xlabel('Time (s)');
ylabel('Amplitude');
title('Inverse Filter');
xlim([0 T]);

% Plot the RIR
figure;
t_rir = (-length(rir)/2:length(rir)/2-1) / fs * 1000;  % Time in milliseconds
plot(t_rir, rir);
xlabel('Time (ms)');
ylabel('Amplitude');
title('Room Impulse Response (should be a single impulse)');
xlim([-10 10]);  % Zoom in to ±10 ms around the center

% Calculate frequency responses
f = linspace(0, fs/2, length(rir)/2);
Y_sweep = abs(fft(sweep));
Y_sweep = Y_sweep(1:length(Y_sweep)/2);
Y_inv = abs(fft(inv_filter));
Y_inv = Y_inv(1:length(Y_inv)/2);
Y_rir = abs(fft(rir));
Y_rir = Y_rir(1:length(Y_rir)/2);

% Plot the frequency responses
figure;
semilogx(f, 20*log10(Y_sweep/max(Y_sweep)), 'b', 'LineWidth', 1.5);
hold on;
semilogx(f, 20*log10(Y_inv/max(Y_inv)), 'r', 'LineWidth', 1.5);
semilogx(f, 20*log10(Y_rir/max(Y_rir)), 'g', 'LineWidth', 1.5);
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
title('Frequency Responses');
xlim([20 20000]);
ylim([-60 5]);
legend('Sweep', 'Inverse Filter', 'RIR');
grid on;

% Check if it's close to a perfect impulse
[max_val, max_idx] = max(abs(rir));
tolerance = 1e-3;
if sum(abs(rir) > tolerance) < 10 && abs(max_idx - length(rir)/2) < 10
    disp('The RIR is very close to a perfect impulse, as expected.');
else
    warning('The RIR is not a perfect impulse. There may be issues with the deconvolution process.');
    disp(['Number of samples above tolerance: ' num2str(sum(abs(rir) > tolerance))]);
    disp(['Distance of peak from center: ' num2str(abs(max_idx - length(rir)/2))]);
end