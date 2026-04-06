# Population Receptive Field (pRF) Mapping Simulation

A MATLAB simulation of population receptive field mapping using a multi-channel neural recording setup. The simulation generates synthetic neural activity in response to stimuli presented at different spatial locations on a grid, then recovers the population receptive field via response averaging.

## Overview

The simulation models a 4×6 stimulus grid presented to a population of neurons. Each neural channel has a preferred spatial location drawn from a Gaussian distribution centered on a user-defined peak sensitivity location. Stimuli are presented in randomized trials, neural responses are simulated, and the resulting population receptive field is visualized as a heatmap.

## Files

| File | Description |
|------|-------------|
| `RF_mapping_simulation.m` | Main script — sets experiment parameters and runs the full pipeline |
| `animate_trials.m` | Simulates and animates neural activity trial-by-trial |
| `simulate_neural_activity.m` | Generates synthetic channel responses using a Gaussian spatial tuning model |
| `calculate_population_receptive_field.m` | Computes and visualizes the pRF heatmap from recorded activity |
| `plot_stimulus.m` | Renders the current stimulus location on the grid |

## Requirements

- MATLAB (R2019b or later recommended)
- Statistics and Machine Learning Toolbox (used by `heatmap`)

## Usage

Open and run `RF_mapping_simulation.m` in MATLAB. Key parameters at the top of the script can be adjusted:

```matlab
arraySize = [4, 6];              % Stimulus grid dimensions
repetitionsPerLocation = 10;     % How many times each location is presented
baselineDuration = 300;          % Pre-stimulus baseline (ms)
stimulusDuration = 500;          % Duration of each stimulus (ms)
ISIDuration = 100;               % Inter-stimulus interval (ms)
numChannels = 32;                % Number of recording channels
color_map = hot;                 % Colormap for the pRF heatmap
interpolation = true;            % Smooth the heatmap via cubic interpolation
```

The script will:
1. Generate a randomized stimulus sequence ensuring each of the 24 locations is shown `repetitionsPerLocation` times.
2. Animate the trial-by-trial stimulus presentation and neural activity.
3. Compute the population receptive field by averaging channel responses per location.
4. Display the pRF as a heatmap and print the population's preferred location to the console.

## Simulation Details

- **Spatial tuning**: Each channel's preferred location is sampled from a 2D Gaussian centered on `peakSensitivityLocation`, with spread `σ = sqrt(totalLocations) / 6`.
- **Response model**: Channel response strength to a stimulus is `exp(-0.5 * (distance / σ)²)`, where distance is the Euclidean distance between the channel's preferred location and the stimulus location.
- **Trial structure**: Each trial presents 3 stimuli, with baseline → stim → ISI → stim → ISI → stim timing.
- **pRF recovery**: Mean activity during each stimulus period is aggregated across trials and channels to estimate the response at each grid location.

## Output

- An animated figure showing the stimulus grid and per-channel neural activity updating in real time across trials.
- A heatmap of the population receptive field (optionally smoothed via cubic interpolation).
- Console output confirming trial count, unique targets per trial, location repetition counts, and the population's preferred grid location.
