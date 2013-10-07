function stimulus = createTextures(display, stimulus, removeImages)
%stimulus = createTextures(display, stimulus, [removeImages=1]);
%
%Replace images within stimulus (stimulus.image) with textures
%(stimulus.textures).
%
%Stimulus can be a 1xn array of stimuli.  It creates the textures
%(like loading in off-screen memory in OS9).
% If the removeImages flag is set to 1 [default value], the code
% destroys the original image field (freeing up the memory and speeding up
% pass-by-copy calls of stimulus). For stimuli with many images, this is
% strongly recommended; however, for a small number of images, the field
% may not slow things too much; setting the flag to 0 keeps the images.

% MORE COMMENTS TO BE ADDED HERE

%2005/06/09   SOD: ported from createImagePointers
%2005/10/31   FWC: changed display.screenNumber into display.windowPtr

if notDefined('removeImages'),      removeImages = 1;       end
if ~isfield(display, 'USE_BITSPLUSPLUS')
    display.USE_BITSPLUSPLUS = false;
end

for stimNum = 1:length(stimulus)

	% if stored as cell?!
	% maybe everything should be cell based and not based on the 3 image
	% dimension - this would allow easy support for rgb images
	if iscell(stimulus(stimNum).images),
		stimulus(stimNum).images = cell2mat(stimulus(stimNum).images);
	end;

	% number of images
	nImages = size(stimulus(stimNum).images,4); % Should check image dimension

	% make Rects
	stimulus(stimNum).srcRect = [0,0,size(stimulus(stimNum).images, 2), ...
		size(stimulus(stimNum).images, 1)];
	if ~isfield(display,'destRect'),
		stimulus(stimNum).destRect = CenterRect(stimulus(stimNum).srcRect, display.rect);
	else
		stimulus(stimNum).destRect = CenterRect(display.destRect, display.rect);
	end;
	% clean up nicely if any of the textures are not null.
	if isfield(stimulus(stimNum), 'textures'),
		nonNull = find(stimulus(stimNum).textures);
		for i=1:length(nonNull),
			% run this from eval to suppress any errors that might ensue if
			% the texture isn't valid converted eval to try, as two
			% argument use of eval is now deprecated (jw)
            try
                Screen(stimulus(stimNum).textures(nonNull(i)), 'Close');
            catch
            end
		end;
	end;
	stimulus(stimNum).textures = zeros(nImages, 1);
    
	% Make textures
	for imgNum = 1 : nImages
        stimulus(stimNum).textures(imgNum) = ...
			Screen('MakeTexture',display.windowPtr, ...
			double(stimulus(stimNum).images(:,:,:,imgNum)));
        % create bits++ color lookup table
        if display.USE_BITSPLUSPLUS
            
            display.clut = [0:255; 0:255; 0:255]' * 256;
        end
	end;

	% Clean up
	if removeImages==1
		stimulus(stimNum).images = [];
	end
end;

% call/load 'DrawTexture' prior to actual use (clears overhead)
Screen('DrawTexture', display.windowPtr, stimulus(1).textures(1), ...
	stimulus(1).srcRect, stimulus(1).destRect);

return
