function dataSum = doStaircase(display, stairParams, stimParams, ...
                              trialGenFuncName, priority, logFID, varargin)
%% function dataSum = doStaircase(display, stairParams, stimParams, ...
%                        trialGenFuncName, [priority], [logFID],[varargin])
% 
%    function that controls and runs staircases trials
%
%  Inputs:
%    display     - ISET compatible display structure
%    stairParams - staircase parameters (see below)
%    stimParams  - stimulus parameters
%
%    trialGenFuncName - string, specifies the function called to generate
%                       the stimuli. This function must exist in the
%                       current matlab path and can be executed by eval.
%                       'data' field is used for whatever you would like to
%                       be preserved from trial to trial (pre-computed
%                       images, colormaps, etc.). Note that 'data' will be
%                       independent across interleaved staircases unless
%                       stairParams.useGlobalData==true, in which case all
%                       interleaved staircases will share the same data
%                       structure. If so, the field 'stairNum' will be
%                       added to the shared data struct so that trial
%                       function can tell which staircase is running.
%
%
%    priority  - int, optional, specifies run priority (0-7, 0 is default)
%    logFID    - int, optional, specifies where log data goes, default is
%                the screen. if logFID is a vector, each of the files
%                specified will be written to.  All files written as text
%                files.
%
%    varargin  - strings, Specify any number of the following options:
%                precomputeFirstTrial: this option is really only useful
%                                      if your trialGenFunction saves
%                                      stuff in the 'data' structure that
%                                      will save time when building
%                                                   subsequent trials.
%                precomputeAllTrials:  this option builds all the trials
%                                      ahead of time.  It may take a while
%                                      to do this, especially if you have
%                                      a lot of adjustableVarValues!  Also
%                                      note that randomization will be
%                                      systematic. Trials in a staircase
%                                      with the same adjustableVarValue
%                                      will have the same randVarValues
%                                      and the same alternativeVarValue.
%                                      You can make things seem more random
%                                      by doing several staircases. Or, you
%                                      may want to do the precomputing in
%                                      your trialGenFunction and leave this
%                                      option off.
%
%
%
%  stairParams structure:
%
%    stairParams.alternativeVarName = 'testPosition';
%    stairParams.alternativeVarValues = ['L' 'R'];
%	     This must be a fieldname of stimParams.  The values are selected
%	     from the list at random and a trial is counted as 'correct' if
%	     alternative index and the response index are the same.  (e.g. if
%	     the second alternative was presented and the second response of
%	     response set was entered, then the trial will be counted as
%	     correct)
%
%   stairParams.adjustableVarName = 'varName';
%		This must be a fieldname of stimParams.  The values are selected
%		systematicallly from stairParams.stimLevels according to the rules
%		defined by the parameters below.
%
%   stairParams.adjustableVarStart = [1 1];
%		The length of this vector determines the number of interleaved
%		staircases (referred to as numStairs in this file).
% 		Each value in this vector is an index to adjustableVarValues which
% 		determines where each of the staircases start
%
%   stairParams.adjustableVarValues = [10.^[0:-.1:-2]];
%		An 1 x N vector or numStairs x N matrix specifying the N different
%		stimulus levels (N can be any value).  If the number of rows is
%		less than numStairs, then adjustableVarValues for all subsequent
%		staircases are taken from the levels of the last staircase
%		specified (e.g., if it is 1 x N, then all staircases will use the
%		same levels)
%
%   stairParams.randomVars = {'varName' [0:3:9]};
%		This is a cell array that may contain any number of rows, where
%		each row is a stimParams field name (the variable you want
%		randomized) and a vector listing the possible values.  DoStaircase
%		will randomly assign a value from the list to the variable(s)
%		before each trial.
%
%   stairParams.curStairVars = {'varName', [1 2 3]};
%		This is a cell array that may contain any number of rows, where
%		each row is a stimParams field name (the variable you want varied)
%		and a vector listing the possible values.  DoStaircase will assign
%		a value from the list to the variable(s) before each trial, based
%		on the current staircase. That is, the first value will be used
%		when doing a trial for the first interleaved staircase, the second
%		value used for the second staircase, etc.
%
%   stairParams.numCorrectForStep = 2;
%   stairParams.numIncorrectForStep = 1;
%		These two determine how many consecutive correct and how many
%		consecutive incorrect responses are needed before adjusting the
%		adjustableVarValue.
%
%   stairParams.correctStepSize = 2;
%   stairParams.incorrectStepSize = 1;
%		These two determine how many index units (of stimLevels) to jump
%		with a correct (or incorrect) response sequence that meets the
%		criteria defined by numCorrectForStep /numIncorrectForStep.
%
%   stairParams.maxNumTrials = 100;
%   stairParams.maxNumReversals = 10;
%		The staircase ends when either of these conditions are met.
%
%   stairParams.feedback = 'click';
%		feedback options: 'none', 'click', 'auditory'.  ('click' clicks
%		when a valid response is registered, but does not indicate
%		correct/incorrect.) You can also provide feedback through the trial
%		structure, including more elaborate visual feedback.
%
%   stairParams.responseSet = '13';
%		This is a string listing acceptable responses (no spaces!)
%		Alternative 1 is the first character in this sting, alternative 2
%		the second, and so on.  Do not use q or Q- these characters are
%		special and cause the experient to abort. If this field is a cell
%		array, then each element of the cell array is considers a valid set
%		of responses for the corresponding alternative. E.g., for a
%		2-alternative case where you want either 1 or 2 to be a correct
%		response for alt 1 and either 3 or 4 to be a correct response for
%		alt 2, use: stairParams.responseSet = {'12','34'};
%       If this field is omitted, then doStaircase will expect the trial to
%       return a response.
%
%	stairParams.conditionName = {'cond1'; 'cond2'};
%		This is a cell array where each row is the condition name for a
%		staircase. For example, the first row should contain the condition
%		name for the first staircase, the second row the name for the
%		second staircase, and so on. If there are fewer rows than
%		staircases, the the staircases without specified naems get the name
%		of the last named staircase.  If this field is omitted, all
%		staircases get the name of the adjustableVar.
%
%   stairParams.iti = 0.1;
%       Inter-trial interval, in seconds. (defaults to 0)
%
%   stairParams.useGlobalData = false;
%       Flag to determine whether staircase 'data' will be independent
%       across interleaved staircases or shared by all staircases. If true,
%       the field 'stairNum' will be automatically appended to the shared
%       data struct so trialGenFuncName can tell which staircase is
%       currently running. (Defaults to false; form mor einfo, see
%       trialGenFuncName above.)
%       
%   stairParams.saveDataVars = {'string var 1', 's'; 'digit var 2', 'd'};
%       Flag variables that you would like saved from the data structure on
%       a trial by trial basis.  Column one of the cell array should
%       contain the variable names as a string, and column two should
%       indicate, for each respective row, whether the data contained in it
%       is a string or a number (digits). 
%
%   stairParams.customInstructions = 'command to be run';
%       Write in the command you'd like to run instead of the default.  For
%       example: showInstructions(5,8,22); will execute that line.  Inputs
%       must be strings.
%
%   stairParams.prFlag = 1;
%       Setting this to 1 starts the inter-trial interval timer after the
%       response has been made.  Setting it to 0, or not setting it at
%       all, will start the inter-trial interval as soon as the stimulus is
%       no longer present.
%
% stimParams structure:
%
%   I added some things to this structure, though they might seem unrelated
%   to the stimuli.  I chose to do this because stimParams gets passed in
%   to each trial, and some of the things I needed control of occurred at
%   that level. - RFB
%
%   stimParams.quitKey = 'g';
%       Set the quit key to whatever you'd like with a string.
%
%   stimParams.inputDevice = 5;
%       Set the input device index for cases in which you're using an
%       external controller
%
% Hitory:
%   
% ( RFD) Oct, 1998  firt working version coded by Bob Dougherty (aka RFD)
% ( JW ) May, 2008  Added a check to see whether user wants to show timing
%                   for each trial (default is to show timing). Flag can be
%                   set in stairParams.showTiming.
% ( RFD) Jan, 2009  added code to allow multiple response keys. 
% ( RFD) Feb, 2009  added the option to share staircase data across all 
%                   interleaved staircases (useGlobalData flag). 
% ( RFB) Jul, 2009  Added option to change instructions screen
%                   (stairParams.customInstructions), add a custom input
%                   device (stimParams.inputDevice), change the quit key
%                   (stimParams.quitKey), or save variables within the data
%                   structure on a trial by trial basis
%                   (stairParams.saveDataVars).
%                   
%                   I also changed the function of ITI - it now begins the
%                   timer after the trial has actually completed.  Thus,
%                   you can set a space between otherwise rapid trials to
%                   allow subjects breathing room.  Previously this just
%                   didn't seem to be working as I'd like.
%
% ( RFB) Aug, 2009  Added stairParams.initTrialCount option. This gives you
%                   the order in which trials occurred, across staircases.
%                   Set to 1 to initialize the temp file 'tctemp.mat' which
%                   keeps track across multiple initializations of
%                   doStaircase, should you be running it in a loop as I do
%                   depending on the experiment.  Subsequent runs through
%                   should be then set to 0 to indicate you've already
%                   initialized the file, and to simply load your progress.
%                   
%                   Set to 2 to indicate you want to keep track of trials
%                   across staircases, but don't want to save out a temp
%                   file since you're only calling doStaircase once.  In a
%                   higher level function at the end of the program, it's
%                   probably useful or good behavior in general to delete
%                   the temp file since it's of no use between
%                   experimental sessions.  In any case, it will be
%                   written over by the next initialization.
% ( RFB) Sep, 2009  Be careful using the internal keyboard with numbers for
%                   responses, for some reason KbQueueCheck has a bit of a 
%                   hissy fit with this and doesn't register them well
% ( JW ) Jul, 2010  Added optional input arg 'plotEachTrialFlag' to plot 
%                   results after every trial, if requested.
% ( HJ ) Aug, 2013  Add bits++ support, structurize the code and add .mat
%                   output

