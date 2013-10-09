function params = colorMatchTAFCGenImage(display, params, type, varargin)
%% function colorMatchTAFCGenImage(display, params, type, [varargin])
%    This function is used to generate reference / match image that will be
%    used in color match TAFC experiment
%
%  Inputs:
%    display   - ISET display structure. This one contains a little more
%                information like bits++ control and etc.
%    params    - stimulus control parameter structure
%    type      - output image type, can be either 'ref' or 'match'
%    varargin  - not used here, might be useful in the future
%
%  Outputs:
%    params    - stimulus parameter structure with correpsonding image
%                fields set. The image can accessed by either .refImg or
%                .matchImg
%  See also:
%    colorMatchTAFCTrial, colorMatchTAFC
%
%  (HJ) Oct, 2013

%% Check inputs
if nargin < 1, error('display structure needed'); end
if nargin < 2, error('stimulus parameter structure needed'); end
if nargin < 3, type = 'ref'; end

%% Init parameters
%  Get patch size
patchWidth  = angle2pix(display, params.visualSize(2));
patchHeight = angle2pix(display, params.visualSize(1));

%  Compute stimulus size (2 patches + 1 gap)
stimWidth   = round(2*patchWidth/(1-params.gapSize)); % width in pix
stimHeight  = patchHeight; % height in pix

%  Set stimulus bgColor
params.bgColor = display.backColorRgb;
if max(params.bgColor) > 1
    params.bgColor = params.bgColor / 255; % Assume 8 bit here
    assert(all(params.bgColor>=0 & params.bgColor<=1));
end

%% Generate reference image
if ~isfield(params, 'refImage') || strcmp(type, 'ref')
    %  Generate reference patch image
    refColor = params.refColor;
    refImg   = repmat(reshape(refColor,[1 1 3]),stimHeight,stimWidth);
    
    % Compute gap size and position
    gapSize = params.gapSize;
    gapL    = floor((0.5-gapSize/2)*stimWidth);
    gapR    = floor((0.5+gapSize/2)*stimWidth);
    
    %  Set gap color
    for i = 1 : 3
        refImg(:, gapL +1:gapR,i)  = params.bgColor(i);
    end
    
    params.refImg = refImg;
end

%% Generate match image if needed
if strcmp(type, 'match')
    angle = deg2rad(params.direction);
    dir   = [cos(angle) sin(angle) 0]';
    
    % Compute match color
    refContrast    = RGB2ConeContrast(display, refColor);
    matchContrast  = refContrast + params.dContrast * dir;
    matchColor     = coneContrast2RGB(display,matchContrast);
    
    params.matchImg = refImg;
    
    % Replace either left/right patch to match color
    if rand > 0.5
        for i = 1 : 3
            params.matchImg(:,1:gapL,i)   = matchColor(i);
        end
    else
        for i = 1 : 3
            params.matchImg(:,gapR+1:end,i) = matchColor(i);
        end
    end
end

end