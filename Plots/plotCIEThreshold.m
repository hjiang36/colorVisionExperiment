function [deltaEImage, whiteXYZ] = plotCIEThreshold(display, refColor, ...
                                        bgColor, whiteXYZ, varargin)
%% function plotCIEThreshold(display, refColor, [bgColor], [whitePointXYZ])
%    plot CIE theoretical threshold in LM contrast plane for reference
%    color point. We might add funtionalities to enable it to plot in other
%    color space in the future.
%
%  Inputs:
%    display     - ISET compatible display structure
%    refColor    - reference RGB color to be shown on display
%    bgColor     - background RGB color of display, default .5 gray
%    whiteXYZ    - white point XYZ value, default 5 times of background
%                  XYZ value
%    varargin    - Name-value pair for parameters, now supports
%                  'Base Plot', the figure handle of plot to be drawn onto
%                               by default, a new figure is created
%                  'Colormap' , colormap to be used in the plot
%                  'Contour'  , plot contours for certain deltaE ellipse,
%                               the values for contour can be a vector of
%                               deltaE values to be ploted
%                  'Alpha'    , scalar, indicating transparency of plot
%
%  Output:
%    deltaEImage - a matrix that contains deltaE for each point of cone
%                  contrast
%    whiteXYZ    - white point XYZ, this one is here because we might fit
%                  white point XYZ to data in the future
%
%  Example:
%    display = displayCreate('LCD-Apple');
%    plotCIEThreshold(display, [0.5 0.5 0.5]);
%
%  See also:
%    lms2xyz (IsetBio), xyz2lms (IsetBio), deltaEab (ISET)
%    plotBrettelThreshold
%
%  (HJ) Aug, 2013

%% Check inputs
%  Check number of inputs
if nargin < 1, error('Display structure required'); end
if nargin < 2, error('Reference color RGB required'); end
if nargin < 3 || isempty(bgColor), bgColor  = [0.5 0.5 0.5]'; end
if nargin < 4 || isempty(whiteXYZ)
    whiteXYZ = displayGet(display, 'white xyz')*2.5;
end

% Check length of varargin
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

%% Parse variable input and Init parameters
% Init constant parameters
plotRegionL = 0.02; % plot region size for L
plotRegionM = 0.02; % plot region size for M
plotSteps  = 1000;  % number of steps to be sampled in L and M

% Parse variable input
hf             = [];        % Create new plot
cmap           = 'default'; % default color map
deltaEContourV = [];        % Plot whole image
transparency   = 0.8;       % Transparency of plot

for i = 1 : 2 : length(varargin)
    switch lower(strrep(varargin{i}, ' ', ''))
        case 'baseplot'
            hf = varargin{i+1};
        case 'colormap'
            cmap = varargin{i+1};
        case 'contour'
            deltaEContourV = varargin{i+1};
        case 'alpha'
            if ~isscalar(varargin{i+1})
                error('Alpha should be scalar'); 
            end
            transparency = varargin{i+1};
        otherwise
            warning('Unknown parameter encountered');
    end
end

%% Compute deltaE values
%  Compute reference color contrast
[refContrast, bgLMS]  = RGB2ConeContrast(display, refColor, bgColor);
refLMS = (refContrast + 1) .* bgLMS;

%  Set plot region
regionL = refContrast(1) + linspace(plotRegionL, -plotRegionL, plotSteps);
regionM = refContrast(2) + linspace(plotRegionM, -plotRegionM, plotSteps);
[L, M]  = meshgrid(regionL, regionM);

% Create reference XYZ image
refXYZ  = lms2xyz(reshape(refLMS,[1 1 3]));
refXYZImage = repmat(refXYZ, [size(L, 1) size(L, 2)]);

% Create cone contrast image
contrastImage = cat(3, L, M);
contrastImage(:,:,3) = refContrast(3);

% Compute corresponding XYZ image
bgLMSImage   = repmat(reshape(bgLMS,[1 1 3]),[size(contrastImage,1) ...
                            size(contrastImage,2)]);
stimLMSImage = (contrastImage + 1) .* bgLMSImage;
stimXYZImage = lms2xyz(stimLMSImage);

% Compute deltaE value
deltaEImage  = deltaEab(refXYZImage, stimXYZImage, whiteXYZ);

% Generate contour image
contourImage = deltaEImage2Contour(deltaEImage, deltaEContourV);

%% Plot
%  create figure
if isempty(hf)
    hf = figure('Name', 'CIELab Threshold', ...
               'NumberTitle', 'off');
    grid off; hold on; 
    xlim([min(regionL) max(regionL)]); ylim([min(regionM) max(regionM)]);
    xlabel('L Contrast'); ylabel('M Contrast'); 
    
end
set(0,'CurrentFigure', hf);


%  plot deltaE image
colormap(cmap);
hI = imagesc(regionL, regionM, contourImage);
set(gca, 'ydir', 'normal'); % Ensure that origin is at lower left corner
uistack(hI, 'bottom');
alpha(hI, transparency);

end