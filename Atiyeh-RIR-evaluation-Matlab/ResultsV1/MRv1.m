% MR
[LS2_sweep, fs2] = audioread("sounds/MR_GDP/RIR_MR_Unity_bf.wav");
[sweep, fsst] = audioread("sounds/MR_GDP/sine_sweep_16bit.wav");
[RT42_5, DRR, C50, Cfs, EDT] = ...
iosr.acoustics.irStats("sounds/MR_GDP/RIR_MR_Unity_bf.wav",'graph', true, 'spec', 'full', 'y_fit', [-5 -47.5]);

% Calculating Mean Values
mean_RT42_5 = mean(RT42_5(3:8));
mean_EDT = mean(EDT(3:8));

% Estimate RT60 from different RTs
mean_RT60 = mean_RT42_5 * 60/42.5;

t2 = 0:1/fs2:((length(LS2_sweep)-1)/fs2);

figure; 
plot(t2,LS2_sweep(:,1).'); xlabel("time [s]"); ylabel("Amplitude"); title("RIR from sweep");

% Extract RT60 values for specific frequencies
freq_indices = find(ismember(Cfs, [500, 1000, 2000, 4000, 8000]));
RT60_values = RT42_5(freq_indices) * 60/42.5;
frequencies = Cfs(freq_indices);

% Create the graph
figure;
plot(1:5, RT60_values, '-o', 'LineWidth', 2, 'MarkerSize', 8, 'MarkerFaceColor', 'auto');
set(gca, 'XTick', 1:5, 'XTickLabel', {'0.5', '1', '2', '4', '8'});
xlabel('Frequency (kHz)');
ylabel('RT60 (s)');
title('MR - RT60 vs Frequency');
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