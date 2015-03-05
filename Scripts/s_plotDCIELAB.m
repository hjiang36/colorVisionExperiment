d = initDisplay('CRT-NEC');

cbType = 0;
% angle = 0:2:359;
angle = [15:5:75 105:5:160 200:5:250 290:5:340];
thresh = .27;
% white = displayGet(d, 'white xyz');

[~, bgLMS] = coneContrast2RGB(d, [0 0 0]);
bgXYZ = lms2xyz(reshape(bgLMS, [1 1 3]));
bgXYZ = bgXYZ(:);

% white = xyz2lms(reshape(bgXYZ, [1 1 3]));
% white = white(:);
threshColor = zeros(2, length(angle));

for ii = 1 : length(angle)
    dir = [cosd(angle(ii)) sind(angle(ii)) 0]';
    dContrast = 0.3; dMin = 0; dMax = 0.1;
    while true
        sContrast = dContrast * dir;
        
        LMS = reshape((sContrast+1).*bgLMS, [1 1 3]);
        LMS = brettelColorTransform(LMS, cbType, bgLMS);
        XYZ = lms2xyz(LMS);
        XYZ = XYZ(:);
        
        de = deltaEab(XYZ', bgXYZ', white, '1976');
        if de < thresh - 0.005
            dMin = dContrast;
        elseif de > thresh + 0.005
            dMax = dContrast;
        else
            break;
        end
        dContrast = (dMin + dMax) / 2;
    end
    threshColor(:, ii) = dContrast * dir([1;2]);
end