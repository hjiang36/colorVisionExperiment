function [trial, data] = cbTrialDetection(display, stimParams, ~)
% [trial, data] = cocTrial(display, stimParams, data)
%
%   function to generate a stimulus and a match stimulus for 
%        testing the color similarities

% set parameters that apply to both stimuli
% 
% Written by HJ, 11/2012 : Adopted from cocTrial


% showProgessDots     = false; 
duration.stimframe  = stimParams.stimframe;
sequence            = cbTrialImageSequence(display, stimParams);
timing              = (1:length(sequence))'.*duration.stimframe;
cmap                = display.gammaTable;
fixSeq              = ones(size(sequence));


%% make color blind stim
stimsize    = stimParams.radius;
m           = round(angle2pix(display,stimsize)*2); %(width in pixels)
N           = round(angle2pix(display,stimsize)*2*2); %(height in pixels)

cbColor                  = [127 127 127]; % same as bg color
cbIm                     = ones([m/8 N/8 3]);
n                        = size(cbIm,2);
cbIm(:,:,1)              = cbColor(1);
cbIm(:,:,2)              = cbColor(2);
cbIm(:,:,3)              = cbColor(3);
gapSize                  = stimParams.gapSize;
gapL                     = floor((0.5-gapSize/2)*n);
gapR                     = floor((0.5+gapSize/2)*n);
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
isi.sound = soundFreqSweep(500, 1000, .05);


%% Build the trial events

trial = addTrialEvent(display,[],'soundEvent',isi );
trial = addTrialEvent(display,trial,'stimulusEvent', 'stimulus', matchStim);
trial = addTrialEvent(display,trial,'ISIEvent', 'stimulus', blankStim, 'duration', 0.01);

data = 'done';

return
end