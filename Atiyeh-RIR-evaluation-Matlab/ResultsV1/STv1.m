% ST
[LS2_sweep, fs2] = audioread("sounds/ST_GDP/RIR_ST_Unity_bf.wav");
[sweep, fsst] = audioread("sounds/ST_GDP/sine_sweep_16bit.wav");
[RT60, DRR, C50, Cfs, EDT] = ...
iosr.acoustics.irStats("sounds/ST_GDP/RIR_ST_Unity_bf.wav",'graph', true, 'spec', 'full', 'y_fit', [-5 -26]);

% Calculating Mean Values
mean_RT60 = mean(RT60(3:8));
mean_EDT = mean(EDT(3:8));

% Estimate RT60 from different RTs
%mean_RT60 = mean_RT20 * 60/20; % no need as this was already done in
%irStats.m, im dumdum.

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
title('ST - RT60 vs Frequency');
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