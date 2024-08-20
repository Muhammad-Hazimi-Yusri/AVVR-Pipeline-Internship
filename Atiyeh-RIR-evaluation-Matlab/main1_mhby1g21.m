% Parameters
fs = 48000;  % Sample rate
T = 10;      % Duration in seconds
t = (0:1/fs:T-1/fs)';

% Generate an exponential sine sweep
function sweep = exp_sine_sweep(f0, f1, T, fs)
    t = (0:1/fs:T-1/fs)';
    w1 = 2*pi*f0;
    w2 = 2*pi*f1;
    K = T*w1/log(w2/w1);
    L = T/log(w2/w1);
    sweep = sin(K*(exp(t/L) - 1));
end

f0 = 20;     % Start frequency
f1 = 20000;  % End frequency
sweep = exp_sine_sweep(f0, f1, T, fs);

% Apply fade-in and fade-out
fade_length = round(0.1 * fs);  % 100 ms fade
fade = linspace(0, 1, fade_length)';
sweep(1:fade_length) = sweep(1:fade_length) .* fade;
sweep(end-fade_length+1:end) = sweep(end-fade_length+1:end) .* flip(fade);

% Generate inverse filter
inv_filter = flip(sweep) .* exp(-t/T);

% Apply window function to inverse filter
window = hann(length(inv_filter));
inv_filter = inv_filter .* window;

% Ensure double precision
sweep = double(sweep);
inv_filter = double(inv_filter);

% Normalize both signals
sweep = sweep / max(abs(sweep));
inv_filter = inv_filter / max(abs(inv_filter));

% Save sweep as .wav file
audiowrite('sweep.wav', sweep, fs);
disp('Sweep saved as sweep.wav');
audiowrite('inverse_filter.wav', inv_filter, fs);
disp('Inverse filter saved as inverse_filter.wav');

% Use the original sweep as the recorded sweep for perfect impulse demonstration
recorded_sweep = sweep;

% Convolve recorded sweep with inverse filter to get the RIR
rir = conv(recorded_sweep, inv_filter, 'same');

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
title('Room Impulse Response');
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

% Function to calculate RT60 with noise floor cutoff
function rt60 = calculate_rt60(ir, fs, noise_floor_db)
    ir_db = 20 * log10(abs(ir) / max(abs(ir)));
    [~, peak_index] = max(abs(ir));
    ir_db = ir_db(peak_index:end);
    
    % Find the point where the decay reaches noise floor
    decay_end = find(ir_db < noise_floor_db, 1);
    if isempty(decay_end)
        decay_end = length(ir_db);
    end
    
    % Linear fit to the decay curve
    t = (0:decay_end-1)' / fs;
    p = polyfit(t, ir_db(1:decay_end), 1);
    
    % Calculate RT60
    rt60 = -60 / p(1);
end

% Calculate and display RT60
rt60 = calculate_rt60(rir, fs, -40);  % Use -40 dB as noise floor
disp(['Calculated RT60: ', num2str(rt60), ' seconds']);

% Save RIR as .wav file
audiowrite('perfect_room_impulse_response.wav', rir, fs);
disp('Perfect room Impulse Response saved as perfect_room_impulse_response.wav');