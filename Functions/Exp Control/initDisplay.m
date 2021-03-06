function display = initDisplay(dispName)
%% function display = initDisplay([dispName])
%    Init display structure for experiment
%
%  Input:
%    dispName - display calibration file name
%
%  Output:
%    display  - display structure, can be used for displayGet, etc.
%             - return [], if get cancelled by user in the middle
%
%  Example:
%    disp = initDisplay('OLED-SonyBVM');
%
%  Note:
%    Only two types of calibration file supported:
%    - cals version, generated by PTB calibration routine
%    - d version, with display structure inside
%
% (HJ) Aug, 2013

%% Check inputs
if nargin < 1, dispName = []; end

%% Load parameter from calibration structure
if isempty(dispName)
    dispName = input('Display Calibration File Name:');
end

c = load(dispName);
if isfield(c,'d')
    display = displayCreate(dispName);
elseif isfield(c,'cals')
    display   = loadDisplayParams(dispName);
else
    error('Unknown display structure');
end

% Convert PTB version to one

%% Set experiment parameters
display.screenNumber = max(Screen('Screens'));
if ~isfield(display, 'numPixels')
    screenRes = Screen('Resolution', display.screenNumber);
    display.numPixels = [screenRes.width screenRes.height];
end
display.radius = pix2angle(display,floor(min(display.numPixels)/2));
display.backColorRgb = [0.5 0.5 0.5]'; % set it to gray