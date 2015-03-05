%% s_plotDataEab
%
%    This script will Plot Dichromatic Color Detection Psychophysics Curve
%    against DeltaEab value. The plot will be in 12 different subplot and
%    each subplot is corresponding to one color direction
%    
%    Notes:
%      This script is adopted from the GNUPlot script we used some time
%      ago and this script is written within Matlab 2014b.
%
% (HJ) ISETBIO TEAM, 2015

%% Init
ieInit; % init a new ISET session

%% Load data & parameters
fileName = fullfile(colorVisionExperimentRootPath, 'Exp Data', ...
                    'expResults', 'hj', 'colorDetection_LS_Deuteran.mat');
load(fileName);
direction = [30 45 75 105 135 150 -30 -45 -75 -105 -135 -150];
pCorrect = 0.5:0.01:0.99;
refContrast = [0 0 0]';

%% Plot for each direction
% open new figure window
vcNewGraphWin; 

% plot for each color direction
for ii = 1 : length(expResult)
    % create subplot
    subplot(3, 4, ii); grid on; hold on;
    title(sprintf('Direction:%d', direction(ii)));
    
    sData = expResult(ii);
    dir = deg2rad(direction(ii));
    dir = [cos(dir) 0 sin(dir)];
    indx = sData.numTrials > 3;
    
    % Weibull fit
    [alpha,beta,~] = FitWeibAlphTAFC(sData.stimLevels(indx), ...
        sData.numCorrect(indx), sData.numTrials(indx) - ...
        sData.numCorrect(indx),[],4);
    
    % plot fitted curve
    plot(alpha*(-log(2*(1-pCorrect))).^(1/beta), pCorrect);
    
    % convert contrast (stimLevels) to deltaE value
    %
    %
    %
    
    % scatter plot points
    scatter(sData.stimLevels(indx), ...
            sData.numCorrect(indx)./sData.numTrials(indx), ...
            sData.numTrials(indx) * 4, 'b');
    
    % set x and y limit
    xlim([0 0.04]); ylim([0.5 1]);
    
end
