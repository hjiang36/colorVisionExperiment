function [trial, status] = cbTrialColorMatch(display, stimParams, varargin)
%% [trial, data] = cbTrialColorMatch(display, stimParams)
%
%   function to generate a stimulus and a match stimulus for 
%        testing the color similarities
%
% set parameters that apply to both stimuli
% 
% (HJ) Nov, 2012 : Adopted from cocTrial

sequence            = cbTrialImageSequence(display, stimParams);
timing              = (1:length(sequence))'*stimParams.stimframe;
cmap                = display.gammaTable;
fixSeq              = ones(size(sequence));


%% make color blind stim
stimsize    = stimParams.radius;
stimWidth   = round(angle2pix(display,stimsize)); %(width in pixels)
stimHeight  = round(angle2pix(display,stimsize)); %(height in pixels)

cbColor                  = stimParams.refColor;
cbIm                     = ones([stimHeight stimWidth 3]);
cbIm(:,:,1)              = cbColor(1);
cbIm(:,:,2)              = cbColor(2);
cbIm(:,:,3)              = cbColor(3);
gapSize                  = stimParams.gapSize;
gapL                     = round((0.5-gapSize/2)*stimWidth);
gapR                     = round((0.5+gapSize/2)*stimWidth);
cbIm(:, gapL +1:gapR,:)  = display.backColorRgb(1);

if stimParams.Gsig > 0
    gFilter = fspecial('Gaussian',[10 10],stimParams.Gsig);
    cbIm    = imfilter(cbIm, gFilter, 'same', display.backColorRgb(1));
end

cbImCell{1}              = cbIm;
cbStim                   = createStimulusStruct(cbImCell,cmap,sequence,[],timing, fixSeq);
cbStim                   = cbCreateTextures(display, cbStim);

%% make matching stim
matchParams         = stimParams;
matchParams.gapL    = gapL;
matchParams.gapR    = gapR;
matchParams.bgColor = display.backColorRgb(1);
matchParams.type    = stimParams.Type;
matchParams.color   = cbColor;
matchIm             = cbSingleFrame(matchParams,cbIm);
matchStim           = createStimulusStruct(matchIm,cmap,sequence,[],timing,fixSeq);
matchStim           = cbCreateTextures(display, matchStim);
%% make blank stim
blankIm         = cbIm;
blankIm(:,:,:)  = display.backColorRgb(1);
col = fixSeq(1) +1; %fixSeq(1) keeps the pos the same as for the edge stimuli and +3 changes the color
blankStim   = createStimulusStruct(blankIm,cmap,1,[], [], col);
blankStim   = createTextures(display, blankStim);
isi.sound   = soundFreqSweep(500, 1000, .05);

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

status = 'done';

return
end