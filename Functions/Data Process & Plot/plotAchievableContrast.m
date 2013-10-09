function achPoints = plotAchievableContrast(display, refColor, ...
                                              bgColor, bitDepth, varargin)
%% function plotAchieveableContrast(dispaly, refColor, ...
%                                       [bgColor], [bitDepth],[varargin])
%
%    copmute and plot achievable color point near certain reference color 
%    in LM plane. This routine is used to observe the quantization effect
%    of different bit depth
%
%  Inputs:
%    display  - ISET compatible display structure
%    refColor - RGB reference color to be shown on display, if any of the 
%               three values is greater than 1, we suppose it's encoded in
%               8 bits
%    bgColor  - RGB background color used on display, by default, 0.5 gray
%               background color is used
%    bitDepth - color bit depth, by default, 8 bits per channel is used
%    varargin - name-value pair, now support
%               'Base Plot', the figure handle of the plot to be drawn on
%                            by default, a new figure is created
%               'Dot Color', color of dots to be ploted
%
%  Output:
%    achPoints - an N-by-2 matrix indicating achievable contrast in LM
%                plane
%
%  Exmaple:
%    display   = displayCreate('LCD-Apple');
%    achPoints = plotAchievablePoints(display, [0.5 0.5 0.5]);
%
%  See also:
%    RGB2ConeContrast, coneContrast2RGB
%
%  (HJ) Aug, 2013

%% Check inputs & Init
%  Check number of inputs
if nargin < 1, error('Display structure required'); end
if nargin < 2, error('Reference color RGB required'); end
if nargin < 3, bgColor  = [0.5 0.5 0.5]'; end
if nargin < 4, bitDepth = 8; end

if isempty(bgColor), bgColor = [0.5 0.5 0.5]'; end

% Check varargin
if mod(length(varargin),2) ~= 0
    error('Parameters should be in name-value pairs');
end

% Check refColor and bgColor format
refColor = refColor(:); % convert to 3-by-1
bgColor  = bgColor(:);  % convert to 3-by-1

% Convert all RGB color to 0~1
% If originally, they're not, assume they're encoded in 8 bits.
if max(refColor) > 1, refColor = refColor / 255; end
if max(bgColor ) > 1, bgColor  = bgColor  / 255; end

assert(all(refColor >= 0 & refColor <= 1 & bgColor >=0 & bgColor <= 1));

% Init parameters to be used
plotRegionL = 0.02; % plot region size for L
plotRegionM = 0.02; % plot region size for M
plotSteps   = 401;  % number of steps to be sampled in L and M

%% Parse variable inputs and Set parameters
hf = []; % handle of figure
dotsColor = [0.75 0.75 0.75]; % color of dots

for i = 1 : 2 : length(varargin)
    switch lower(strrep(varargin{i}, ' ', ''))
        case 'baseplot'
            hf = varargin{i+1};
        case 'dotcolor'
            dotsColor = varargin{i+1};
        otherwise
            warning('Unknown parameter encountered');
    end
end

%% Compute quantized RGB values
%  Compute contrast for reference point
refContrast = RGB2ConeContrast(display, refColor, bgColor);

%  Set plot region, should init the constants at front of the program
regionL = refContrast(1) + linspace(-plotRegionL, plotRegionL, plotSteps);
regionM = refContrast(2) + linspace(plotRegionM, -plotRegionM, plotSteps);
[L, M]  = meshgrid(regionL, regionM);

% Create cone contrast image
contrastImage = cat(3, L, M);
contrastImage(:,:,3) = refContrast(3);

%% Compute achievable contrast
%  Convert to XW format
contrastImage = RGB2XWFormat(contrastImage);

%  Convert to RGB space
%  Should enable coneContrast2RGB accept RGB matrix input
achievableRGB = coneContrast2RGB(display, contrastImage, bgColor);

%  Quantization
maxColor = 2^bitDepth - 1;
achievableRGB = round(achievableRGB * maxColor) / maxColor;
achievableRGB = unique(achievableRGB, 'rows');

%  Convert to cone contrast
achPoints = RGB2ConeContrast(display, achievableRGB, bgColor);

%% Plot
if isempty(hf)
    hf = figure('Name', 'Achievable Contrast', ...
               'NumberTitle', 'off');
    axis on; axis equal; grid on; hold on;
    xlabel('L Contrast'); ylabel('M Contrast');
end

set(0,'CurrentFigure', hf);    
plot(achPoints(:,1),achPoints(:,2), '.', 'Color', dotsColor); 

end
