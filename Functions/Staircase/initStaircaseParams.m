function stairParams = initStaircaseParams(varargin)
%% function stairParams = initStaircaseParams([varargin])
%    initialize staircase parameters
%
%  Input:
%    varargin   - name value pair
%  
%  Output:
%    stairParams - staircase parameter structure
%
%  Example:
%    stairParams = initStaircaseParams('experimentName','colorMatching')
%
%  (HJ) Aug, 2013

%% Check input
if mod(length(varargin),2)~=0
    error('Inputs should be in name-value pairs');
end

%% Initialize default values
%  Name of experiment
stairParams.experimentName          = {'Color Vision Experiment'};

% Alternative variable
stairParams.alternativeVarName      = 'MatchingSlot';
stairParams.alternativeVarValues    = ['1' '2'];

% Decision keys
stairParams.responseSet             = 'zx';

% Parameter for each staircase separately
stairParams.curStairVars            = {'direction',...
    [0 30 45 75 105 120 135 150 -30 -45 -75 -105 -120 -135 -150]};

% Variable adjusted by staircase
stairParams.adjustableVarName       = 'dContrast';
stairParams.adjustableVarValues     = 0.05:0.05:2;

% Set starting value, use 13 here
stairParams.adjustableVarStart      = ...
            repmat(13, size(stairParams.curStairVars{2}));


% Randomly vary the value
stairParams.randomVars              = {'matchFirstOrSecond', [1 2]};  

% num answers before stair val changes
stairParams.numCorrectForStep       = 3;
stairParams.numIncorrectForStep     = 1;

% limit experiment in case of lack of convergence
stairParams.maxNumTrials            = 200;

% end expt after this many reversals
stairParams.maxNumReversals         = 15;

% increment size for each successive reversal 
stairParams.correctStepSize         = [-4 -3 -3 -2 -1];
stairParams.incorrectStepSize       = [4 3 3 2 1];

% auditory feedback
stairParams.feedback                = 'auditory'; %{'none')

% display dur of stimulus on control screen
stairParams.showTiming              = false;

% intertrial interval in seconds
stairParams.iti      = 0.1;

%% Parse varargin and set to stairParams
for i = 1 : 2 : length(varargin)
    stairParams.(varargin{i}) = varargin{i+1};
end

%% END
