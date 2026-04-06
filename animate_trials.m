function neuralActivity = animate_trials(stimulusLocations, numChannels, baseDuration, stimDuration, ISI, totalLocations, peakSensitivityLocation, arraySize)

%ANIMATE_TRIALS Simulates and visualizes neural activity for each trial based on stimulus presentation.
%
% This function simulates neural activity in response to stimuli presented at
% various locations and visualizes this activity progressively as it would be
% recorded in a real experiment. The function accounts for the baseline period,
% the duration of each stimulus presentation, and the inter-stimulus interval (ISI).
%
% Usage:
%   neuralActivity = animate_trials(stimulusLocations, numChannels, baseDuration,
%       stimDuration, ISI, totalLocations, peakSensitivityLocation, arraySize)
%
% Inputs:
%   stimulusLocations      - Matrix specifying the stimulus locations for each trial.
%   numChannels            - Number of neural recording channels.
%   baseDuration           - Duration (ms) of the baseline period before stimulus presentation.
%   stimDuration           - Duration (ms) of each stimulus presentation.
%   ISI                    - Duration (ms) of the inter-stimulus interval.
%   totalLocations         - Total number of unique stimulus locations.
%   peakSensitivityLocation- The location with peak neural sensitivity.
%   arraySize              - Size of the stimulus presentation grid (e.g., [4, 6]).
%
% Outputs:
%   neuralActivity         - 3D matrix (trials x channels x time) of simulated neural responses.
%
% Example:
%   neuralActivity = animate_trials(stimulusLocations, 100, 300, 500, 100, 24,
%       peakSensitivityLocation, [4, 6]);
%
% Notes:
%   - The function visualizes the stimulus presentation and the corresponding
%     neural activity for each location across all trials, updating the neural
%     activity visualization progressively to mimic real-time recording.
%   - The visualization includes an adjustment for the colorbar range to fix it
%     between 0 and 1 for consistency across different segments of the trial.
%
% See also: imagesc, colormap, caxis
%
% Author: Orhan Soyuhos, 2024


% Setup for visualization
gridRows = arraySize(1);
gridCols = arraySize(2);

% Define the entire recording duration for a trial
recordingDuration = baseDuration + (stimDuration * 3) + (ISI * 2);

% Initialize neural activity matrix for all trials
neuralActivity = zeros(size(stimulusLocations, 1), numChannels, recordingDuration);

% Initialize an empty (or NaN-filled) recording array for visualization
emptyRecording = NaN(size(stimulusLocations, 1), numChannels, recordingDuration); % Use NaN or zeros based on preference

% Visualization configuration
figure;

for trialIdx = 1:size(stimulusLocations, 1)
    currentLocations = stimulusLocations(trialIdx, :);

    % Simulate neural activity for the current trial
    trialActivity = simulate_neural_activity(currentLocations, numChannels, totalLocations, peakSensitivityLocation, baseDuration, stimDuration, ISI);
    neuralActivity(trialIdx, :, :) = trialActivity;

    for locIdx = 1:length(currentLocations)
        % Calculate the start and end time for the current stimulus's neural activity
        stimStartTime = baseDuration + ((locIdx - 1) * (stimDuration + ISI));
        stimEndTime = stimStartTime + stimDuration;

        % Update the emptyRecording with actual neural activity for the current stimulus period
        emptyRecording(trialIdx, :, stimStartTime:stimEndTime) = neuralActivity(trialIdx, :, stimStartTime:stimEndTime);

        % Visualization of stimulus presentation
        subplot(1, 2, 1); % Stimulus plot
        cla reset;
        plot_stimulus(gridRows, gridCols, currentLocations(locIdx));
        title(sprintf('Trial %d, Stimulus %d', trialIdx, locIdx));

        % Visualization of progressively updated neural activity
        subplot(1, 2, 2); % Neural activity plot
        imagesc(squeeze(emptyRecording(trialIdx, :, :))); % Use the entire duration for x-axis
        colormap('parula');
        caxis([0, 1]); % Fix the colorbar range between 0 and 1
        title(sprintf('Neural Activity up to Stimulus %d', locIdx));
        xlabel('Time (ms)');
        ylabel('Channel');
        colorbar;
        axis tight; % Ensure x-axis remains consistent
        drawnow;
        pause(0.2); % Adjust for visualization pace
    end
end
end
