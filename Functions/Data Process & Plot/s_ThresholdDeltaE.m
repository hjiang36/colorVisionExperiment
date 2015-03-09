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
% fileName = fullfile(colorVisionExperimentRootPath, 'Exp Data', ...
%                     'expResults', 'Final Results', 'Detection MS Plain',...
%                     'colorDetection_HJ_Protan.mat');
control1 = load(fileName);

fileName = fullfile(colorVisionExperimentRootPath, 'Exp Data', ...
    'expResults', 'jf', 'colorDetection_LS_Deuteran.mat');
% fileName = fullfile(colorVisionExperimentRootPath, 'Exp Data', ...
%                    'expResults', 'Final Results', 'Detection MS Plain',...
%                     'colorDetection_JEF_Protan.mat');
control2 = load(fileName);

fileName = fullfile(colorVisionExperimentRootPath, 'Exp Data', ...
                      'expResults', 'rz', 'colorDetection_LS.mat');
% fileName = fullfile(colorVisionExperimentRootPath, 'Exp Data', ...
%                   'expResults', 'Final Results', 'Detection MS Plain',...
%                    'colorDetection_Protanopia.mat');
subjectData = load(fileName);

direction = [30 45 75 105 135 150 -30 -45 -75 -105 -135 -150];
pCorrect = 0.8;
refContrast = [0 0 0]';
d = displayCreate('CRT-NEC');
cbType = 2; % Colorblind Type
deltaEThresh = zeros(length(direction), 3);

%% Plot for each direction
% open new figure window
lineColorB = [117 112 179]/255;
lineColorR = [217 95 2] / 255;
lineColorG = [27 158 119] / 255;
lineColorGray = [0.5 0.5 0.5];

% plot for each color direction
for ii = 1 : length(direction)
    sData = subjectData.expResult(ii);
    dir = [cosd(direction(ii)) 0 sind(direction(ii))];
    indx = sData.numTrials > 3;
    
    % Weibull fit
    [alpha,beta,~] = FitWeibAlphTAFC(sData.stimLevels(indx), ...
        sData.numCorrect(indx), sData.numTrials(indx) - ...
        sData.numCorrect(indx),[],4);
    
    % plot fitted curve
    xContrast = alpha*(-log(2*(1-pCorrect))).^(1/beta);
    deltaEThresh(ii,1) = coneContrast2DeltaEab(xContrast, dir, d, cbType);
        
    sData = control1.expResult(ii);
    indx = sData.numTrials > 3;
    
    % Weibull fit
    [alpha,beta,~] = FitWeibAlphTAFC(sData.stimLevels(indx), ...
        sData.numCorrect(indx), sData.numTrials(indx) - ...
        sData.numCorrect(indx),[],4);
    
    % plot fitted curve
    xContrast = alpha*(-log(2*(1-pCorrect))).^(1/beta);
    deltaEThresh(ii,2) = coneContrast2DeltaEab(xContrast, dir, d, cbType);

    sData = control2.expResult(ii);
    indx = sData.numTrials > 3;
    
    % Weibull fit
    [alpha,beta,~] = FitWeibAlphTAFC(sData.stimLevels(indx), ...
        sData.numCorrect(indx), sData.numTrials(indx) - ...
        sData.numCorrect(indx),[],4);
    
    xContrast = alpha*(-log(2*(1-pCorrect))).^(1/beta);
    deltaEThresh(ii,3) = coneContrast2DeltaEab(xContrast, dir, d, cbType);

    
end

%% plot
vcNewGraphWin; hold on;
plot(deltaEThresh(:,2), deltaEThresh(:,1), 'o');
plot(deltaEThresh(:,3), deltaEThresh(:,1), 'x');
xlabel('Control Threshold'); ylabel('Subject Threshold');
plot([0 2], [0 2], '--', 'Color', lineColorGray);
grid on;
