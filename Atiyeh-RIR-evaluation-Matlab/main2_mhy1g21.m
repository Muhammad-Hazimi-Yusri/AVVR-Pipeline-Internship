% RIR extraction script with pure silence removal and robust alignment

clear all;
close all;

% Parameters
fs = 48000;  % Sample rate (Hz)
alignment_window = 0.2;  % Time window for alignment (in seconds)

try
    % Load the original sweep and inverse filter
    [sweep, fs_sweep] = audioread('sweep.wav');
    [inv_filter, fs_inv] = audioread('inverse_filter.wav');

    % Ensure the sample rates match
    assert(fs_sweep == fs && fs_inv == fs, 'Sample rates of sweep and inverse filter must match the specified fs');

    % Read the recorded sweep
    [recorded_sweep, fs_recorded] = audioread('Recorded/LR_matlab_sweep_synced_0.1vol_1to1.wav');

    % Convert recorded sweep to mono if it's stereo
    if size(recorded_sweep, 2) > 1
        recorded_sweep = mean(recorded_sweep, 2);
    end

    % Resample recorded sweep if necessary
    if fs_recorded ~= fs
        recorded_sweep = resample(recorded_sweep, fs, fs_recorded);
    end

    % Remove pure silence from both sweeps
    [sweep, sweep_start] = remove_pure_silence(sweep);
    [recorded_sweep, recorded_start] = remove_pure_silence(recorded_sweep);

    % Normalize both signals
    sweep = sweep / max(abs(sweep));
    recorded_sweep = recorded_sweep / max(abs(recorded_sweep));

    % Extract a portion of each signal for alignment
    alignment_samples = round(alignment_window * fs);
    sweep_portion = sweep(1:min(alignment_samples, length(sweep)));
    recorded_portion = recorded_sweep(1:min(alignment_samples, length(recorded_sweep)));

    % Perform cross-correlation on the extracted portions
    [acor, lag] = xcorr(recorded_portion, sweep_portion);
    [~, I] = max(abs(acor));
    lagDiff = lag(I);

    % Adjust recorded sweep based on lag
    if lagDiff > 0
        recorded_sweep = [zeros(lagDiff, 1); recorded_sweep(1:end-lagDiff)];
    else
        recorded_sweep = recorded_sweep(-lagDiff+1:end);
    end

    % Ensure both sweeps have the same length
    min_length = min(length(sweep), length(recorded_sweep));
    sweep = sweep(1:min_length);
    recorded_sweep = recorded_sweep(1:min_length);

    % Apply fade-in and fade-out
    fade_samples = round(0.01 * fs);  % 10 ms fade
    fade_in = linspace(0, 1, fade_samples)';
    fade_out = linspace(1, 0, fade_samples)';
    sweep(1:fade_samples) = sweep(1:fade_samples) .* fade_in;
    sweep(end-fade_samples+1:end) = sweep(end-fade_samples+1:end) .* fade_out;
    recorded_sweep(1:fade_samples) = recorded_sweep(1:fade_samples) .* fade_in;
    recorded_sweep(end-fade_samples+1:end) = recorded_sweep(end-fade_samples+1:end) .* fade_out;

    % Plot aligned sweeps for comparison
    figure;
    t = (0:length(sweep)-1) / fs;
    plot(t, sweep, 'b', 'DisplayName', 'Original Sweep');
    hold on;
    plot(t, recorded_sweep, 'r', 'DisplayName', 'Recorded Sweep');
    xlabel('Time (s)');
    ylabel('Amplitude');
    title('Original vs Recorded Sweep');
    legend('show');
    xlim([0 max(t)]);

    % Zoom in on the start of the sweeps
    figure;
    zoom_samples = 10000;  % Number of samples to show in zoomed plot
    t_zoom = (0:zoom_samples-1) / fs;
    plot(t_zoom, sweep(1:zoom_samples), 'b', 'DisplayName', 'Original Sweep');
    hold on;
    plot(t_zoom, recorded_sweep(1:zoom_samples), 'r', 'DisplayName', 'Recorded Sweep');
    xlabel('Time (s)');
    ylabel('Amplitude');
    title('Start of Sweeps (Zoomed)');
    legend('show');

    % Perform deconvolution in frequency domain
    RecordedSweep_fft = fft(recorded_sweep);
    InvFilter_fft = fft(inv_filter, length(recorded_sweep));
    RIR_fft = RecordedSweep_fft .* InvFilter_fft;
    rir = real(ifft(RIR_fft));

    % Apply a window to the RIR to reduce noise
    rir_length = round(0.5 * fs);  % 500 ms RIR
    window = hann(rir_length * 2)';
    window = window(1:rir_length);
    rir = rir(1:rir_length) .* window';

    % Normalize RIR
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

catch err
    % Display error message
    disp('An error occurred:');
    disp(err.message);
    % Display the line where the error occurred
    disp(['Error in line: ', num2str(err.stack(1).line)]);
end

% Function to remove pure silence keeping the last silent sample
function [signal_no_silence, start_index] = remove_pure_silence(signal)
    start_index = find(signal ~= 0, 1) - 1;
    if start_index < 1
        start_index = 1;
    end
    signal_no_silence = signal(start_index:end);
end