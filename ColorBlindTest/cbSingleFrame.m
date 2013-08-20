function matchIm = cbSingleFrame(stimulus,cbIm)
% function [matchIm] = cocSingleFrame(stimulus, display)
        
% Adjust the image according to the experiment type
% switch lower(stimulus.type)
%     case {'protanopia'}
%         cbType = 1;
%     case('deuteranopia')
%         cbType = 2;
%     case{'tritanopia'}
%         cbType = 3;
%     otherwise
%         cbType = 0;
% end

originalColor.dir   = stimulus.refColor'-stimulus.bgColor';
originalColor.scale = 1;
originalContrast  = RGB2ConeContrast(stimulus,originalColor);
deltaE            = stimulus.deltaE;
%dir               = [0 0 1]';
ang = stimulus.direction*pi/180;
dir = [cos(ang) sin(ang) 0];

matchContrast.dir = originalContrast + deltaE*dir'/100;
matchContrast.scale = max(abs(matchContrast.dir));
matchContrast.dir = matchContrast.dir / matchContrast.scale;

tt = cone2RGB(stimulus,matchContrast);
matchColor = (0.5+tt.scale*tt.dir)*255;
%matchColor(matchColor<0) = 0;
%matchColor(matchColor>255) = 255;

% Find match color along direction k with deltaE
%rgb2xyzM = ieXYZFromEnergy(stimulus.spectra',stimulus.wavelength);
%whitePoint = [1 1 1]*rgb2xyzM;

% weights1 = [1 1.4058];%[1 1.2258];%[1 1.5798];%[1 1.18];
% weights2 = [1 -0.84];
% weights = cos(stimulus.direction*pi/180)*weights1 + sin(stimulus.direction*pi/180)*weights2;
% 
% originalXYZ   = originalColor/255*rgb2xyzM;
% matchColorXYZ = originalXYZ;
% 
% matchColorxyz = matchColorXYZ / sum(matchColorXYZ);
% matchColorxyz(1:2) = matchColorxyz(1:2) + deltaE*weights/100;
% matchColorxyz(3)   = 1 - sum(matchColorxyz(1:2));
% matchColorXYZ = matchColorxyz*matchColorXYZ(2);
% matchColor = matchColorXYZ * 255 / rgb2xyzM;
% matchColor = matchColor * originalXYZ(2) / matchColorXYZ(2);
% matchColor(matchColor < 0) = 0;
% matchColor(matchColor > 255) = 255;

% Generate Im
im              = cbIm;
gapL            = stimulus.gapL;
gapR            = stimulus.gapR;

im(:,gapL+1:gapR,:)      = stimulus.bgColor;
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
    im    = imfilter(im, gFilter, 'same', stimulus.bgColor);
end

matchIm{1} = im;

% Record Color
% save single.mat;
% fid = fopen('ColorTable.txt','a+');
% 
% if cbType == 0
%     diff = xyz2lab(originalXYZ,whitePoint) - xyz2lab(matchXYZ,whitePoint);
% else
%     %diff = (reshape(cbColorXYZ,[1 3]) - reshape(matchXYZ,[1 3]))/sum(cbColorXYZ);
%     diff = xyz2lab(cbColorXYZ,whitePoint) - xyz2lab(matchXYZ,whitePoint);
% end
% fprintf(fid,'%f,%f\n',...
%     diff(2),diff(3));
% fclose(fid);

return
