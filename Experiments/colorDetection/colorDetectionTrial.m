function [trial, stat] = colorDetectionTrial(display, stimParams, varargin)
%% function [trial, status] = cbTrial(display, stimParams)
%    function to generate a stimulus for color detection experiment
% 
%  Inputs:
%    display    - display structure initialized by initDisplay
%    stimParams - stimulus parameters structure generated by initSimParams
%    varargin   - not used here, just to be compatible with older versions
%
%  Outputs:
%    trial      - generated staircase trial
%    status     - completion status
%  
%  See also:
%    initDisplay, initStimParams, doTrial
%
%  History:
%    (HJ) Dec, 2012 : Adopted from cocTrial
%    (HJ) Aug, 2013 : Clean up, commented and increase robustness

%% Check inputs
if nargin < 1, error('Display structure required'); end
if nargin < 2, error('Stimulus parameter structure required'); end

%% Init parameters
cmap  = displayGet(display,'gamma table');
angle = deg2rad(stimParams.direction);
dir   = [cos(angle) 0 sin(angle)]';

if ~isfield(stimParams, 'duration')
    stimParams.duration = 0.5; % Default to .5 seconds
end

%% Make stimulus image with gap & reference color
%  Compute size for one patch
patchWidth  = angle2pix(display, stimParams.visualSize(2));
patchHeight = angle2pix(display, stimParams.visualSize(1));

%  Compute stimulus size (2 patches + 1 gap)
stimWidth   = round(2*patchWidth/(1-stimParams.gapSize)); % width in pix
stimHeight  = patchHeight; % height in pix

%  Set stimulus bgColor
stimParams.bgColor = display.backColorRgb;
if max(stimParams.bgColor) > 1
    stimParams.bgColor = stimParams.bgColor / 255; % Assume 8 bit here
    assert(all(stimParams.bgColor>=0 & stimParams.bgColor<=1)); 
end

%  Init reference image
refColor  = stimParams.refColor;
stimImg   = repmat(reshape(refColor,[1 1 3]),stimHeight,stimWidth);

%  Compute gap position
gapSize = stimParams.gapSize;
gapL    = floor((0.5-gapSize/2)*stimHeight);
gapR    = floor((0.5+gapSize/2)*stimHeight);

%  Set gap color
for i = 1 : 3
    stimImg(gapL +1:gapR, :,i)  = stimParams.bgColor(i);
end

%% Make match stimulus
%  Compute match color
refContrast    = RGB2ConeContrast(display, refColor);
matchContrast  = refContrast + stimParams.dContrast * dir;
[matchColor, bgLMS] = coneContrast2RGB(display,matchContrast);

% cbType = 1;
% matchLMS = (matchContrast + 1) .* bgLMS;
% matchColorLMS = brettelColorTransform(reshape(matchLMS, [1 1 3]), cbType, bgLMS);
% matchColor = coneContrast2RGB(display, matchColorLMS(:)./bgLMS -1);
% matchColor = matchColor(:);

%  Set color to corresponding positions in stimIm
if stimParams.MatchingSlot == '1' % Set to up
    stimImg(1:gapL,:,1)   = matchColor(1);
    stimImg(1:gapL,:,2)   = matchColor(2);
    stimImg(1:gapL,:,3)   = matchColor(3);
else % Set to down
    stimImg(gapR+1:end,:,1) = matchColor(1);
    stimImg(gapR+1:end,:,2) = matchColor(2);
    stimImg(gapR+1:end,:,3) = matchColor(3);
end

%%  Blur stimulus if needed
if stimParams.Gsig > 0
    gFilter = fspecial('Gaussian',[10 10],stimParams.Gsig);
    stimImg = imfilter(stimImg, gFilter,'same', 0.5); % should update 0.5 to something
end

%%  Create trial stimulus structure
if ~isfield(stimParams, 'duration')
    stimParams.duration = [];
end

stimulus = createStimulusStruct(stimImg.^(1/2.3),cmap,[],stimParams.duration);

% Create textures
stimulus = createTextures(display, stimulus);

%% Make blank stimulus
blankIm   = repmat(reshape(stimParams.bgColor,[1 1 3]),...
                   stimHeight,stimWidth).^(1/2.3);
blankStim = createStimulusStruct(blankIm,cmap);
blankStim = createTextures(display, blankStim);


isi.sound = soundFreqSweep(500, 1000, .05);


%% Build the trial events
trial = addTrialEvent(display,[],'soundEvent',isi );
trial = addTrialEvent(display,trial,'stimulusEvent', 'stimulus', stimulus);
trial = addTrialEvent(display,trial,'ISIEvent', 'stimulus', blankStim,...
                                    'duration', 0.1);

stat = 'done';
end