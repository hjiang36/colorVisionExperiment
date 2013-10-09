function display = openScreen(display, varargin)
%% function display = openScreen(display,[varargin])
%    Open PTB window under settings in display
%
%  Inputs:
%    display  - ISET compatible display structure
%    varargin - name-value pair for settings
%             - supports: hideCursorFlag, bitDepth, numBuffers, drawFix
%
%  Output:
%    display  - display structure with window pointer and rect set
%
%  General Process:
%    1. Parse input parameters
%    2. If needed, test 10 bit color support
%    3. Init screen parameters to PTB: resolution, framerate, gamma, etc.
%    4. Open a PTB screen with a background color (0.5 gray by default)
%    5. Draw fixation point & Hide cursor
%  
%  See also:
%    closeScreen, drawFixation
%
%  History:
%    ( RFD) ###, #### - Write first version
%    ( HJ ) Aug, 2013 - Clean up, comment and add 10 bit support
%

%% Check inputs
%  Check number of inputs
if nargin < 1, error('Display structure required'); end
if mod(length(varargin),2) ~= 0
    error('Parameter should be in name-value pairs');
end

%  Check fields in display structure
if ~isfield(display,'screenNumber'), display.screenNumber = 0; end
if ~isfield(display,'frameRate'), display.frameRate = 60; end
if ~isfield(display,'resolution')
    res = Screen('Resolution', display.screenNumber);
    display.resolution = [res.width res.height]; 
end

% check gamma table
if isempty(displayGet(display,'gamma table'))
	error('Gamma table not found in display structure');
end
% check background color
if ~isfield(display,'backColorRgb')
    display.backColorRgb = [0.5 0.5 0.5]';
end

%% Parse varargin
bitDepth       = 8;    % color bit depth
hideCursorFlag = true; % whether to hide mouse in experiment
numBuffers     = 2;    % number of buffers
drawFix        = true; % whether to draw fixation point

for i = 1 : 2 : length(varargin)
    switch lower(varargin{i})
        case 'hidecursorflag'
            hideCursorFlag = varargin{i+1};
        case 'bitdepth'
            bitDepth = varargin{i+1};
        case 'numbuffers'
            numBuffers = varargin{i+1};
        case 'drawfix'
            drawFix  = varargin{i+1};
    end
end

% check bitDepths, only support 8 bit and 10 bit
assert(bitDepth == 8 || bitDepth == 10,'Error: Unknown bit depth');

%% Test 10 bit support
if bitDepth == 10
    try
        AdditiveBlendingForLinearSuperpositionTutorial('Native10Bit');
    catch
        disp('10 bit not supported on this machine, use 8 bit instead');
        bitDepth = 8;
    end
end

%% Init screen parameters
% Skip flickering warning
Screen('Preference','SkipSyncTests',1);

% Save current gamma table
display.oldGamma=Screen('ReadNormalizedGammaTable', display.screenNumber);
try
    Screen('LoadNormalizedGammaTable', display.screenNumber,display.gamma);
catch ME
    warning(ME.identifier, ME.message)
    % 10 bit gamma table not supported, reduce it to 8 bit
    pGamma = display.gamma(round(linspace(1,size(display.gamma,1),256)),:);
    Screen('LoadNormalizedGammaTable', display.screenNumber,pGamma);
end;

% Set the resolution
try
    % Try to set spatial resolution, then spatial and temporal
    Screen('Resolution', display.screenNumber, ...
        display.resolution(1), display.resolution(2));
    Screen('Resolution', display.screenNumber, ...
        display.resolution(1), display.resolution(2), display.frameRate);
catch ME
    warning(ME.identifier, ME.message)
end

% Check again if resolution got set
newSettings = Screen('Resolution', display.screenNumber);
if (newSettings.width~=display.resolution(1) || ...
        newSettings.height~=display.resolution(2))
    
    % Save resolution
    display.resolution    = [newSettings.width newSettings.height];
    
    % Save framerate is applicable
    if newSettings.hz > 0
        display.frameRate     = newSettings.hz;
    end
    warning('Failed to set indicated resolution and refresh rate.');
end

%% Open PTB Screen
if bitDepth == 8 % Open screen for 8 bit
    [display.windowPtr,display.rect] = Screen('OpenWindow', ...
        display.screenNumber,display.backColorRgb, [],[], numBuffers);
else % Open screen for 10 bit
    PsychImaging('PrepareConfiguration');
	PsychImaging('AddTask', 'General', 'FloatingPoint32BitIfPossible');
    PsychImaging('AddTask', 'General', 'EnableNative10BitFrameBuffer');
    [display.windowPtr,display.rect] = PsychImaging('OpenWindow', ...
        display.screenNumber,display.backColorRgb, [],[], numBuffers);
end

%% Handle cursor and fixation
%  Draw fixation point and hide cursor if necessary
if drawFix, drawFixation(display); end
if(hideCursorFlag), HideCursor;  end

% Flip and show
Screen('Flip', display.windowPtr);

end
