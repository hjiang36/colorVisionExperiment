%% Process colorblind test data
%
%  This script contains following procedures:
%   1. Load and parse the staircase log file
%   2. Weibull fit and get points with 75% accuracy for all directions
%   3. Plot data in xyY space
%   4. Fitting and Comparing with Confusion Lines
%   5. Compute colorblind DeltaE values for all directions
% 
%  Written by HJ
%  July, 2013

%% Clean up
clear; clc; close all;

%% Init Experiment Parameters
% Set colorblind type
cbType = 2; % Protanopia - 1, Deuteranopia - 2, Tritanopia - 3

% Create Display Structure
c = load('BVM_SMPTE-C_PR715_Spectrum_06_01_2013.mat');
display.spectra = [c.spectrum.red c.spectrum.green c.spectrum.blue];
display.wavelength = c.wavelength;
rgb2xyzM = ieXYZFromEnergy(display.spectra', c.wavelength);
backColor    = [0.5 0.5 0.5];

% Set Experiment Reference Color
refColorRGB.dir       = [35 152 101]'/255;%[175 50 50]'/255;%[110 30 83]'/255;%[10 220 100];%[99 15 17];
refColorRGB.scale     = 1;
refColorXYZ           = refColorRGB.dir' * refColorRGB.scale * rgb2xyzM;
refColorLMS = RGB2ConeContrast(display,refColorRGB);
refColorxyY           = refColorXYZ / sum(refColorXYZ);
refColorxyY(3)        = refColorXYZ(2);

% Set White Point (Display Gray Background)
whitePoint = backColor*rgb2xyzM;

% Set Directions and Angles
weights1 = [1 (1.4-refColorxyY(1))/(0.4+refColorxyY(2))];
weights2 = 1./weights1;
%ang = [0 45 75 115 135 180 225 250 300 345];
ang = [0 180];
ang = ang / 180 * pi;

%% Load and Parse Experiment Log file
tmp = importdata('~/Desktop/Colorblind Process Data/Haomiao_NOM.log');
data = tmp.textdata(4:end,1:4);
for i = 1 : length(data(:))
    data{i} = str2double(data{i});
end;
data = [cell2mat(data) tmp.data];

%% Weibull Fit Data and Get Points with 75% Accuracy
% Init Figure Properties
figure; axis; hold on;
title('Fitted Weibull Curves');
xlabel('Color Contrast'); ylabel('Accuracy');
set(gcf,'DefaultAxesColorOrder',[1 0 0;0 1 0;0 0 1],...
      'DefaultAxesLineStyleOrder','-|--|:')
pCorrect = 0.51:0.01:0.99;

% Fit and Plot
stairs = unique(data(:,1)); % Get different Directions
dist75 = zeros(1,length(stairs));
for i = 1 : length(stairs)
    % Get data for certain stairs
    curData = data(data(:,1) == stairs(i), 3:4);
    % Compute Statistics
    [distAcc,~,IC] = unique(curData(:,1));
    distAcc = padarray(distAcc,[0 2], 0, 'post');
    % distAcc(:,1) - level values (distance)
    % distAcc(:,2) - number of correctness
    % distAcc(:,3) - total trials for certain level
    for j = 1 : length(curData)
        distAcc(IC(j),2) = distAcc(IC(j),2) + curData(j,2);
        distAcc(IC(j),3) = distAcc(IC(j),3) + 1;
    end
    % Weibull fit
    [alpha,beta,~] = FitWeibAlphTAFC(distAcc(:,1),distAcc(:,2),...
        distAcc(:,3)-distAcc(:,2),[],2.2);
    %[alpha,beta,~] = FitWeibTAFC(distAcc(:,1),distAcc(:,2),...
    %    distAcc(:,3)-distAcc(:,2));
    dist75(i) = FindThreshWeibTAFC(0.75,alpha,beta);
    threshX = alpha*(-log(2*(1-pCorrect))).^(1/beta);
    plot(threshX,pCorrect);
    plot(distAcc(:,1),distAcc(:,2)./distAcc(:,3),'or')
end
dist75 = dist75/100; % Divided by 100 is because in experiment this is divided by 100

%% Compute 75% Positions and corresponding deltaE values
matchColorxyY = zeros(length(ang),3);
matchColorXYZ = zeros(length(ang),3);
matchColorLMS = zeros(length(ang),3);
disp('Colorblind DeltaE value:');
for i = 1:length(ang)
    weights = cos(ang(i))*weights1 + sin(ang(i))*weights2;
    matchColorxyY(i,1:2) = refColorxyY(1:2) + dist75(i)*weights;
    matchColorxyY(i,3)   = refColorxyY(3);
    matchColorXYZ(i,:)   = [matchColorxyY(i,1:2) 1-sum(matchColorxyY(i,1:2))] * ...
        refColorxyY(3)/matchColorxyY(i,2);
    matchColorRGB.dir = (matchColorXYZ(i,:)/rgb2xyzM)';
    matchColorRGB.scale = 1;
    matchColorLMS(i,:) = RGB2ConeContrast(display,matchColorRGB);
    % Compute Colorblind DeltaE value
    cbRefColorXYZ = ctSimColorblind([],reshape(...
        refColorXYZ,[1 1 3]),cbType,whitePoint);
    cbMatchColorXYZ   = ctSimColorblind([],reshape(...
        matchColorXYZ(i,:),[1 1 3]),cbType,whitePoint);
    disp([num2str(ang(i)/pi*180) ':' num2str(deltaEab(cbRefColorXYZ,cbMatchColorXYZ, whitePoint))]);
end

%% Plot Data in xyY range
% Create Figure
figure; axis;
xlabel('x'); ylabel('y');

% Plot Visible Range
visColor = importdata('ciexyz64.csv');
visX = visColor(:,2) ./ sum(visColor(:,2:4),2);
visY = visColor(:,3) ./ sum(visColor(:,2:4),2);
plot(visX,visY); hold on;
plot([visX(1) visX(end)],[visY(1) visY(end)]);

% Plot Reference Point
plot(refColorxyY(1), refColorxyY(2),'+r');

% Plot Match Color 75% Data Points
switch cbType
    case 1 % Protanopia
        refX = 0.7635; refY = 0.2365;
        curX = 0; direction = 1;
    case 2 % Deuteranopia
        refX = 1.4; refY =-0.4;
        curX = 0; direction = 1;
    case 3 % Tritanopia - not tested
        refX = 0.1748; refY = 0;
        curX = 1; direction = -1;
end

for i = 1 : length(ang)
    plot(matchColorxyY(i,1),matchColorxyY(i,2),'og');
    tol  = 1e-3; isIn = 0; stepSize = 0.2;
    getY = @(X) refY + (X-refX)*(refY - matchColorxyY(i,2))/(refX-matchColorxyY(i,1));
    % Find intersection with binary search
    while stepSize > tol
        curY = getY(curX);
        if inpolygon(curX,curY,visX,visY) ~= isIn
            isIn = ~isIn;
            direction = -direction;
            stepSize = stepSize / 2;
        end
        curX = curX + stepSize * direction;
    end
    curY = getY(curX);
    plot([curX refX],[curY refY],'--', 'Color', [0.5 0.5 0.5]);
end

%% Plot in LMS Space
figure; axis; hold on;
xlabel('L'); ylabel('M'); zlabel('S');

% Plot Reference Point
plot3(refColorLMS(1),refColorLMS(2),refColorLMS(3),'+r');

% Plot Match Color 75% Data Points
for i = 1 : length(ang)
    plot3(matchColorLMS(i,1),matchColorLMS(i,2),matchColorLMS(i,3),'og');
end