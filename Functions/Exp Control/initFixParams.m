function display = initFixParams(display, fov, varargin)
%% function display = initFixParams(display, fov, [varargin])
%    Initialize display fixation point parameters
%
%  Inputs:
%    display  - ISET compatible display structure
%    fov      - Fixation point size in degrees
%    varargin - Name-value pair for fixation parameters
%             - Acceptable name: 'Position','fixType', 'fixColor'
%
%  Outputs:
%    display - display structure with fixation point information set
%
%  Example:
%    display = initDisplay('OLED-SonyBVM.mat');
%    display = initFixParams(display, 1);
%
%  See also:
%    initDisplay
%
%  (HJ) Aug, 2013

%% Check inputs
if nargin < 1, error('Display structure required'); end
if nargin < 2, error('Size of fixation point required (in degree)'); end
if mod(length(varargin),2)~=0, error('Parameters should be in pairs'); end

%% Init fixation by default value
display.fixType        = 'dot';
display.fixSizePixels  = 2;
display.fixColorRgb    = [0 0 0]';
                      
dim.x                  = display.numPixels(1);
dim.y                  = display.numPixels(2);
ecc                    = angle2pix(display, fov);

display.fixStim        = round([0 -1 1] * ecc + dim.x/2); 
display.fixPosY        = round(dim.y/2);

% fixPosX is divided by two is just for bits++ color++ mode
display.fixPosX        = round(dim.x/2)/2;

%% Set Parameter by varargin
for i = 1 : 2 : length(varargin)
    switch lower(varargin{i})
        case 'position'
            pos = varargin{i+1};
            display.fixPosY = round(pos(2)/2);
            display.fixPosX = round(pos(1)/2);
        case 'fixtype'
            display.fixType = varargin{i+1};
        case 'fixcolor'
            display.fixColorRgb = varargin{i+1};
        otherwise
            warning(['Unknown parameter ' varargin{i} ', ignored']);
    end
end

%% END