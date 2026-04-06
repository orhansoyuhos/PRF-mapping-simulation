function plot_stimulus(gridRows, gridCols, currentStim)

%PLOT_STIMULUS Visualizes the location of a stimulus on a grid.
%
% This function visualizes the position of a stimulus on a predefined grid
% by highlighting the stimulated location. The grid and the stimulated
% position are defined by the input parameters. This visualization helps
% in understanding the spatial distribution of stimuli across trials.
%
% Usage:
%   plot_stimulus(gridRows, gridCols, currentStim)
%
% Inputs:
%   gridRows      - The number of rows in the stimulus grid.
%   gridCols      - The number of columns in the stimulus grid.
%   currentStim   - The linear index of the current stimulus location on the grid,
%                   assuming the grid is indexed row-wise.
%
% Outputs:
%   A figure window showing the grid with the current stimulus location highlighted.
%
% Example:
%   plot_stimulus(4, 6, 10);
%
% Notes:
%   - The function plots the entire grid with all locations represented as squares.
%     The current stimulus location is highlighted in a different color.
%   - This function does not return any output variables. It generates a plot
%     in a new figure window or the current figure window if one is already open.
%
% See also: ind2sub, plot, hold
%
% Author: Orhan Soyuhos, 2024

[row, col] = ind2sub([gridRows, gridCols], currentStim);
hold on;
for i = 1:gridRows
    for j = 1:gridCols
        rectangle('Position', [j - 0.5, i - 0.5, 1, 1], ...
                  'EdgeColor', 'k', ...
                  'FaceColor', 'w', ...
                  'LineWidth', 0.5);
    end
end
rectangle('Position', [col - 0.5, row - 0.5, 1, 1], ...
          'EdgeColor', 'k', ...
          'FaceColor', 'r', ...
          'LineWidth', 0.5);
xlim([0.5, gridCols + 0.5]);
ylim([0.5, gridRows + 0.5]);
axis equal;
axis off;
hold off;
end