%% Check inputs & Init
if nargin < 1, error('Display structure required'); end
if nargin < 2, error('Staircase parameter structure required'); end
if nargin < 3, error('Stimulus parameter structure required'); end
if nargin < 4, error('Trial generation function required'); end
if nargin < 5, priority = 0; end
if nargin < 6, logFID = 1; end

% Seed random number generator
ClockRandSeed;

% Set up flags if missing
if ~isfield(stairParams,'etFlag') % Eye tracking
    stairParams.etFlag = 0;
end

% Init trial stimulus duration display
if isfield(stairParams, 'showTiming')
    showTimingFlag = stairParams.showTiming;
else
    showTimingFlag = true;
end

% Init instructions script
if isfield(stairParams,'customInstructions')
    instructions = stairParams.customInstructions;
else
    instructions = 'pressKey2Begin(display,0);';
end

% Allow custom quit key
if isfield(stimParams,'quitKey')
    quitKey = stimParams.quitKey;
else
    quitKey = 'q';
end

% Allow different start points for inter-trial interval
if isfield(stairParams,'prFlag')
    prFlag = stairParams.prFlag;
else
    prFlag = 0;
end

% Determine if we need to keep track of the trial count
if isfield(stairParams,'initTrialCount')
    tcName = fullfile(stimParams.dataDir,'tctemp.mat');
    if stairParams.initTrialCount==1 || stairParams.initTrialCount==2
        trialCounts = 0;
    elseif stairParams.initTrialCount==0
        load(tcName);
    end
