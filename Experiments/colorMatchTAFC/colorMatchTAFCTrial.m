function [trial, stat] = colorMatchTAFCTrial(display, stimParams, varargin)
%% function colorMatchTAFCTrial(display, stimParams, [varargin])
%    This is the function to generate a stimulus and a match stimulus for
%    testing the color similarities and set parameters that apply to both
%    stimuli
%
%  Inputs:
%    display    - ISET display structure, see displayCreate for more
%                 information. Also, there's some more information about
%                 experiment display (use bits++ box) is contained
%    stimParams - stimulus parameters structure, contains information about
%                 reference and match stimulus
%    varagin    - not used here, to keep it here to be compatible with old
%                 doTrial function which might pass a 'data' field in as
%                 the third parameter
%
%  Outputs:
%    trial      - stairacse trial structure
%    stat       - status of building trial, generally just return 'done' to
%                 be compatible with old doTrial code
%
%  See also:
%    colorMatchTAFC, doStaircase, doTrial
%
%  History:
%    (HJ) Nov, 2012 : Adopted from cocTrial
%    (HJ) Oct, 2013 : add LMS space accurate color control, clean up code
%                     and make it more compatible with current code
%

%% Check inputs
if nargin < 1, error('Display structure required'); end
if nargin < 2, error('Stimulus parameter structure required'); end

%% Init parameters
cmap  = displayGet(display,'gamma table');

if ~isfield(stimParams, 'duration')
    stimParams.duration = 0.5; % Default to .5 seconds
end

%% Make reference and match patch image
stimParams = colorMatchTAFCGenImage(display, stimParams, 'ref');
stimParams = colorMatchTAFCGenImage(display, stimParams, 'match');

refImg   = stimParams.refImg;
matchImg = stimParams.matchImg;

%  Blur if needed
if stimParams.Gsig > 0
    gFilter  = fspecial('Gaussian',[10 10],params.Gsig);
    refImg   = imfilter(refImg, gFilter, 'same', stimParams.bgColor(1));
    matchImg = imfilter(matchImg, gFilter, 'same', stimParams.bgColor(1));
end

%% Create stimulus
%  Create reference stimulus
refStim = createStimulusStruct(refImg,cmap,[],stimParams.duration);
refStim = createTextures(display, refStim);
%disp(['Ref Color:' num2str(unique(refImg(:,:,1))')]);

%  Create match stimulus
matchStim = createStimulusStruct(matchImg,cmap,[],stimParams.duration);
matchStim = createTextures(display, matchStim);

%disp(['Match Color:' num2str(unique(matchImg(:,:,1))')]);

%% Create blank stim
blankIm         = refImg;
for i = 1 : 3
    blankIm(:,:,i)  = display.backColorRgb(i).^(1/2.1);
end

blankStim = createStimulusStruct(blankIm, cmap);
blankStim = createTextures(display, blankStim);
isi.sound = soundFreqSweep(500, 1000, .05);

%% Randomize
if stimParams.MatchingSlot == '2'
    first   = refStim;
    second  = matchStim;
else
    first   = matchStim;
    second  = refStim;
end


%% Build the trial events 
trial = addTrialEvent(display,[],'soundEvent',isi );
trial = addTrialEvent(display,trial,'stimulusEvent', 'stimulus', first);
trial = addTrialEvent(display,trial,'ISIEvent', 'stimulus', blankStim, ...
                                               'duration', stimParams.isi);
trial = addTrialEvent(display,trial,'soundEvent',isi );
trial = addTrialEvent(display,trial,'stimulusEvent', 'stimulus', second);
trial = addTrialEvent(display,trial,'ISIEvent', 'stimulus', blankStim, ...
                                                'duration', 0.01);

stat = 'done';

end