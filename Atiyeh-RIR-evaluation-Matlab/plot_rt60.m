% Data
methods = {'Kim19', 'Kim21', 'Proposed'};
scenes = {'MR', 'KT', 'LR', 'ST', 'UL'};

% Estimated values
estimated = [
    0.80, 1.75, 0.10, 2.1, 1.05;  % Kim19
    0.65, 0.6, 0.17, 1.8, 0.76;  % Kim21 (previously Proposed)
    0.2061, 0.2084, 0.4773, 0.6477, 0.4098  % New Proposed
];

% Recorded values
recorded = [
    0.55, 0.47, 0.15, 1.85, 0.42;  % Kim19
    0.55, 0.47, 0.15, 1.85, 0.42;  % Kim21 (previously Proposed)
    0.55, 0.47, 0.15, 1.85, 0.42;  % New Proposed
];

% Create the plot
figure;
hold on;

% Colors and markers
colors = {'k', 'y', 'r', 'g', 'b'};  % Black, Yellow, Red, Green, Blue
markers = {'o', '^', 's'};  % Circle, Square, Diamond

for i = 1:length(methods)
    for j = 1:length(scenes)
        plot(estimated(i,j), recorded(i,j), [colors{j}, markers{i}], 'MarkerSize', 8, 'LineWidth', 1.5, 'MarkerFaceColor', colors{j}, 'MarkerEdgeColor','black');
    end
end

% Plot the diagonal line
plot([0, 5], [0, 5], 'k-', 'LineWidth', 1.5);

% Plot the JND limits
jnd = 0.2;  % 20% JND
x = 0:0.1:5;
plot(x, x*(1+jnd), 'k--', 'LineWidth', 1);
plot(x, x*(1-jnd), 'k--', 'LineWidth', 1);

% Customize the plot
xlabel('Estimated (s)');
ylabel('Recorded (s)');
title('RT60s for the five rooms');
axis([0 5 0 2]);
grid on;

% Create method legend
h_method = zeros(1, length(methods));
for i = 1:length(methods)
    h_method(i) = plot(NaN,NaN, ['k' markers{i}], 'MarkerSize', 8, 'LineWidth', 1.5);
end
legend(h_method, methods, 'Location', 'northwest', 'AutoUpdate', 'off');

% Create scene legend
h_scene = zeros(1, length(scenes));
for j = 1:length(scenes)
    h_scene(j) = plot(NaN,NaN, [colors{j} 's'], 'MarkerSize', 8, 'LineWidth', 1.5, 'MarkerFaceColor', colors{j});
end
legend([h_method, h_scene], [methods, scenes], 'Location', 'northwest');

hold off;