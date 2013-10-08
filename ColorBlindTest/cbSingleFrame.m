function matchIm = cbSingleFrame(display, stimulus, refIm)
% COMMENTS NEED TO BE ADDED HERE
% Also, we need to give this function a more understandable name

originalColor.dir   = stimulus.refColor - stimulus.bgColor;
originalColor.scale = 1;
originalContrast    = RGB2ConeContrast(display,originalColor);
dContrast           = stimulus.dContrast;

ang = stimulus.direction*pi/180;
dir = [cos(ang) sin(ang) 0];

matchContrast.dir = originalContrast + dContrast*dir'/100;
matchContrast.scale = max(abs(matchContrast.dir));
matchContrast.dir = matchContrast.dir / matchContrast.scale;

tt = cone2RGB(display,matchContrast);
matchColor = 0.5+tt.scale*tt.dir;

% Generate Im
im              = refIm;
gapL            = stimulus.gapL;
gapR            = stimulus.gapR;

for i = 1 : 3
    im(:,gapL+1:gapR,i)      = stimulus.bgColor(i); % Why shall I do this
end

if stimulus.MatchingSlot == '1'%(rand > 0.5)
    im(:,1:gapL,1)   = matchColor(1);
    im(:,1:gapL,2)   = matchColor(2);
    im(:,1:gapL,3)   = matchColor(3);
else
    im(:,gapR+1:end,1) = matchColor(1);
    im(:,gapR+1:end,2) = matchColor(2);
    im(:,gapR+1:end,3) = matchColor(3);
end

if stimulus.Gsig > 0
    gFilter = fspecial('Gaussian',[10 10],stimulus.Gsig);
    im    = imfilter(im, gFilter, 'same', 0.5); % Should update 0.5 to something
end

matchIm{1} = im;

return
