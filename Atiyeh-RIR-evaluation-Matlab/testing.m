function [sweep, inv_filter] = generate_sweep(f1, f2, T, fs)

% Parameters
% f1: start frequency (Hz)
% f2: end frequency (Hz)
% T: sweep duration (seconds)
% fs: sample rate (Hz)

t = 0:1/fs:T;
L = T / log(f2/f1);
K = 2*pi*f1*L;

% Generate sweep
sweep = sin(K*(exp(t/L) - 1));

% Generate inverse filter  
inv_filter = fliplr(sweep) .* exp(-t/L);

% Apply envelope to avoid transients
env = sin(pi*t/T);
sweep = sweep .* env;
inv_filter = inv_filter .* env;

% Add silence
silence = zeros(1, fs);
sweep = [silence, sweep, silence];
inv_filter = [silence, inv_filter, silence];

end

function rir = deconvolve_rir(recorded_sweep, inverse_filter)
    % Ensure both signals are row vectors
    recorded_sweep = recorded_sweep(:)';
    inverse_filter = inverse_filter(:)';
    
    % Perform linear convolution
    rir_raw = fftfilt(inverse_filter, recorded_sweep);
    
    % Find the peak of the RIR
    [~, peak_index] = max(abs(rir_raw));
    
    % Extract a portion of the RIR (e.g., 50 ms before and 2 seconds after the peak)
    fs = 48000; % Assuming 48kHz sample rate, adjust if different
    before_peak = round(0.05 * fs);  % 50 ms before peak
    after_peak = 2 * fs;  % 2 seconds after peak
    
    start_index = max(1, peak_index - before_peak);
    end_index = min(length(rir_raw), peak_index + after_peak);
    
    rir = rir_raw(start_index:end_index);
    
    % Apply a fade-out to the end to reduce any potential artifacts
    fade_length = min(round(0.1 * fs), length(rir));  % 100 ms fade or length of RIR, whichever is shorter
    fade_out = linspace(1, 0, fade_length).^2;
    rir(end-fade_length+1:end) = rir(end-fade_length+1:end) .* fade_out;
    
    % Normalize RIR
    rir = rir / max(abs(rir));
end

% Function to save WAV file with specific format
function saveWav(filename, signal, fs)
    % Ensure signal is in [-1, 1] range
    signal = signal / max(abs(signal));
    
    % Save as 16-bit WAV
    audiowrite(filename, signal, fs, 'BitsPerSample', 16);
    disp(['Saved: ' filename]);
end



% Generate sweep and inverse filter
fs = 48000;  % Sample rate
f1 = 20;     % Start frequency
f2 = 20000;  % End frequency
T = 15;      % Sweep duration

[sweep, inv_filter] = generate_sweep(f1, f2, T, fs);

% Save sweep and inverse filter
saveWav('sweep.wav', sweep, fs);
saveWav('inverse_filter.wav', inv_filter, fs);

% Use the generated sweep as the recorded sweep
recorded_sweep = sweep;

% Save recorded sweep
saveWav('recorded_sweep.wav', recorded_sweep, fs);

% Deconvolve to get the RIR
try
    rir = deconvolve_rir(recorded_sweep, inv_filter);
    
    % Save RIR
    saveWav('room_impulse_response.wav', rir, fs);

    % Plot the full RIR
    figure;
    t = (0:length(rir)-1) / fs;
    plot(t, rir);
    xlabel('Time (s)');
    ylabel('Amplitude');
    title('Room Impulse Response (should be a single impulse)');
    xlim([0, 0.1]);  % Zoom in to the first 100 ms

    % Plot the first 10 ms of the RIR
    figure;
    t_start = (0:min(round(0.01*fs), length(rir))-1) / fs;
    plot(t_start*1000, rir(1:length(t_start)));
    xlabel('Time (ms)');
    ylabel('Amplitude');
    title('First 10 ms of Room Impulse Response');

    disp('All files saved as 16-bit WAV at 48000 Hz');

    % Check if the peak is at the start and if it's a perfect impulse
    [max_val, max_idx] = max(abs(rir));
    if max_idx > 10
        warning('The peak of the RIR is not at the start. It occurs at %.2f ms.', max_idx/fs*1000);
    else
        disp('The peak of the RIR is at the start, as expected.');
    end
    
    % Check if it's close to a perfect impulse
    tolerance = 1e-6;
    if sum(abs(rir) > tolerance) == 1
        disp('The RIR is a perfect impulse, as expected.');
    else
        warning('The RIR is not a perfect impulse. There may be issues with the deconvolution process.');
    end

catch err
    disp('An error occurred during RIR deconvolution:');
    disp(err.message);
end



% test
[LS2_sweep, fs2] = audioread("room_impulse_response.wav");
[sweep, fsst] = audioread("sweep.wav");
[RT60, DRR, C50, Cfs, EDT] = ...
iosr.acoustics.irStats("room_impulse_response.wav",'graph', true, 'spec', 'full');

% Calculating Mean Values
mean_RT60 = mean(RT60(3:8));
mean_EDT = mean(EDT(3:8));

t2 = 0:1/fs2:((length(LS2_sweep)-1)/fs2);

figure; 
plot(t2,LS2_sweep(:,1).'); xlabel("time [s]"); ylabel("Amplitude"); title("RIR from sweep");

% Extract RT60 values for specific frequencies
freq_indices = find(ismember(Cfs, [500, 1000, 2000, 4000, 8000]));
RT60_values = RT60(freq_indices);
frequencies = Cfs(freq_indices);

% Create the graph
figure;
plot(1:5, RT60_values, '-o', 'LineWidth', 2, 'MarkerSize', 8, 'MarkerFaceColor', 'auto');
set(gca, 'XTick', 1:5, 'XTickLabel', {'0.5', '1', '2', '4', '8'});
xlabel('Frequency (kHz)');
ylabel('RT60 (s)');
title('KT - RT60 vs Frequency');
grid on;


% Add value labels on top of each point
for i = 1:length(RT60_values)
    text(i, RT60_values(i), sprintf('%.2f', RT60_values(i)), ...
         'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center');
end

% Display Mean Values
disp('Mean RT60:');
disp(mean_RT60);

disp('Mean EDT:');
disp(mean_EDT);

% Print RT60 and EDT for each octave band contributing to the mean
disp('RT60 and EDT for each contributing octave band:');
disp('Frequency (Hz) | RT60 (s) | EDT (s)');
disp('----------------------------------------');
for i = 3:8
    fprintf('%13d | %8.2f | %7.2f\n', Cfs(i), RT60(i), EDT(i));
end