% Data for methods
methods = {'Kim19', 'Kim21', 'Proposed'};
scenes = {'MR', 'KT', 'LR', 'ST', 'UL'};
colors = {'k', 'y', 'r', 'g', 'b'};  % Colors for each scene
markers = {'o', '^', 's'};  % Markers for each method

% Estimated data points (you may need to adjust these for accuracy)
estimated = [
    0.58 0.84 0.15 1.60 0.64;  % Kim19
    0.55 0.43 0.16 1.00 0.56;  % Kim21 (previously labeled as Proposed)
    0.4045 0.3208 0.7821 1.4762 0.7595;  % New Proposed
];

recorded = [
    0.21 0.41 0.17 0.22 0.20;  % Kim19
    0.21 0.41 0.17 0.22 0.20;  % Kim21 (previously labeled as Proposed)
    0.21 0.41 0.17 0.22 0.20;  % New Proposed
];

% Create the plot
figure;
hold on;

% Plot data
for i = 1:3  % For each method
    for j = 1:5  % For each scene
        plot(estimated(i,j), recorded(i,j), [colors{j}, markers{i}], ...
             'MarkerSize', 10, 'LineWidth', 1.5, 'MarkerFaceColor', colors{j}, 'MarkerEdgeColor','black');
    end
end

% Plot JND lines
x = linspace(0, 3.6, 100);
jnd_line = plot(x, 1.05*x, 'k--', x, 0.95*x, 'k--', 'LineWidth', 1.5);

% Set axis limits and labels
xlim([0 3.6]);
ylim([0.12 0.48]);
xlabel('Estimated (s)');
ylabel('Recorded (s)');

% Create combined legend
legend_handles = [];
legend_labels = [];

% Method shapes
for i = 1:length(methods)
    h = plot(NaN,NaN,['k' markers{i}],'MarkerSize',10, 'MarkerFaceColor','none');
    legend_handles = [legend_handles, h];
    legend_labels = [legend_labels, methods(i)];
end

% JND line
jnd_handle = plot(NaN,NaN,'k--','LineWidth',1.5);
legend_handles = [legend_handles, jnd_handle];
legend_labels = [legend_labels, {'JND'}];

% Scene colors
for i = 1:length(scenes)
    h = plot(NaN,NaN,[colors{i}, 's'], 'MarkerSize',10, 'MarkerFaceColor',colors{i}, 'MarkerEdgeColor','black');
    legend_handles = [legend_handles, h];
    legend_labels = [legend_labels, scenes(i)];
end

% Create the combined legend
l = legend(legend_handles, legend_labels, 'Location', 'northwest', 'NumColumns', 1);

% Adjust plot properties
grid on;
box on;
set(gca, 'FontSize', 12);
title('EDTs for the five rooms');

% Make sure the legend is visible
set(l, 'AutoUpdate', 'off')

hold off;