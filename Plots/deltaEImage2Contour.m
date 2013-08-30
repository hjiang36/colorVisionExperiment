function contourImage = deltaEImage2Contour(deltaEImage, contourV)
%% function deltaEImage2Contour(deltaEImage, [contourV])
%    find contours of ellipses in an deltaE image, deltaE image can be
%    CIE theoretical deltaE image or brettel theoretical colorblind deltaE
%    image
%
%  Inputs:
%    deltaEImage  - M-by-N matrix, indicating deltaE value for every given
%                   color point in LM plain
%
%    contourV     - value of contours to be plotted, default is empty
%
%  Output:
%    contourImage - M-by-N matrix, containing the countour image
%
%  Example:
%    contourImage = deltaE2contour(deltaEImage, [0.5 1 2 3])
%
%  See also:
%    plotCIEThreshold, plotBrettelThreshold
%
%  (HJ) Aug, 2013

%% Check inputs
if nargin < 1, error('deltaE image is required'); end
if nargin < 2, contourV = []; end
if ~ismatrix(deltaEImage), error('deltaE image should be a 2D matrix'); end

if isempty(contourV), contourImage = deltaEImage; return; end
contourV = contourV(:); % Transform to column vector

%% Compute bw image for countour values
%  Init bw image
[M, N] = size(deltaEImage);
contourBWImage = zeros(M, N);

for i = 1 : length(contourV)
    curContourImage = deltaEImage;
    indx = curContourImage <  contourV(i);
    curContourImage(indx) = 1; % Mark region
    curContourImage(~indx) = 0; % convert to bw
    curContourImage(imerode(curContourImage,strel('disk',4))>0) = 0; %# mask all but the border % find border
    contourBWImage = contourBWImage | curContourImage;
end

% Set contourImage
contourImage = ones(M,N);
contourImage(contourBWImage) = deltaEImage(contourBWImage);

end