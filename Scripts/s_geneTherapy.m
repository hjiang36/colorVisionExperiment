%% s_geneTherapy
%    This script simulate the consequence of gene therapy that helps
%    dichromatic observers generate their missing cone type.
%
%    This script assumes that gene therapy only affects the cone mosaic and
%    has no effect to the rest of the nerve system
%
%  (HJ) ISETBIO TEAM, 2015

%% Init Parameters
ieInit; % initialize a new ISETBIO session

imgName  = 'hats.jpg'; % image to be used
img_rgb  = im2double(imread(imgName));
img_size = [size(img_rgb, 1) size(img_rgb, 2)];

d = displayCreate('LCD-Apple'); % calibrated display structure
cbNames = {'Protanopia', 'Deuteranopia', 'Tritanopia'};

%% Compute Image for Dichromatic Observers with Brettel's Algorithm
%  convert rgb image to XYZ
rgb2xyz = displayGet(d, 'rgb2xyz');
img_xyz = imageLinearTransform(img_rgb, rgb2xyz);

% show original image
img_srgb = xyz2srgb(img_xyz);
vcNewGraphWin;
subplot(2, 4, 1); imshow(img_srgb);
title('Trichromats');

% set white point as an equal energy light
wave = 400 : 10 : 700;
energy = 0.002 * ones(length(wave), 1);
wp = ieXYZFromEnergy(energy', wave);

% compute and show colorblind image
img_srgb_cb = cell(3, 1);
for cbType = 1 : 3
    % convert to LMS
    img_lms = xyz2lms(img_xyz, cbType, 'Brettel', wp);

    % convert back to srgb
    img_srgb_cb{cbType} = lms2srgb(img_lms);
    
    % show image
    subplot(2, 4, cbType + 1); imshow(img_srgb_cb{cbType});
    title([cbNames{cbType} ' (Brettel)']);
end

%% Compute Image for Dichromatic Observers with Linear Method
%  compute LMS image for trichromats
img_lms_T = xyz2lms(img_xyz);

%  compute for protanopia
img_lms_GT = img_lms_T;
img_lms_GT(:,:,1) = 1.3855 * img_lms_GT(:,:,2) - 0.285 * img_lms_GT(:,:,3);
img_rgb_GT_P = lms2srgb(img_lms_GT);

% show image
subplot(2, 4, 6); imshow(img_rgb_GT_P);
title('Protanopia (Linear)');

%  compute for deuteranopia
img_lms_GT = img_lms_T;
img_lms_GT(:,:,2) = 0.6949 * img_lms_GT(:,:,1)+0.2614 * img_lms_GT(:,:,3);
img_rgb_GT_D = lms2srgb(img_lms_GT);

% show image
subplot(2, 4, 7); imshow(img_rgb_GT_D);
title('Deuteranopia (Linear)');

%  compute for tritanopia
img_lms_GT = img_lms_T;
img_lms_GT(:,:,3) = -0.9623 * img_lms_GT(:,:,1)+1.7595*img_lms_GT(:,:,2);
img_rgb_GT_T = lms2srgb(img_lms_GT);

% show image
subplot(2, 4, 8); imshow(img_rgb_GT_T);
title('Tritanopia (Linear)');

%% Compare Brettel and Linear Methods
vcNewGraphWin;
subplot(1,3,1); plot(img_srgb_cb{1}(:), img_rgb_GT_P(:), '.r');
xlabel('Brettel Protan'); ylabel('Linear Protan'); grid on;

subplot(1,3,2); plot(img_srgb_cb{2}(:), img_rgb_GT_D(:), '.g');
xlabel('Brettel Deutan'); ylabel('Linear Deutan'); grid on;

subplot(1,3,3); plot(img_srgb_cb{3}(:), img_rgb_GT_T(:), '.b');
xlabel('Brettel Tritan'); ylabel('Linear Tritan'); grid on;

%% Compute Image for Protanopia Observers with Gene Therapy
%  Show the original and colorblind transformed image again
vcNewGraphWin;
subplot(2, 4, 1); imshow(img_srgb); title('Trichromats');
subplot(2, 4, 2); imshow(img_rgb_GT_P); title('Proteranopia');
subplot(2, 4, 3); imshow(img_rgb_GT_D); title('Deuteranopia');
subplot(2, 4, 4); imshow(img_rgb_GT_T); title('Tritanopia');

%  compute for protanopia with gene therapy
%  set mutated cone density
md = 2/3; % two thirds of M cones are mutated to be L cones
indx = rand(img_size) < md; % randomly select mutated positions

% simulate the effect for gene therapy
img_lms_GT = img_lms_T;
M = img_lms_GT(:,:,2); L = img_lms_GT(:,:,1);
M(indx) = L(indx); img_lms_GT(:,:,2) = M;

% compute rgb image
img_lms_GT(:,:,1) = 1.3855 * img_lms_GT(:,:,2) - 0.285 * img_lms_GT(:,:,3);
img_rgb_GT = lms2srgb(img_lms_GT);

% show image 
subplot(2, 4, 6); imshow(img_rgb_GT);
title('Protanope with Gene Therapy');

%% Compute Image for Deuteranopia Observers with Gene Therapy
%  compute LMS image for trichromats
img_lms_T = xyz2lms(img_xyz);

% compute for protanopia with gene therapy
% set mutated cone density
md = 1/3; % one third of L cones are mutated to be M cones
indx = rand(img_size) < md; % randomly select mutated positions

% simulate the effect for gene therapy
img_lms_GT = img_lms_T;
M = img_lms_GT(:,:,2); L = img_lms_GT(:,:,1);
L(indx) = M(indx); img_lms_GT(:,:,1) = L;

% compute rgb image
img_lms_GT(:,:,2) = 0.6949 * img_lms_GT(:,:,1)+0.2614 * img_lms_GT(:,:,3);
img_rgb_GT = lms2srgb(img_lms_GT);

% show image 
subplot(2, 4, 7); imshow(img_rgb_GT);
title('Deuteranope with Gene Therapy');

%% Compute Image for Tritanopia Observers with Gene Therapy
%  compute LMS image for trichromats
img_lms_T = xyz2lms(img_xyz);

% compute for protanopia with gene therapy
% set mutated cone density
md = 1/7; % two thirds of M cones are mutated to be L cones
indx = rand(img_size) < md; % randomly select mutated positions

% simulate the effect for gene therapy
img_lms_GT = img_lms_T;
S = img_lms_GT(:,:,3); L = img_lms_GT(:,:,1);
L(indx) = S(indx); img_lms_GT(:,:,1) = L;

% compute rgb image
img_lms_GT(:,:,3) = -0.9623 * img_lms_GT(:,:,1)+1.7595*img_lms_GT(:,:,2);
img_rgb_GT = lms2srgb(img_lms_GT);

% show image 
subplot(2, 4, 8); imshow(img_rgb_GT);
title('Tritanopia with Gene Therapy');