else
    stairParams.initTrialCount = 2;
    trialCounts = 0;
end

% Initialize all variables to be saved from trials
fStr = 'dataSum(curStair).%s(stairHistory.numTrials(curStair)) = data.%s;';
if isfield(stairParams,'saveDataVars')
    saveData = cell(length(stairParams.saveDataVars), 2);
    
    for i=1:length(stairParams.saveDataVars)
        if strcmp(stairParams.saveDataVars{i,2},'d') % Saving digits
            saveData{i,1} = sprintf('dataSum(curStair).%s = [];', ...
                                    stairParams.saveDataVars{i,1});
            saveData{i,2} = sprintf(fStr, ...
                stairParams.saveDataVars{i,1}, ...
                stairParams.saveDataVars{i,1});
        elseif strcmp(stairParams.saveDataVars{i,2},'s') % Saving strings
            saveData{i,1} = sprintf('dataSum(curStair).%s = {};', ...
                                    stairParams.saveDataVars{i,1});
            saveData{i,2} = sprintf(fStr, ...
                stairParams.saveDataVars{i,1}, ...
                stairParams.saveDataVars{i,1});
        else
            error('Unknown saving type');
        end
    end
end

% Get keyboard input device (see help file for specifics)
device = getBestDevice(display);

% Generate keyList for checking responses after the trial
% If you need to use some special keys, including number keys, use cell
% For example, {'1!','2@'}
keyList     = zeros(1,256);
includeKeys = zeros(1,length(stairParams.responseSet));
for i=1:size(stairParams.responseSet,2)
    if(iscell(stairParams.responseSet))
        includeKeys(i) = KbName(stairParams.responseSet{i});
    else
        includeKeys(i) = KbName(stairParams.responseSet(i));
    end
