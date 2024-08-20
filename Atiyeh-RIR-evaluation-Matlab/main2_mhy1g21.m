% main2_simple.m
% Room Impulse Response extraction with improved silence removal, alignment, and comparison plots

clear all;
close all;

% Parameters
fs = 48000;  % Sample rate (Hz)
silence_threshold = 0.001;  % Adjust this value to fine-tune silence detection (lowered for less aggressive cutoff)

try
    % Load the original sweep and inverse filter
    [sweep, fs_sweep] = audioread('sweep.wav');
    [inv_filter, fs_inv] = audioread('inverse_filter.wav');

    % Ensure the sample rates match
    assert(fs_sweep == fs && fs_inv == fs, 'Sample rates of sweep and inverse filter must match the specified fs');

    % Read the recorded sweep
    [recorded_sweep, fs_recorded] = audioread('Recorded/matlab_sweep_openair.wav');

    % Convert recorded sweep to mono if it's stereo
    if size(recorded_sweep, 2) > 1
        recorded_sweep = mean(recorded_sweep, 2);
    end

    % Resample recorded sweep if necessary
    if fs_recorded ~= fs
        recorded_sweep = resample(recorded_sweep, fs, fs_recorded);
    end

    % Find the start of the signal in the recorded sweep
    energy = recorded_sweep.^2;
    cumulative_energy = cumsum(energy);
    normalized_energy = cumulative_energy / cumulative_energy(end);
    start_index = find(normalized_energy > silence_threshold, 1);

    % Align signals using cross-correlation
    [acor, lag] = xcorr(recorded_sweep(start_index:end), sweep);
    [~, I] = max(abs(acor));
    lagDiff = lag(I);

    % Adjust recorded sweep based on lag and ensure it matches the length of the original sweep
    if lagDiff > 0
        recorded_sweep_aligned = [zeros(lagDiff, 1); recorded_sweep(start_index:end)];
    else
        recorded_sweep_aligned = recorded_sweep(start_index-lagDiff:end);
    end

    % Trim or zero-pad the aligned recorded sweep to match the length of the original sweep
    if length(recorded_sweep_aligned) > length(sweep)
        recorded_sweep_aligned = recorded_sweep_aligned(1:length(sweep));
    else
        recorded_sweep_aligned = [recorded_sweep_aligned; zeros(length(sweep) - length(recorded_sweep_aligned), 1)];
    end

    % Normalize recorded sweep
    recorded_sweep_aligned = recorded_sweep_aligned / max(abs(recorded_sweep_aligned));

    % Plot aligned sweeps for comparison
    figure;
    t = (0:length(sweep)-1) / fs;
    plot(t, sweep, 'b', 'DisplayName', 'Original Sweep');
    hold on;
    plot(t, recorded_sweep_aligned, 'r', 'DisplayName', 'Recorded Sweep (Aligned)');
    xlabel('Time (s)');
    ylabel('Amplitude');
    title('Original vs Recorded Sweep (Aligned)');
    legend('show');
    xlim([0 max(t)]);

    % Perform deconvolution in frequency domain
    RecordedSweep_fft = fft(recorded_sweep_aligned);
    InvFilter_fft = fft(inv_filter);
    RIR_fft = RecordedSweep_fft .* InvFilter_fft;
    rir = real(ifft(RIR_fft));

    % Normalize RIR
    rir = rir / max(abs(rir));

    % Find the main peak and the second peak
    [~, main_peak_idx] = max(abs(rir));
    search_start = main_peak_idx + round(0.001 * fs);  % Start searching 1 ms after main peak
    search_end = min(length(rir), main_peak_idx + round(0.1 * fs));  % Search up to 100 ms after main peak
    [second_peak_val, second_peak_idx] = max(abs(rir(search_start:search_end)));
    second_peak_idx = second_peak_idx + search_start - 1;

    % Calculate the ratio of second peak to main peak
    peak_ratio = abs(rir(second_peak_idx)) / abs(rir(main_peak_idx));

    % If the second peak is significant, apply a window to suppress it
    if peak_ratio > 0.1  % Adjust this threshold as needed
        window = ones(size(rir));
        window_length = second_peak_idx - main_peak_idx;
        fade_window = hann(2 * window_length);
        fade_window = fade_window(window_length+1:end);
        window(second_peak_idx:min(length(rir), second_peak_idx+window_length-1)) = fade_window(1:min(window_length, length(rir)-second_peak_idx+1));
        rir = rir .* window;
    end

    % Re-normalize RIR after windowing
    rir = rir / max(abs(rir));

    % Plot the RIR
    figure;
    t_rir = (0:length(rir)-1) / fs;
    plot(t_rir, rir);
    xlabel('Time (s)');
    ylabel('Amplitude');
    title('Room Impulse Response');
    xlim([0 0.5]);  % Show first 500 ms

    % Plot the RIR in dB scale
    figure;
    rir_db = 20 * log10(abs(rir) / max(abs(rir)));
    plot(t_rir, rir_db);
    xlabel('Time (s)');
    ylabel('Amplitude (dB)');
    title('Room Impulse Response (dB scale)');
    xlim([0 0.5]);  % Show first 500 ms
    ylim([-60 5]);

    % Save RIR as .wav file
    audiowrite('room_impulse_response.wav', rir, fs);
    disp('Room Impulse Response saved as room_impulse_response.wav');

    % RT60 calculation
    rir_squared = rir .^ 2;
    energy_decay = cumsum(rir_squared(end:-1:1));
    energy_decay_db = 10 * log10(energy_decay / max(energy_decay));
    
    % Find -5 dB and -25 dB points
    idx_5db = find(energy_decay_db < -5, 1);
    idx_25db = find(energy_decay_db < -25, 1);
    
    if ~isempty(idx_5db) && ~isempty(idx_25db)
        rt60 = (idx_25db - idx_5db) / fs * (60 / 20);  % Scaling to full 60 dB decay
        disp(['Estimated RT60: ', num2str(rt60), ' seconds']);
    else
        disp('Unable to calculate RT60 - insufficient decay range');
    end

catch err
    % Display error message
    disp('An error occurred:');
    disp(err.message);
    % Display the line where the error occurred
    disp(['Error in line: ', num2str(err.stack(1).line)]);
end