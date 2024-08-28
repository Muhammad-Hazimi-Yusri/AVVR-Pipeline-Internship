% RIR extraction and analysis script

clear all;
close all;

% Parameters
fs = 48000;  % Sample rate (Hz)

try
    % Load the original sweep and inverse filter
    [sweep, fs_sweep] = audioread('sweep.wav');
    [inv_filter, fs_inv] = audioread('inverse_filter.wav');

    % Ensure the sample rates match
    assert(fs_sweep == fs && fs_inv == fs, 'Sample rates of sweep and inverse filter must match the specified fs');

    % Read the recorded sweep
    [recorded_sweep, fs_recorded] = audioread('Recorded/LR_matlabsweep_-20db_attenuation_defaultbaked.wav');

    % Convert recorded sweep to mono if it's stereo
    if size(recorded_sweep, 2) > 1
        recorded_sweep = mean(recorded_sweep, 2);
    end

    % Resample recorded sweep if necessary
    if fs_recorded ~= fs
        recorded_sweep = resample(recorded_sweep, fs, fs_recorded);
    end

    % Print diagnostic information
    disp(['Length of original sweep: ', num2str(length(sweep))]);
    disp(['Length of recorded sweep: ', num2str(length(recorded_sweep))]);
    disp(['Length of inverse filter: ', num2str(length(inv_filter))]);

    % Perform deconvolution in frequency domain
    N = length(recorded_sweep);
    F_recorded = fft(recorded_sweep, N);
    F_inverse = fft(inv_filter, N);
    F_rir = F_recorded .* F_inverse;
    rir = real(ifft(F_rir));

    % Normalize RIR
    rir = rir / max(abs(rir));

    % Plot the full RIR
    figure;
    t_rir = (0:length(rir)-1) / fs;
    plot(t_rir, rir);
    xlabel('Time (s)');
    ylabel('Amplitude');
    title('Full Room Impulse Response');

    % Plot the RIR in dB scale
    figure;
    rir_db = 20 * log10(abs(rir) / max(abs(rir)));
    plot(t_rir, rir_db);
    xlabel('Time (s)');
    ylabel('Amplitude (dB)');
    title('Room Impulse Response (dB scale)');
    ylim([-60 0]);

    % Plot the frequency response
    figure;
    f = (0:N-1) * fs / N;
    F_rir_mag = abs(F_rir);
    semilogx(f, 20*log10(F_rir_mag / max(F_rir_mag)));
    xlabel('Frequency (Hz)');
    ylabel('Magnitude (dB)');
    title('Frequency Response of RIR');
    xlim([20 20000]);  % Focus on audible range
    grid on;

    % Plot the inverse filter
    figure;
    t_inv = (0:length(inv_filter)-1) / fs;
    plot(t_inv, inv_filter);
    xlabel('Time (s)');
    ylabel('Amplitude');
    title('Inverse Filter');

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