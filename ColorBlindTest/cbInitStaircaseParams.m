function [stairParams] = cbInitStaircaseParams

% name of expt
stairParams.conditionName           = {'ColorSimilarity'};

% alternative variable
stairParams.alternativeVarName      = 'MatchingSlot';

% alter values
stairParams.alternativeVarValues    = ['1' '2'];

% decision keys
stairParams.responseSet             = 'zx';

% variable that is adjusted by staircase
stairParams.adjustableVarName       = 'deltaE';

% values that deltaE can take
stairParams.adjustableVarValues     = [0.06 0.08 0.1 0.12 0.144 0.1728 0.2074 0.2488 0.2986 0.3583 0.43 0.6 0.7 0.8 0.9 1 1.2 1.3 1.44 1.51 1.66 1.74 1.85 1.9 2 2.1 2.2 2.3 2.4 2.5];
% put things in here to run the staircase separately for a given condition
%stairParams.curStairVars            = {'direction',[0 45 75 115 135 180 225 250 300 345]}; 
%stairParams.curStairVars            = {'direction',[0 180]};
stairParams.curStairVars            = {'direction',[0 30 45 75 105 120 135 150 -30 -45 -75 -105 -120 -135 -150]};

% put things here to randomly vary the value e.g. {'formDir',[0 90 180 270]}
stairParams.randomVars              = {'matchFirstOrSecond', [1 2]};  

% num right answers before stair val changes
stairParams.numCorrectForStep       = 3;

% num wrong answers before stair val changes
stairParams.numIncorrectForStep     = 1;

% limit expt in case of lack of convergence
stairParams.maxNumTrials            = 200;

% end expt after this many reversals
stairParams.maxNumReversals         = 15;

% increment size for correct answers for each successive reversal (normally
% these numbers should go down as num reversals incr)
stairParams.correctStepSize         = [-4 -3 -3 -2 -1];
stairParams.incorrectStepSize       = [4 3 3 2 1];

% auditory feedback?
stairParams.feedback                = 'auditory'; %{'none')

% display dur of stimulus on control screen
stairParams.showTiming              = false;


% intertrial interval in seconds
stairParams.iti = 0.3;

% don't udnerstand this (copied from word cocStairCase)
if(~isempty(stairParams.curStairVars))
    stairParams.adjustableVarStart = repmat(13, size(stairParams.curStairVars{2}));
else
    stairParams.adjustableVarStart = 13;
end