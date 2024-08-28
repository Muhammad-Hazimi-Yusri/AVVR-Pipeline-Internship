% Data
rooms = {'MR', 'KT', 'LR', 'ST', 'UL'};
frequencies = [500, 1000, 2000, 4000, 8000];

% Ground truth (approximated from the image)
ground_truth = [
    0.6, 0.6, 0.6, 0.6, 0.6;  % MR
    0.6, 0.6, 0.6, 0.6, 0.6;  % KT
    0.15, 0.15, 0.15, 0.15, 0.15;  % LR
    1.9, 1.9, 1.9, 1.9, 1.9;  % ST
    0.9, 0.9, 0.9, 0.9, 0.9   % UL
];

% Kim19 data (approximated from the image)
kim19 = [
    0.9, 1.0, 0.9, 0.9, 0.9;  % MR
    1.8, 1.8, 1.9, 2.0, 2.0;  % KT
    0.15, 0.15, 0.15, 0.15, 0.15;  % LR
    2.0, 2.1, 2.1, 2.1, 2.1;  % ST
    1.1, 1.2, 1.2, 1.2, 1.2   % UL
];

% Kim21 data (labeled as "Proposed" in the original image, approximated)
kim21 = [
    0.75, 0.75, 0.75, 0.75, 0.75;  % MR
    0.7, 0.7, 0.7, 0.7, 0.7;  % KT
    0.2, 0.2, 0.2, 0.2, 0.2;  % LR
    1.9, 1.9, 1.9, 1.9, 1.9;  % ST
    0.9, 0.9, 0.9, 0.9, 0.9   % UL
];

% New proposed data
new_proposed = [
    0.19, 0.21, 0.20, 0.21, 0.21;  % MR
    0.18, 0.22, 0.22, 0.22, 0.23;  % KT
    0.50, 0.50, 0.49, 0.48, 0.45;  % LR
    0.72, 0.62, 0.64, 0.60, 0.62;  % ST
    0.44, 0.43, 0.43, 0.38, 0.47   % UL
];

% Create figure with subplots
figure('Position', [100, 100, 1200, 800]);

for i = 1:length(rooms)
    subplot(2, 3, i);
    hold on;
    
    % Plot ground truth
    plot(frequencies, ground_truth(i,:), 'k-', 'LineWidth', 2);
    
    % Plot JND lines
    plot(frequencies, ground_truth(i,:)*1.2, 'k--', 'LineWidth', 1);
    plot(frequencies, ground_truth(i,:)*0.8, 'k--', 'LineWidth', 1);
    
    % Plot data
    plot(frequencies, kim19(i,:), 'bo-', 'LineWidth', 1.5, 'MarkerSize', 6);
    plot(frequencies, kim21(i,:), 'ys-', 'LineWidth', 1.5, 'MarkerSize', 6);
    plot(frequencies, new_proposed(i,:), 'rd-', 'LineWidth', 1.5, 'MarkerSize', 6);
    
    % Customize plot
    title([rooms{i}]);
    xlabel('Frequency (kHz)');
    ylabel('RT60 (s)');
    xlim([400 9000]);
    set(gca, 'XScale', 'log');
    set(gca, 'XTick', frequencies);
    set(gca, 'XTickLabel', {'0.5', '1', '2', '4', '8'});
    grid on;
    
    % Adjust y-axis limits based on data
    y_min = min([ground_truth(i,:), kim19(i,:), kim21(i,:), new_proposed(i,:)]) * 0.8;
    y_max = max([ground_truth(i,:), kim19(i,:), kim21(i,:), new_proposed(i,:)]) * 1.2;
    ylim([y_min, y_max]);
    
    % Add legend only to the first subplot
    if i == 1
        legend('Ground Truth', 'JND', '', 'Kim19', 'Kim21', 'New Proposed', 'Location', 'best');
    end
    
    hold off;
end

% Add overall title
sgtitle('RT60s over different frequency bands for the five rooms');

% Adjust subplot spacing
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);