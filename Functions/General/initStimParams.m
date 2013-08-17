function stimParams = initStimParams(display)
% initialize stimulus parameters

% type of color blind to measure
stimParams.Type = 'normal'; % {'protanopia', 'deuteranopia', 'tritanopia','normal'}

% initial value of modified Delta E (this will be reset during expt)
stimParams.deltaE = 4;

% initial value of random match (will be controlled by staircase)
stimParams.matchFirstOrSecond = 1; % {1,2}

% size of stimulus (can't be bigger than the display)
stimParams.radius = min(24, display.radius); %(deg)

% position of fixation cross
stimParams.fixationEcc = 3; %(deg)

% initial val for fixation side (-1, 0, 1 = L, Center, R)
stimParams.fixationSide = 1;

% degree to which edge curves (curvature is important for scan expt)
stimParams.curvatureAmp = 10; %(deg)

% number of refreshes to show each identical image
framesPerImage = 1;

% duration of a stimulus frame in seconds
stimParams.stimframe = framesPerImage / display.frameRate;

% duration of stimulus presentation
stimParams.duration = 1; % seconds

% temporal frequency of stimuli
stimParams.frequency  = 1; %Hz

% isi
stimParams.isi = 1; % seconds

% Alter
stimParams.alterV = 1;

stimParams.gapSize = 1/8;

% Spacial Blur
stimParams.Gsig = 5;

% Save Spectra and wavelength information
stimParams.spectra = display.spectra;
stimParams.wavelength = display.wavelength;

return