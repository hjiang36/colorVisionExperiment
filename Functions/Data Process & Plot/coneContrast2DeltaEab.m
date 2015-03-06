function deltaE = coneContrast2DeltaEab(contrast, dir, d, cbType, bgColor)
%% function coneContrast2DeltaEab(contrast, dir, d, bgColor)
%    compute deltaE value for given cone contrast at given color direction
%    in LMS space
%
%  Inputs:
%    contrast  - contrast distance defined as Euclidean distance in LMS
%                space
%    dir       - color direction in LMS space, should be a 3 element unit
%                length vector 
%    d         - ISET display structure
%    cbType    - colorblind type
%    bgColor   - background color in RGB, default [0.5 0.5 0.5]
%
%  (HJ) ISETBIO TEAM, 2015

%% Check inputs & Init
if notDefined('contrast'), error('Contrast required'); end
if notDefined('dir'), error('direction required'); end
if notDefined('d'), error('display structure required'); end
if notDefined('cbType'), cbType = 0; end
if notDefined('bgColor'), bgColor = [0.5 0.5 0.5]; end % half gray

%% Computes stimulus color
%  Compute stimulus contrast
sContrast = contrast * dir;

%  Compute background RGB values
sRGB = coneContrast2RGB(d, sContrast, bgColor);

%  Convert to XYZ
sXYZ  = sRGB(:)' * displayGet(d, 'rgb2xyz');
bgXYZ = bgColor(:)' * displayGet(d, 'rgb2xyz');

%  Convert for colorblind
sXYZ  = lms2xyz(xyz2lms(reshape(sXYZ, [1 1 3]), cbType, bgXYZ));
bgXYZ = lms2xyz(xyz2lms(reshape(bgXYZ, [1 1 3]), cbType, bgXYZ));

%% Compute deltaEab value
deltaE = deltaEab(sXYZ, bgXYZ, bgXYZ);

end