end

includeKeys = [includeKeys KbName(quitKey)]; % add quitKey
includeKeys = unique(includeKeys);

keyList(includeKeys) = 1; 

% Init fields in stair parameters
if ~isfield(stairParams, 'numIncorrectBeforeStep')
    stairParams.numIncorrectBeforeStep = 1;
end

if ~isfield(stairParams, 'randomVars')
    stairParams.randomVars = {};
end

if ~isfield(stairParams, 'feedback')
    stairParams.feedback = 'auditory';
end

if ~isfield(stairParams, 'curStairVars')
    stairParams.curStairVars = {};
end

% Initialize condition name
if ~isfield(stairParams, 'conditionName')
    if length(stairParams.curStairVars) < 1
        stairParams.conditionName = stairParams.adjustableVarName;
    else
        for ii = 1 : size(stairParams.adjustableVarStart, 1)
            for jj = 1 : size(stairParams.curStairVars, 1)
                stairParams.conditionName{ii,jj*2-1} = ...
                    stairParams.curStairVars{jj,1};
                stairParams.conditionName{ii,jj*2} = ...
                    stairParams.curStairVars{jj,2}...
                    (min(length(stairParams.curStairVars{jj,2}),ii));
            end
        end
    end
end

if ~isfield(stairParams, 'iti')
    stairparams.iti = 0;
end

if ~isfield(stairParams, 'useGlobalData')
    stairParams.useGlobalData = false;
end

numStairs = length(stairParams.adjustableVarStart); % number or staircases
numLevels = size(stairParams.adjustableVarValues, 2);

% Generate auditory feedback
if isfield(stairParams, 'feedback')
    if strcmp(stairParams.feedback,'auditory')
        correctSnd = soundFreqSweep(200, 500, .1);
        incorrectSnd = soundFreqSweep(1000, 200, .5);
    elseif  strcmp(stairParams.feedback,'click')
        % make both the same - a click to acknowledge the response
        correctSnd = soundFreqSweep(500, 1000, .01);
        incorrectSnd = soundFreqSweep(500, 1000, .01);
    else
        correctSnd = [];
        incorrectSnd = [];
    end
else
    correctSnd = [];
    incorrectSnd = [];
end

% Ensure the starting values are in range
if any(stairParams.adjustableVarStart>numLevels) || ...
        any(stairParams.adjustableVarStart<1)
    error('Starting values are out of range');
end

% Initialize all the book keeping stuff
data = cell(numStairs,1);

% Initialize structure to keep track of staircase parameters
stairHistory.numTrials = zeros(1,numStairs); % Number of trials run at 
stairHistory.numConsecCorrect = zeros(1,numStairs);
stairHistory.numConsecIncorrect = zeros(1,numStairs);
stairHistory.runDirection = ones(1,numStairs);
stairHistory.curAdjustIndex = stairParams.adjustableVarStart;
stairHistory.numReversals = zeros(1,numStairs);
stairHistory.done = zeros(1,numStairs); % indicate if staircase is done

numAlternatives = length(stairParams.alternativeVarValues);
numLevelVectors = size(stairParams.adjustableVarValues, 1);

