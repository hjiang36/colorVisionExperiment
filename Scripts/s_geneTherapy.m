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

imgName = 'hats.jpg'; % image to be used
d = displayCreate('LCD-Apple'); % calibrated display structure

cbType = 2; % colorblind type

%% Compute Image for Dichromatic Observers



%% Compute Image for Dichromatic Observers with Gene Therapy
%  linearize display Gamma
d = displaySet(d, 'gamma', repmat(linspace(0, 1, 256)', [1 3]));

%  Compute radiance (scene)
scene = sceneFromFile(imgName, 'rgb', [], d);

%  Compute irradiance (optical image)
oi = oiCreate('wvf human');
oi = oiCompute(scene, oi);

%  Create Human Cone Mosaic for Dichromatic Observers
switch cbType
    case 0, params.humanConeDensities = [0 .6 .3 .1]; % trichromats
    case 1, params.humanConeDensities = [0  0 .9 .1]; % proteranopia
    case 2, params.humanConeDensities = [0 .9  0 .1]; % deuteranopia
    case 3, params.humanConeDensities = [0 .7 .3  0]; % tritanopia
end

sensor = sensorCreate('human', [], params);
sensor = sensorSetSizeToFOV(sensor, sceneGet(scene, 'h fov'), scene, oi);

sensor = sensorCompute(sensor, oi);