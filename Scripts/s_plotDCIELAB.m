% Init display structure
% Actually, the final result does not depend on which display we use. But
% having a display structure could help make the code simpler
d = displayCreate('LCD-Apple');

% Init parameters
cbType = 'Deutan'; % colorblind type
angle = [15:5:75 105:5:160 200:5:250 290:5:340]; % color direction in LM
thresh = .27; % threshold in units of deltaE
threshColor = zeros(2, length(angle)); % pre-allocate space

% Compute background XYZ (used as white point)
[~, bgLMS] = coneContrast2RGB(d, [0 0 0]);
bgXYZ = lms2xyz(reshape(bgLMS, [1 1 3]));
bgXYZ = bgXYZ(:);

% Compute threshold contrast for each color direction
for ii = 1 : length(angle)
    % printf info
    fprintf('Computing for angle: %d...', angle(ii));
    
    % Generate parameters
    dir = [cosd(angle(ii)) sind(angle(ii)) 0]';
    dContrast = 0.3; dMin = 0; dMax = 0.1;
    
    % Binary search for JND contrast
    while true
        sContrast = dContrast * dir;
        
        LMS = reshape((sContrast+1).*bgLMS, [1 1 3]);
        LMS = lms2lmsDichromat(LMS, cbType, 'Brettel', bgLMS);
        XYZ = lms2xyz(LMS);
        XYZ = XYZ(:);
        
        de = deltaEab(XYZ', bgXYZ', bgXYZ, '1976');
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
    fprintf('Done\n');
end

% Visualize
% vcNewGraphWin; hold on;
plot(threshColor(1,:), threshColor(2,:), 'x');

% fit line or ellipse
if ischar(cbType), cbType = ieParamFormat(cbType); end
switch cbType
    case {0, 'trichromat'}
        % trichromatic observer, fit ellipse
        [zg, ag, bg, alphag] = fitellipse(threshColor);
        plotellipse(zg, ag, bg, alphag, '--')
    case {1, 'protan', 'protanopia', 'protanope'}
        % protanope, missing L cones, should be two horizontal lines
        indx = threshColor(2,:) > mean(threshColor(2,:));
        refline(0, mean(threshColor(2,  indx)));
        refline(0, mean(threshColor(2, ~indx)));
        
    case {2, 'deutan', 'deuteran', 'deuteranope', 'deuteranopia'}
        % deuteranope, missing M cones, should be two vertical lines
        indx = threshColor(1,:) > mean(threshColor(1,:));
        pos = mean(threshColor(1,  indx)); line([pos pos], [-0.05 0.05]);
        pos = mean(threshColor(1, ~indx)); line([pos pos], [-0.05 0.05]);
    case {3, 'tritan', 'tritanope', 'tritanopia'}
        % it's not a good idea to plot contour for tritanope in L-M plane
        % but anyway, we plot it
        [zg, ag, bg, alphag] = fitellipse(threshColor);
        plotellipse(zg, ag, bg, alphag, '--')
    otherwise
        error('Unknown colorblind type');
end

% Set labels
xlabel('L Cone Contrast'); ylabel('M Cone Contrast'); 
grid on; axis equal;