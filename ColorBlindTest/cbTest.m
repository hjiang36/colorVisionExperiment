%% s_cbStaircaseMain
%    This is the main function for running psychophysical staircase to
%    assess color vision similarities for color blind people
%
%    Staircase is controlled by generic doStaircase function (RFD)
%    Stimulus generation function is specified as 'trialGenFuncName'
%    parameter
%
%  General Process:
%     1. s_cbStaircase - set parameters for experiment
%     2. doStaircase   - start staircase control process
%     3. cbTrial       - prepare 
%     4. doTrial       - show stimulus in each trial, get user response and
%                        give sound feedback to user
%
%  History
%    (HJ) Nov, 2012 - First version adopted from cocStairCase (RFD)
%    (HJ) Sep, 2013 - Add routine for detection and two interval pedestal
%                     experiment

%% Initialize parameters for display, staircase, stimulus, and subject
AssertOpenGL;

display          = initDisplay;
if isempty(display), return; end

stimParams       = initStimParams('Gsig',10);   % Gaussian blurred stimulus
display          = initFixParams(display,0.25); % fixation fov to 0.25
stairParams      = initStaircaseParams;
dataDir          = initDataDir;
subjectParams    = getSubjectParams(dataDir);

priorityLevel    = 0;
trialGenFuncName = 'cbTrialDetection'; 

%% Subject data and log file
if exist(fullfile(dataDir,[subjectParams.name '.log']),'file')
    delete(fullfile(dataDir,[subjectParams.name '.log']));
end
logFID(1) = fopen(fullfile(dataDir,[subjectParams.name '.log']), 'a+');
%fprintf(logFID(1), '%s\n', datestr(now));
%fprintf(logFID(1), '%s\n', subjectParams.comment);

fprintf(logFID(1), '\n');
logFID(2) = 1;
hideCursor = false;

%% Custumize the instruction Page
instructions{1} = 'Color Test\n';
instructions{2} = 'This test is composed of several trials. In each trial, you will be presented four colors, two at each time\n';
instructions{3} = 'Your task is to tell colors in which group are the same. Press A for first group and L for second\n';
instructions{4} = 'If your answer is correct, you will hear a cheering sound. If your answer is wrong, you will hear beep\n';
instructions{5} = 'Press any key to continue';
stairParams.customInstructions = ['pressKey2Begin(display,0,false,''' cell2mat(instructions) ''')'];

%% Do the staircase
%  open screen
display    = openScreen(display,'hideCursor',false);

%  do staircase
newDataSum = doStaircase(display, stairParams, stimParams, ...
    trialGenFuncName, priorityLevel, logFID);

%  close screen
display = closeScreen(display);
fclose(logFID(1));

%% Visualize Data





