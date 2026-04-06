function trialActivity = simulate_neural_activity(currentLocations, numChannels, totalLocations, peakSensitivityLocation, baselineDuration, stimulusDuration, ISIDuration)

%SIMULATE_NEURAL_ACTIVITY Simulates neural activity in response to stimuli presented at specific locations.
%
% This function generates simulated neural activity for a set of channels
% based on the presentation of stimuli at various locations on a grid. The
% simulation incorporates a Gaussian response profile to model the spatial
% sensitivity of neurons around a peak sensitivity location. The activity is
% simulated for the entire duration of a trial, including baseline, stimulus
% presentations, and inter-stimulus intervals (ISIs).
%
% Usage:
%   trialActivity = simulate_neural_activity(currentLocations, numChannels,
%       totalLocations, peakSensitivityLocation, baselineDuration,
%       stimulusDuration, ISIDuration)
%
% Inputs:
%   currentLocations      - Array indicating the locations of stimuli presented in a trial.
%   numChannels           - Number of neural recording channels.
%   totalLocations        - Total number of unique stimulus locations.
%   peakSensitivityLocation - The grid location with peak neural sensitivity.
%   baselineDuration      - Duration (ms) of the baseline period before stimulus presentation.
%   stimulusDuration      - Duration (ms) of each stimulus presentation.
%   ISIDuration           - Duration (ms) of the inter-stimulus interval.
%
% Output:
%   trialActivity         - Matrix (channels x time) of simulated neural activity for one trial.
%
% Example:
%   trialActivity = simulate_neural_activity([1, 5, 9], 100, 24, 12, 300, 500, 100);
%
% Notes:
%   - The function assumes a Gaussian distribution of sensitivity around the
%     peak sensitivity location. The spread of this distribution is adjusted based
%     on the total number of locations.
%   - The grid size for stimulus locations is inferred from `totalLocations` and
%     is expected to form a rectangular grid (e.g., 4x6 for `totalLocations` = 24).
%
% See also: rand, exp, sqrt, mod
%
% Author: Orhan Soyuhos, 2024


% Parameters for the Gaussian response profile
sigma = sqrt(totalLocations) / 6; % Adjusted spread of sensitivity for 2D

% Define the grid size for a 4x6 layout
numRows = 4;
numCols = 6;

% Calculate total recording duration for one trial
recordingDuration = baselineDuration + 3 * stimulusDuration + 2 * ISIDuration;

% Initialize the activity matrix for one trial: Channels x RecordingDuration
trialActivity = zeros(numChannels, recordingDuration);

% Initialize matrix to record preferred locations in 2D grid coordinates
channelPreferredLocations = zeros(numChannels, 2); % Each row: [prefRow, prefCol]

% Calculate the 2D position of the peak sensitivity location
[peakRow, peakCol] = ind2sub([numRows, numCols], peakSensitivityLocation);

% Generate preferred locations around the peak in 2D
for channelIdx = 1:numChannels
    angle = 2 * pi * (channelIdx / numChannels); % Distribute angles evenly around the circle
    radius = sigma * sqrt(-2 * log(rand())); % Random radius with Gaussian falloff
    deltaRow = radius * cos(angle);
    deltaCol = radius * sin(angle);

    % Calculate preferred location in grid coordinates
    prefRow = round(peakRow + deltaRow);
    prefCol = round(peakCol + deltaCol);

    % Ensure preferred locations wrap around the grid boundaries
    prefRow = mod(prefRow - 1, numRows) + 1;
    prefCol = mod(prefCol - 1, numCols) + 1;

    % Record the preferred location
    channelPreferredLocations(channelIdx, :) = [prefRow, prefCol];
end

% Convert currentLocations to 2D grid positions (row, col)
[currentRows, currentCols] = ind2sub([numRows, numCols], currentLocations);

% Timing for each phase of a trial
times = [baselineDuration, stimulusDuration, ISIDuration, stimulusDuration, ISIDuration, stimulusDuration];
timeCumSum = cumsum([0, times]);

% Simulate activity for each channel
for channelIdx = 1:numChannels
    prefRow = channelPreferredLocations(channelIdx, 1);
    prefCol = channelPreferredLocations(channelIdx, 2);
    baseActivity = rand(1, recordingDuration) * 0.1; % Base level of activity

    % Iterate through each stimulus presentation period
    for stimIdx = 1:length(currentLocations)
        currentRow = currentRows(stimIdx);
        currentCol = currentCols(stimIdx);
        distance = sqrt((prefRow - currentRow)^2 + (prefCol - currentCol)^2);
        responseStrength = exp(-0.5 * (distance / sigma)^2);

        % Apply response strength to the appropriate time period for this stimulus
        startTime = timeCumSum(2*stimIdx) + 1;
        endTime = startTime + stimulusDuration - 1;
        baseActivity(startTime:endTime) = baseActivity(startTime:endTime) + responseStrength * rand(1, stimulusDuration);
    end

    trialActivity(channelIdx, :) = baseActivity;
end
end