% Initialize the dataSum
conditionIndx = 1 : numStairs;
conditionNameLength = length(stairParams.conditionName);
conditionIndx(conditionNameLength:end) = conditionNameLength;
stimIndx = 1 : numStairs;
stimIndx(numLevelVectors:end) = numLevelVectors;
stimLevels = stairParams.adjustableVarValues(stimIndx, :)';
stimLevels = mat2cell(stimLevels, length(stimLevels), ones(1, numStairs));
reversalStimLevel = ones(1,stairParams.maxNumReversals)*NaN;
dataSum = struct(...
    'history',     cell(1, numStairs), ...
    'response',    cell(1, numStairs), ...
    'correct',     cell(1, numStairs), ...
    'trialCounts', cell(1, numStairs), ...
    'condName',    stairParams.conditionName(conditionIndx), ...
    'stimLevels',  stimLevels, ...
    'numTrials',   mat2cell(zeros(numLevels, numStairs), numLevels, ...
                            ones(1, numStairs)), ...
    'numCorrect',  mat2cell(zeros(numLevels, numStairs), numLevels, ...
                            ones(1, numStairs)), ...
    'etxForm',     cell(1, numStairs), ...
    'etData',      cell(1, numStairs), ...
    'reversalStimLevel', num2cell(reversalStimLevel) ...
    );

if exist('saveData', 'var')
    for i=1:length(saveData)
        eval(saveData{i,1});
    end
end

% Build the appropriate trialGenFuncName
if(stairParams.useGlobalData)
    trialGenFuncName = [trialGenFuncName '(display, stimParams, data)'];
else
    trialGenFuncName = [trialGenFuncName ...
        '(display, stimParams, data{curStair})'];
end

%% parse the option flags
for ii=1:length(varargin)
    switch varargin{ii}
        case 'precomputeFirstTrial',
            % build the trial
            % if data file is shared, we only need to precompute one case
            if stairParams.useGlobalData
                stairCount = 1;
            else  % precompute first trial of each staircase
                stairCount = 1:numStairs;
            end
            for curStair = stairCount
                adjustValue = stairParams.adjustableVarValues(...
                                        min(curStair,numLevelVectors), 1);
                stimParams.(stairParams.adjustableVarName) = adjustValue;
                stimParams.(stairParams.alternativeVarName)= ...
                                      stairParams.alternativeVarValues(1);
                
                % set the curStair variable values
                curStairVal = zeros(length(stairParams.curStairVars),1);
                for i=1 : length(stairParams.curStairVars)
                    curStairVal(i) = stairParams.curStairVars{i,2}...
                        (min(curStair, ...
                        length(stairParams.curStairVars{i,2})));
                    stimParams.(stairParams.curStairVars{i,1}) = ...
                        curStairVal(i);
                end
                if(stairParams.useGlobalData)
                    data.curStairNum = curStair;
                    [trial, data] = eval(trialGenFuncName);
                else
                    [trial, data{curStair}] = eval(trialGenFuncName);
                end
            end
        case 'precomputeAllTrials',
            for curStair = 1:numStairs
                fprintf('Building trials for staircase %d\n', curStair);
                for adjustIndex = 1 : numLevels
                    adjustValue = stairParams.adjustableVarValues(...
                        min(curStair,numLevelVectors), adjustIndex);
                    % set the adjustable variable value
                    stimParams.(stairParams.adjustableVarName)=adjustValue;
                    % set the random variable values
                    randVal = zeros(length(stairParams.randomVars),1);
                    for i=1:length(stairParams.randomVars)
                        randVal(i) = stairParams.randomVars{i,2}...
                          (ceil(rand*length(stairParams.randomVars{i,2})));
                        stimParams.(stairParams.randomVars{i,1}) = ...
                          randVal(i);
                    end
                    % set the curStair variable values
                    for i=1:size(stairParams.curStairVars, 1)
                        curStairVal(i) = stairParams.curStairVars{i,2}...
                            (min(curStair, ...
                            length(stairParams.curStairVars{i,2})));
                        stimParams.(stairParams.curStairVars{i,1}) = ...
                            curStairVal(i);
                    end
                    % randomly choose and set the alternative variable
                    altIndex = round(rand*(numAlternatives-1))+1;
                    altValue = stairParams.alternativeVarValues(altIndex);
                    stimParams.(stairParams.alternativeVarName) = altValue;
                    % build the trial
                    if(stairparams.useGlobalData)
                        [trial{curStair, adjustIndex}, data] = ...
                            eval(trialGenFuncName);
                    else
                        [trial{curStair, adjustIndex}, data{curStair}]= ...
                            eval(trialGenFuncName);
                    end
                end
            end
        case 'plotEachTrial'
        otherwise,
            warning('doStaircase unrecognized option flag');
    end
