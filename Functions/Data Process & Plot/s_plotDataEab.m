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
% fileName = fullfile(colorVisionExperimentRootPath, 'Exp Data', ...
%                    'expResults', 'hj', 'colorDetection_LS_Deuteran.mat');  
fileName = fullfile(colorVisionExperimentRootPath, 'Exp Data', ...
                   'expResults', 'Final Results', 'Detection MS Plain',...
                   'colorDetection_HJ_Protan.mat');
control1 = load(fileName);

% fileName = fullfile(colorVisionExperimentRootPath, 'Exp Data', ...
%                    'expResults', 'jf', 'colorDetection_LS_Deuteran.mat');
fileName = fullfile(colorVisionExperimentRootPath, 'Exp Data', ...
                    'expResults', 'Final Results', 'Detection MS Plain',...
                    'colorDetection_JEF_Protan.mat');
control2 = load(fileName);

% fileName = fullfile(colorVisionExperimentRootPath, 'Exp Data', ...
%                      'expResults', 'rz', 'colorDetection_LS.mat');
fileName = fullfile(colorVisionExperimentRootPath, 'Exp Data', ...
                   'expResults', 'Final Results', 'Detection MS Plain',...
                    'colorDetection_Protanopia.mat');
subjectData = load(fileName);

direction = [30 45 75 105 135 150 -30 -45 -75 -105 -135 -150];
pCorrect = 0.5:0.01:0.99;
refContrast = [0 0 0]';
d = displayCreate('CRT-NEC');
cbType = 1; % Colorblind Type

%% Plot for each direction
% open new figure window
vcNewGraphWin; hold on;
lineColorB = [117 112 179]/255;
lineColorR = [217 95 2] / 255;
lineColorG = [27 158 119] / 255;
lineColorGray = [0.5 0.5 0.5];

% plot for each color direction
for ii = 1 : length(expResult)
    % create subplot
    subplot(3, 4, ii); grid on; hold on;
    title(sprintf('Direction:%d', direction(ii)));
    
    
    sData = subjectData.expResult(ii);
    dir = [0 cosd(direction(ii)) sind(direction(ii))];
    indx = sData.numTrials > 3;
    
    % Weibull fit
    [alpha,beta,~] = FitWeibAlphTAFC(sData.stimLevels(indx), ...
        sData.numCorrect(indx), sData.numTrials(indx) - ...
        sData.numCorrect(indx),[],4);
    
    % plot fitted curve
    xContrast = alpha*(-log(2*(1-pCorrect))).^(1/beta);
    xDeltaE = xContrast;
    for jj = 1 : length(xContrast)
        xDeltaE(jj) = coneContrast2DeltaEab(xContrast(jj), dir, d, cbType);
    end
    plot(xDeltaE, pCorrect, 'lineWidth', 2, 'Color', lineColorG);
    
    % convert contrast (stimLevels) to deltaE value
    idx = find(indx);
    xDeltaE = zeros(length(idx), 1);
    for jj = 1 : length(idx)
        xDeltaE(jj) = coneContrast2DeltaEab(sData.stimLevels(idx(jj)), ...
                      dir, d, cbType);
    end
    
    % scatter plot points
    scatter(xDeltaE, sData.numCorrect(indx)./sData.numTrials(indx), ...
            sData.numTrials(indx) * 4, lineColorG);
        
        
    sData = control1.expResult(ii);
    dir = deg2rad(direction(ii));
    dir = [cos(dir) 0 sin(dir)];
    indx = sData.numTrials > 3;
    
    % Weibull fit
    [alpha,beta,~] = FitWeibAlphTAFC(sData.stimLevels(indx), ...
        sData.numCorrect(indx), sData.numTrials(indx) - ...
        sData.numCorrect(indx),[],4);
    
    % plot fitted curve
    xContrast = alpha*(-log(2*(1-pCorrect))).^(1/beta);
    xDeltaE = xContrast;
    for jj = 1 : length(xContrast)
        xDeltaE(jj) = coneContrast2DeltaEab(xContrast(jj), dir, d, cbType);
    end
    plot(xDeltaE, pCorrect, '--', 'lineWidth', 1, 'Color', lineColorGray);
    
    % convert contrast (stimLevels) to deltaE value
    idx = find(indx);
    xDeltaE = zeros(length(idx), 1);
    for jj = 1 : length(idx)
        xDeltaE(jj) = coneContrast2DeltaEab(sData.stimLevels(idx(jj)), ...
                      dir, d, cbType);
    end
    
    % scatter plot points
    scatter(xDeltaE, sData.numCorrect(indx)./sData.numTrials(indx), ...
            sData.numTrials(indx) * 4, lineColorGray);
        
        
    sData = control2.expResult(ii);
    dir = deg2rad(direction(ii));
    dir = [cos(dir) 0 sin(dir)];
    indx = sData.numTrials > 3;
    
    % Weibull fit
    [alpha,beta,~] = FitWeibAlphTAFC(sData.stimLevels(indx), ...
        sData.numCorrect(indx), sData.numTrials(indx) - ...
        sData.numCorrect(indx),[],4);
    
    % plot fitted curve
    xContrast = alpha*(-log(2*(1-pCorrect))).^(1/beta);
    xDeltaE = xContrast;
    for jj = 1 : length(xContrast)
        xDeltaE(jj) = coneContrast2DeltaEab(xContrast(jj), dir, d, cbType);
    end
    plot(xDeltaE, pCorrect, '--', 'lineWidth', 1, 'Color', lineColorGray);
    
    % convert contrast (stimLevels) to deltaE value
    idx = find(indx);
    xDeltaE = zeros(length(idx), 1);
    for jj = 1 : length(idx)
        xDeltaE(jj) = coneContrast2DeltaEab(sData.stimLevels(idx(jj)), ...
                      dir, d, cbType);
    end
    
    % scatter plot points
    scatter(xDeltaE, sData.numCorrect(indx)./sData.numTrials(indx), ...
            sData.numTrials(indx) * 4, lineColorGray);
    
    % set x and y limit
    xlim([0 1.5]); ylim([0.5 1]); drawnow();
    
end
