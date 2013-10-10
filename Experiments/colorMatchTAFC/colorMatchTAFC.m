function expResult = colorMatchTAFC(subjectParams, display, varargin)
%% function colorMatchTAFC(subjectParams, display, [varargin])
%    This is the main function for running psychophysical staircase to
%    assess color vision similarities for color blind people
%
%    Staircase is controlled by generic doStaircase function (RFD)
%    Stimulus generation function is specified as 'trialGenFuncName'
%    parameter
%
%    Each trial in this experiment has two intervals. In each interval, two
%    flat color patches are shown to the subject, either same or different.
%    The subject is asked to choose in which interval the two patches are
%    different
%
%  Inputs:
%    subjectParams  - structure contains subject information, including
%                     subject name, colorblind type and etc.
%    display        - display name string or display structure
%    varargin       - name-values pairs to be used to control stimulus
%                     parameters
%
%  Output:
%    expResult      - structure that contains experiment result
%
%  History
%    (HJ) Nov, 2012 - First version adopted from cocStairCase (RFD)
%    (HJ) Sep, 2013 - Add routine for detection and two interval pedestal
%                     experiment
%

%% Check inputs
if nargin < 1, error('Subject info structure needed'); end
if nargin < 2
    warning('Display not set, use NEC CRT data');
    display = initDisplay('CRT-NEC');
end

if ischar(display)
    display = displayCreate(display);
end

display.USE_BITSPLUSPLUS = true;

%% Initialize parameters for display, staircase, stimulus, and subject
AssertOpenGL;

if ~isempty(varargin)
    stimParams = initStimParams('cbType', subjectParams.cbType, varargin);
else
    stimParams = initStimParams('cbType', subjectParams.cbType);
end

display       = initFixParams(display,0.25); % fixation fov to 0.25
stairParams   = initStaircaseParams;

priorityLevel    = 0;
trialGenFuncName = 'colorMatchTAFCTrial'; 

%% Custumize the instruction Page
instructions{1} = 'Color Test\n';
instructions{2} = 'This test is composed of several trials. In each trial, you will be presented four colors, two at each time\n';
instructions{3} = 'Your task is to tell colors in which group are the same. Press Z for first group and X for second\n';
instructions{4} = 'If your answer is correct, you will hear a cheering sound. If your answer is wrong, you will hear beep\n';
instructions{5} = 'Press any key to continue';
stairParams.customInstructions = ['pressKey2Begin(display,0,false,''' ...
    cell2mat(instructions) ''')'];

%% Do the staircase
%  open screen
display    = openScreen(display,'hideCursor',false);

%  do staircase
expResult = doStaircase(display, stairParams, stimParams, ...
    trialGenFuncName, priorityLevel);

%  close screen
closeScreen(display);

%% Save experiment results
%  Save at this point to avoid any data loss later
dataFileName = fullfile(subjectParams.dataDir, 'colorMatchTAFC.mat');
save(dataFileName, 'expResult');

%% Weibull fit and Visualization
%  fitting
threshColor = zeros(2, length(expResult));
refLMS = RGB2ConeContrast(display, stimParams.refColor);
for curStair = 1 : length(expResult)
    sData = expResult(curStair);
    dir = deg2rad(stairParams.curStairVars(curStair));
    indx = sData.numTrials > 0;
    [alpha,beta,~] = FitWeibAlphTAFC(sData.stimLevels(indx), ...
        sData.numCorrect(indx), sData.numTrials - sData.numCorrect,[],2.2);
    thresh = FindThreshWeibTAFC(0.75,alpha,beta);
    threshColor(:,curStair) = refLMS(1:2) + thresh * [cos(dir) sin(dir)];
    expResult(curStair).threshold = thresh;
end

%  save again
save(dataFileName, 'expResult');

%  plot threshold data and fitted ellipse
hf = figure('NumberTitle', 'off', ...
       'Name', 'Color Contour', ...
       'Visible', 'off'); hold on;
grid on; xlabel('L'); ylabel('M');
plot(threshColor(1,:), threshColor(2,:), 'ro');

if subjectParams.cbType == 0
    [zg, ag, bg, alphag] = fitellipse(results.threshColor);
    plotellipse(zg, ag, bg, alphag, 'b--')
end

axis equal;

figureFileName = fullfile(subjectParams.dataDir, 'colorContour.png');
saveas(hf, figureFileName);
close(hf);

%% Send Email
c = clock;
emailContent = sprintf(['%s finished experiment color match TAFC ' ...
    'by %d-%d-%d %d:%d:%d'],subjectParams.name, ...
    c(1),c(2),c(3),c(4),c(5),round(c(6)));
sendMailAsHJ({'hjiang36@gmail.com'},'Color Match TAFC Experiment Done', ...
    emailContent, {dataFileName});