end


%% Start Trial
if ~isfield(display, 'fixColorRgb'),
    display.fixColorRgb = [0 display.maxRgbValue 0 display.maxRgbValue];
end

% prepare the log
for i=1:length(logFID)
    % print out header
    fprintf(logFID(i), ['\ncurStair\ttrial\tadjustValue(%s)\t' ...
                        'correct\taltValue(%s)\tresponseKey\t'], ...
            stairParams.adjustableVarName, stairParams.alternativeVarName);
    for j= 1 : size(stairParams.randomVars, 1)
        fprintf(logFID(i), '%s\t', stairParams.randomVars{j,1});
    end
    
    for j=1 : size(stairParams.curStairVars, 1)
        fprintf(logFID(i), '%s\t', stairParams.curStairVars{j,1});
    end
    
    fprintf(logFID(i), '\n');
end

curStair = round(rand*(numStairs-1))+1; % Randomly select first staircase
abort = false; % Default to false so we can begin running
dataSum(1).abort = false;

% Show customized instruction sceen
eval(instructions);

% Main staircase loop
while ~all(stairHistory.done) && ~abort
    % build the trial
    adjustValue = stairParams.adjustableVarValues(...
        min(curStair,numLevelVectors), ...
        stairHistory.curAdjustIndex(curStair));
    
    %
    correctStepIndex = min(length(stairParams.correctStepSize), ...
                           stairHistory.numReversals(curStair)+1);
    incorrectStepIndex = min(length(stairParams.incorrectStepSize), ...
                             stairHistory.numReversals(curStair)+1);
    
    % Set the adjustable variable value
    stimParams.(stairParams.adjustableVarName) = adjustValue;
    
    % Set the random variable values
    randVal = zeros(length(stairParams.randomVars),1);
    for i=1:size(stairParams.randomVars, 1)
        randVal(i) = stairParams.randomVars{i,2}...
                     (ceil(rand*length(stairParams.randomVars{i,2})));
        stimParams.(stairParams.randomVars{i,1}) = randVal(i);
    end
    
    % Set the curStair variable values
    curStairVal = zeros(length(stairParams.curStairVars),1);
    for i = 1 : size(stairParams.curStairVars, 1)
        curStairVal(i) = stairParams.curStairVars{i,2}...
                     (min(curStair,length(stairParams.curStairVars{i,2})));
        stimParams.(stairParams.curStairVars{i,1}) = curStairVal(i);
    end
    
    % Randomly choose and then set the alternative variable
    altIndex = round(rand*(numAlternatives-1))+1;
    altValue = stairParams.alternativeVarValues(altIndex);
    stimParams.(stairParams.alternativeVarName) = altValue;
    
    % build the trial
    if stairParams.useGlobalData
        [trial, data] = eval(trialGenFuncName);
    else
        [trial, data{curStair}] = eval(trialGenFuncName);
    end
    
    % clear the keyboard queue
    FlushEvents('keyDown');
    % preTrialSecs = GetSecs - preTrialSecs;
    
    % run the trial
    response = doTrial(display, trial, priority, showTimingFlag);
    if stairParams.etFlag
        etData = etCheckEyes(stimParams.duration);
    end
    
    postTrialSecs = GetSecs;
    
    if isfield(stairParams, 'responseSet')
        % If we already have a keyLabel, process it into a respCode;
        if ~isempty(response.keyLabel)
            if(~isempty(strfind(lower(response.keyLabel),quitKey)))
                respCode = -1;
                abort = 1;
            elseif(iscell(stairParams.responseSet))
                respCode = find(~cellfun('isempty',...
                    strfind(stairParams.responseSet, response.keyLabel)));
            else
                respCode = strfind(stairParams.responseSet, ...
                    response.keyLabel);
            end
        else
            respCode = [];
        end
        
        if isempty(respCode) % If respCode is empty at this point, get one
            % Wait for the response
            KbQueueCreate(device,keyList);
            KbQueueStart();
            [k.pressed, k.firstPress, k.firstRelease, k.lastPress, ...
                k.lastRelease] = KbQueueWaitCheck();
            response.secs = min(k.firstPress(k.firstPress~=0));
            response.keyCode = find(k.firstPress==response.secs);
            response = getKeyLabel(response);
            
            % Process the keyCode into a respCode
            if(~isempty(strfind(lower(response.keyLabel),quitKey)))
                respCode = -1;
                abort = 1;
            elseif(iscell(stairParams.responseSet))
                respCode = find(~cellfun('isempty', ...
                    strfind(stairParams.responseSet,response.keyLabel)));
            else
                respCode = strfind(stairParams.responseSet,...
                                   response.keyLabel);
            end
        end
    end
    correct = (respCode == altIndex);
    postRespSecs = GetSecs; % changed the position of postTrialSecs
    % update dataSum with relevant trial and response information
    trialCounts = trialCounts + 1;
    curStairNumTrials   = stairHistory.numTrials(curStair) + 1;
    if ~abort
        stairHistory.numTrials(curStair) = curStairNumTrials;
        dataSum(curStair).history(curStairNumTrials) = adjustValue;
        dataSum(curStair).response(curStairNumTrials) = response.keyLabel;
        dataSum(curStair).correct(curStairNumTrials) = correct;
        dataSum(curStair).trialCounts(curStairNumTrials) = trialCounts;
        
        % Store eye tracking data
        if stairParams.etFlag
            dataSum(curStair).etData{1,curStairNumTrials} = etData.horiz;
            dataSum(curStair).etData{2,curStairNumTrials} = etData.vert;
            dataSum(curStair).etxForm{curStairNumTrials}  = ...
                                                    stairParams.et.xform;
        end
        % If using code which records the start of the trial GetSecs, then
        % compute the RT
        if isfield(response,'secsStart')
            dataSum(curStair).responseTime(curStairNumTrials) = ...
                                        response.secs - response.secsStart;
        end
        
        % If user indicates the need to save stuff out from the actual
        % trials themselves, do so with the eval function.
        if exist('saveData','var')
            for i = 1 : length(saveData)
                eval(saveData{i, 2});
            end
        end
        
        indx = find(dataSum(curStair).stimLevels == adjustValue);
        if isempty(indx)
            error('Missing stimLevel in dataSum - data maybe invalid');
        end
        dataSum(curStair).numTrials(indx) = ...
            dataSum(curStair).numTrials(indx) + 1;
        if correct
            % auditory feedback
            if ~isempty(correctSnd), sound(correctSnd); end
            dataSum(curStair).numCorrect(indx) = ...
                dataSum(curStair).numCorrect(indx) + 1;
        else
            if ~isempty(incorrectSnd), sound(incorrectSnd); end
        end
    else
        return;
    end

    % print out the log
    for i=1:length(logFID)
        fprintf(logFID(i), '%d\t%d\t%.4f\t%d\t%s\t%s\t', ...
            curStair, curStairNumTrials, adjustValue, correct, ...
            num2str(altValue),response.keyLabel);
        
        for j = 1 : length(stairParams.randomVars)
            fprintf(logFID(i), '%.4f\t',  randVal(j));
        end
        
        for j = 1 : length(stairParams.curStairVars)
            fprintf(logFID(i), '%.4f\t',  curStairVal(j));
        end
        
        fprintf(logFID(i), '\n');
    end

    % if requested, update plot on each trial. useful for debugging.
    if exist('plotEachTrialFlag', 'var')
        plotStaircase(stairParams, dataSum, 1);
    end
    
    % adjust the adjustable
    if correct
        stairHistory.numConsecCorrect(curStair) = ...
                     stairHistory.numConsecCorrect(curStair) + 1;
        stairHistory.numConsecIncorrect(curStair) = 0;
        if mod(stairHistory.numConsecCorrect(curStair), ...
                               stairParams.numCorrectForStep) == 0
            stairHistory.curAdjustIndex(curStair) = ...
                stairHistory.curAdjustIndex(curStair) ...
                + stairParams.correctStepSize(correctStepIndex);
            % check to see if this is a reversal if the current run is
            % negative (the 'incorrect' direction), then meeting the
            % numConsecCorrect criterion constitutes a reversal.
            if stairHistory.runDirection(curStair) == -1
                stairHistory.numReversals(curStair) = ...
                    stairHistory.numReversals(curStair) + 1;
                dataSum(curStair).reversalStimLevel...
                    (stairHistory.numReversals(curStair)) = adjustValue;
                stairHistory.runDirection(curStair) = +1;
            end
        end
    else
        stairHistory.numConsecIncorrect(curStair) = ...
            stairHistory.numConsecIncorrect(curStair) + 1;
        stairHistory.numConsecCorrect(curStair) = 0;
        if mod(stairHistory.numConsecIncorrect(curStair), ...
                stairParams.numIncorrectForStep) == 0
            stairHistory.curAdjustIndex(curStair) = ...
                stairHistory.curAdjustIndex(curStair) ...
                + stairParams.incorrectStepSize(incorrectStepIndex);
            % check to see if this is a reversal if the current run is
            % positive (the 'correct' direction), then meeting the
            % numConsecIncorrect criterion constitutes a reversal.
            if stairHistory.runDirection(curStair) == 1
                stairHistory.numReversals(curStair) = ...
                    stairHistory.numReversals(curStair) + 1;
                dataSum(curStair).reversalStimLevel...
                    (stairHistory.numReversals(curStair)) = adjustValue;
                stairHistory.runDirection(curStair) = -1;
            end
        end
    end
	
    % ensure adjustable isn't out of range Note that if we have gone out of
    % range, then we should (and do) count this as a reversal because it
    % means the observer has hit one of the boundaries.  If we don't do
    % something like this, the observer may get stuck at one of the bounds
    % and do many unnecessary trials there!
    curNumReversals = stairHistory.numReversals(curStair) + 1;
    if stairHistory.curAdjustIndex(curStair) > numLevels
        % count this as a reversal
        stairHistory.numReversals(curStair) = curNumReversals;
        dataSum(curStair).reversalStimLevel(curNumReversals) = adjustValue;
        
        % constrain curAdjustIndex to the bounds
        stairHistory.curAdjustIndex(curStair) = numLevels;
        
    elseif stairHistory.curAdjustIndex(curStair) < 1
        % count this as a reversal
        stairHistory.numReversals(curStair) = curNumReversals;
        dataSum(curStair).reversalStimLevel(curNumReversals) = adjustValue;
        % constrain curAdjustIndex to the bounds
        stairHistory.curAdjustIndex(curStair) = 1;
    end
    % check to see if we are done with this staircase
    if stairHistory.numTrials(curStair) >= stairParams.maxNumTrials ...
            || curNumReversals >= stairParams.maxNumReversals
        stairHistory.done(curStair) = 1;
    end

    % choose the curStair pseudorandomly, giving preference to staircases
    % that are less done.
    completeIndex = stairHistory.numTrials./stairParams.maxNumTrials - ...
                    randn(size(stairHistory.numTrials))*.2;
    curStair = find(completeIndex == min(completeIndex));
    curStair = curStair(round(rand*(length(curStair)-1))+1);

    % wait for an ITI, if needed
    postTrialSecs = GetSecs-postTrialSecs;
    postRespSecs = GetSecs-postRespSecs;
    
    % we use the previous pre-trial time as a guess for how long the next
    % pre-trial prep time will take.
    if prFlag
        interval = postRespSecs;
    else
        interval = postTrialSecs; 
    end
    
    if(~all(stairHistory.done) && ~abort && interval<stairParams.iti)
        waitTill(stairParams.iti-interval);
    end
end

if stairParams.initTrialCount==1 || stairParams.initTrialCount==0
    save(tcName,'trialCounts');
end

return;
