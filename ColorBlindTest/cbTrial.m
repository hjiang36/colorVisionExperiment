function [trial, data] = cbTrial(display, stimParams, varargin)
% [trial, data] = cocTrial(display, stimParams, data)
%
%   function to generate a stimulus and a match stimulus for 
%        testing the color similarities

% set parameters that apply to both stimuli
% MORE COMMENT NEEDED HERE
% 
% Written by HJ, 11/2012 : Adopted from cocTrial

sequence            = cbTrialImageSequence(display, stimParams);
timing              = (1:length(sequence))'.*stimParams.stimframe;
cmap                = display.gammaTable;
fixSeq              = ones(size(sequence));


%% make color blind stim
stimsize    = stimParams.radius;
m           = round(angle2pix(display,stimsize)*2); %(width in pixels)
N           = round(angle2pix(display,stimsize)*2*2); %(height in pixels)

cbColor                  = [127 127 127];
refIm                    = ones([m/6 N/6 3]);
n                        = size(refIm,2);
refIm(:,:,1)             = cbColor(1);
refIm(:,:,2)             = cbColor(2);
refIm(:,:,3)             = cbColor(3); % Should make this simple
gapSize                  = stimParams.gapSize;
gapL                     = floor((0.5-gapSize/2)*n);
gapR                     = floor((0.5+gapSize/2)*n);
refIm(:, gapL +1:gapR,:)  = display.backColorRgb(1);

if stimParams.Gsig > 0
    gFilter = fspecial('Gaussian',[10 10],stimParams.Gsig);
    refIm    = imfilter(refIm, gFilter, 'same', display.backColorRgb(1));
end

cbImCell{1} = refIm;
cbStim = createStimulusStruct(cbImCell,cmap,sequence,[],timing, fixSeq);
cbStim = createTextures(display, cbStim);

%% make matching stim
matchParams         = stimParams;
matchParams.gapL    = gapL;
matchParams.gapR    = gapR;
matchParams.bgColor = display.backColorRgb(1);
matchParams.type    = stimParams.Type;
matchParams.color   = cbColor;
matchIm             = cbSingleFrame(matchParams,refIm);
matchStim           = createStimulusStruct(matchIm,cmap,sequence,[],timing,fixSeq);
matchStim           = createTextures(display, matchStim);

%% make blank stim
blankIm         = refIm;
blankIm(:,:,:)  = display.backColorRgb(1);
col = fixSeq(1) +1;
blankStim = createStimulusStruct(blankIm,cmap,1,[], [], col);
blankStim = createTextures(display, blankStim);
isi.sound = soundFreqSweep(500, 1000, .05);

if stimParams.MatchingSlot == '2'
    first   = cbStim;
    second  = matchStim;
else
    first   = matchStim;
    second  = cbStim;
end


%% Build the trial events 

trial = addTrialEvent(display,[],'soundEvent',isi );
trial = addTrialEvent(display,trial,'stimulusEvent', 'stimulus', first);
trial = addTrialEvent(display,trial,'ISIEvent', 'stimulus', blankStim, 'duration', stimParams.isi);
trial = addTrialEvent(display,trial,'soundEvent',isi );
trial = addTrialEvent(display,trial,'stimulusEvent', 'stimulus', second);
trial = addTrialEvent(display,trial,'ISIEvent', 'stimulus', blankStim, 'duration', 0.01);

data = 'done';

end