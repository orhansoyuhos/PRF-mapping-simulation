clear
close all

%%
arraySize = [4, 6]; % 4 by 6 array

% Experiment parameters
repetitionsPerLocation = 10; % Each location is shown 10 times

% New Timing Parameters
baselineDuration = 300; % Baseline duration in ms before the first stimulus
stimulusDuration = 500; % Duration for each stimulus presentation in ms
ISIDuration = 100;  % Duration of the inter-stimulus interval (ISI) in ms

% Calculate total recording duration for a trial
recordingDuration = baselineDuration + (stimulusDuration * 3) + (ISIDuration * 2); % Adjusted for the new trial structure

% Channel parameters
peakSensitivityLocation = randi(24);
numChannels = 32; % Number of channels

% Heatmap parameters
color_map = hot; % parula, hot, etc.
interpolation = true;

%%
totalLocations = prod(arraySize); % Total number of unique locations
targetsPerTrial = 3; % Number of targets shown per trial
totalTrials = (totalLocations * repetitionsPerLocation) / targetsPerTrial; % Total number of trials

% Generate stimulus locations
% Initialize stimulus locations array
stimulusLocations = zeros(totalTrials, targetsPerTrial);

% Create a pattern that ensures each location is shown 10 times across all trials
for i = 1:repetitionsPerLocation
    % Shuffle locations for each repetition block
    shuffledLocations = randperm(totalLocations);
    for j = 1:(totalLocations / targetsPerTrial)
        startIdx = (i - 1) * (totalLocations / targetsPerTrial) + j;
        stimulusLocations(startIdx, :) = shuffledLocations((j - 1) * targetsPerTrial + 1 : j * targetsPerTrial);
    end
end


% 1. Verify Total Number of Trials
if size(stimulusLocations, 1) == totalTrials
    fprintf('The total number of trials matches the required %d trials.\n', totalTrials);
else
    error('Mismatch in the total number of trials. Expected: %d, Found: %d\n', totalTrials, size(stimulusLocations, 1));
end

% 2. Verify Unique Targets per Trial
% This checks that each row (trial) has unique elements (locations)
uniqueTargetsPerTrialCheck = all(arrayfun(@(i) numel(unique(stimulusLocations(i,:))) == targetsPerTrial, 1:totalTrials));
if uniqueTargetsPerTrialCheck
    fprintf('Each trial has exactly %d unique targets.\n', targetsPerTrial);
else
    error('Error: Not all trials have %d unique targets.\n', targetsPerTrial);
end

% 3. Verify Correct Repetition of Each Location
% This counts the occurrences of each location across all trials
locationCounts = histcounts(stimulusLocations, 1:(totalLocations+1));
if all(locationCounts == repetitionsPerLocation)
    fprintf('Each location is repeated exactly %d times across all trials.\n', repetitionsPerLocation);
else
    error('Error: Not all locations are repeated %d times.\n', repetitionsPerLocation);
end

% simulate the trials and recordings, pass the new timing parameters
neuralActivity = animate_trials(stimulusLocations, numChannels, baselineDuration, stimulusDuration, ISIDuration, totalLocations, peakSensitivityLocation, arraySize);
% find population receptive field
calculate_population_receptive_field(neuralActivity, stimulusLocations, color_map, interpolation, arraySize, baselineDuration, stimulusDuration, ISIDuration);
% print population's preferred location
[x, y] = ind2sub(arraySize, peakSensitivityLocation);
fprintf("Population's preferred location: row = %d; column = %d.\n", x, y);

%% Orhan Soyuhos 2024