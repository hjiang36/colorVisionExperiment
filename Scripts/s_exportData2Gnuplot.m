%% s_exportData2Gnuplot
%
%    This script exports data to files that could be load by gnu-plot
%
%  (HJ) ISETBIO TEAM, 2014

%% Load data
load('deuteranopia.mat');

%% Init display and stimulus structure
display = initDisplay('CRT-NEC');
stimParams       = initStimParams;
display          = initFixParams(display,0.25); % fixation fov to 0.25
stairParams      = initStaircaseParams;

%% Re-structure data
dir_index = 1; % 30 degree
direction = deg2rad(stairParams.curStairVars{2}(dir_index));
direction = [cos(direction) sin(direction)];
sData = expResult(dir_index);

% filter data by number of trials
index = sData.numTrials > 3;
index = index(:);

% set stimulus position to out_matrix
out_matrix(:, 1 : 2) = bsxfun(@times, sData.stimLevels(index), direction);

% set number of trials of stimulus to out_matrix
out_matrix(:, 3) = sData.numTrials(index);

% set correct rate to out_matrix
out_matrix(:, 4) = sData.numCorrect(index) ./ sData.numTrials(index);

%% Write data to file
dlmwrite('deuteranopia_data_gnu.txt', out_matrix, 'delimiter', '\t');

%% Export simulated deuteranopia data
clear out_matrix
load('JEF_Deuteran.mat');
sData = expResult(dir_index);

% filter data by number of trials
index = sData.numTrials > 3;
index = index(:);

[~, bgLMS] = coneContrast2RGB(display,[0 0 0]');
contrast = zeros(sum(index), 3);
contrast(:, [1 3]) = bsxfun(@times, sData.stimLevels(index), direction);
matchLMS = bsxfun(@times, contrast + 1, bgLMS');
contrast = brettelColorTransform(reshape(matchLMS, [sum(index) 1 3]), 2, bgLMS);
contrast = reshape(contrast, [sum(index) 3]);
contrast = bsxfun(@rdivide, contrast, bgLMS') - 1;

out_matrix(:, 1:3) = contrast;

% set number of trials of stimulus to out_matrix
out_matrix(:, 4) = sData.numTrials(index);

% set correct rate to out_matrix
out_matrix(:, 5) = sData.numCorrect(index) ./ sData.numTrials(index);

% Write data to file
dlmwrite('sim_deuteranopia_data_gnu.txt', out_matrix, 'delimiter', '\t');