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
    warning('Display not set, use Apple LCD data');
    display = initDisplay('LCD-Apple');
end

if ischar(display)
    display = displayCreate(display);
end

% display.USE_BITSPLUSPLUS = true;

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
stairParams.customInstructions = ['pressKey2Begin(display,0,false,''' cell2mat(instructions) ''')'];

%% Do the staircase
%  open screen
display    = openScreen(display,'hideCursor',false);

%  do staircase
expResult = doStaircase(display, stairParams, stimParams, ...
    trialGenFuncName, priorityLevel);

%  close screen
closeScreen(display);

%% Visualize Data


%% Send Email


