function calculate_population_receptive_field(neuralActivity, stimulusLocations, color_map, interpolation, arraySize, baselineDuration, stimulusDuration, ISIDuration)

%CALCULATE_POPULATION_RECEPTIVE_FIELD Calculates and visualizes the population receptive field (PRF).
%
% This function computes the PRF based on neural activity elicited by stimuli
% presented at various locations on a predefined grid. It aggregates neural
% responses to each location, averages them across trials, and visualizes
% the results as a heatmap. Optionally, it can interpolate the heatmap for
% smoother visualization.
%
% Usage:
%   calculate_population_receptive_field(neuralActivity, stimulusLocations,
%       color_map, interpolation, arraySize, baselineDuration,
%       stimulusDuration, ISIDuration)
%
% Inputs:
%   neuralActivity     - 3D matrix (trials x channels x time) of neural responses.
%   stimulusLocations  - Matrix specifying the stimulus locations for each trial.
%   color_map          - Colormap for heatmap visualization.
%   interpolation      - Boolean flag for interpolating the heatmap.
%   arraySize          - Size of the stimulus presentation grid (e.g., [4, 6]).
%   baselineDuration   - Duration (ms) of the baseline period before stimulus presentation.
%   stimulusDuration   - Duration (ms) of each stimulus presentation.
%   ISIDuration        - Duration (ms) of the inter-stimulus interval (ISI).
%
% Outputs:
%   A heatmap visualization of the PRF is displayed. If `interpolation` is true,
%   the heatmap will be interpolated for smoother transitions between grid locations.
%
% Example:
%   calculate_population_receptive_field(neuralActivity, stimulusLocations,
%       'hot', true, [4, 6], 300, 500, 100)
%
% Notes:
%   - The function requires the Statistics and Machine Learning Toolbox for some
%     functions (e.g., `heatmap`).
%   - The `stimulusLocations` matrix should contain integers representing
%     unique locations on the grid, with each row corresponding to a trial.
%
% See also: heatmap, imagesc
%
% Author: Orhan Soyuhos, 2024

% Initialize variables
numLocations = max(stimulusLocations(:));
numRows = arraySize(1);
numCols = arraySize(2);
responseGrid = zeros(numRows, numCols); % Initialize response grid

% Calculate the stimulus presentation periods within a trial
stimPeriods = [baselineDuration + 1, baselineDuration + stimulusDuration]; % First stimulus period
for i = 2:3 % For each subsequent stimulus
    stimPeriods(i, :) = stimPeriods(i-1, :) + stimulusDuration + ISIDuration;
end

% Aggregate and average neural activity for each location
for loc = 1:numLocations
    locActivity = []; % Initialize an empty array to hold activity for this location
    for trialIdx = 1:size(stimulusLocations, 1)
        for stimIdx = 1:3 % For each stimulus position in a trial
            if stimulusLocations(trialIdx, stimIdx) == loc
                % Extract neural activity for this location's presentation period
                periodStart = stimPeriods(stimIdx, 1);
                periodEnd = stimPeriods(stimIdx, 2);
                locActivity = [locActivity; neuralActivity(trialIdx, :, periodStart:periodEnd)];
            end
        end
    end

    % Calculate mean response for this location
    if ~isempty(locActivity)
        % Average across time, channels and trials
        meanResponse = mean(mean(mean(locActivity, 3), 2), 1);
        [row, col] = ind2sub(arraySize, loc);
        responseGrid(row, col) = meanResponse;
    end
end

% Visualization
if ~interpolation
    figure;
    heatmap(responseGrid, 'Colormap', color_map, 'GridVisible', 'off');
    title('Population Receptive Field Heatmap');
else
    % Interpolate the data for smoother transitions
    [numRows, numCols] = size(responseGrid);
    fineGridRows = linspace(1, numRows, numRows*10); % Increase for finer interpolation
    fineGridCols = linspace(1, numCols, numCols*10);
    [gridX, gridY] = meshgrid(1:numCols, 1:numRows);
    [fineGridX, fineGridY] = meshgrid(fineGridCols, fineGridRows);
    interpolatedResponseGrid = interp2(gridX, gridY, responseGrid, fineGridX, fineGridY, 'cubic');

    % Plot using imagesc for smoother appearance
    figure;
    imagesc(interpolatedResponseGrid);
    colormap(hot); % Use a colormap that supports smooth transitions
    colorbar; % Optionally add a colorbar to indicate scale
    axis equal tight; % Adjust axis for equal aspect ratio and tight fit
    title('Population Receptive Field Heatmap (Smoothed)');
    % Set axis ticks to correspond to the original number of rows and columns
    ax = gca; % Get current axes
    ax.XTick = linspace(1, size(interpolatedResponseGrid, 2), numCols); % Set X ticks to match original columns
    ax.YTick = linspace(1, size(interpolatedResponseGrid, 1), numRows); % Set Y ticks to match original rows
    ax.XTickLabel = 1:numCols; % Label X ticks with original column numbers
    ax.YTickLabel = 1:numRows; % Label Y ticks with original row numbers
end

end
