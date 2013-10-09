function [angle, cbParams] = cbDirectionOnCircle(cbParams, varargin)
%% function [angle, cbParams] = cbTestCbDirection([cbParams],[varargin])
%
%  experiment script that can be used to test colorblind direction
%
%  Inputs:
%    cbParams - experiment parameter structure
%    varargin - name-value pairs for experiment control, now supports
%       bitDepth:   bitDepth of the screen, can be either 8 or 10
%       showPlot:   bool, whether or not to show plot for result
%       sendResult: email address to receive the result
%
%  Output:
%    angle    - angle vector of each trial result
%    cbParams - parameters used for colorblind direction test
%
%  See also:
%    doCbDirTrial
%
%  (HJ) Aug, 2013

%% Check inputs
if nargin < 1, cbParams = []; end
if mod(length(varargin),2)~=0, error('Parameter should be in pairs'); end

% Parse varargin
bitDepth   = 8;
showPlot   = false;
sendResult = [];

for i = 1 : 2 : length(varargin)
    switch lower(varargin{i})
        case 'bitdepth' % Set bit depth to be used
            bitDepth   = varargin{i+1};
        case 'showplot' % whether or not to show plot
            showPlot   = varargin{i+1};
        case 'sendresult' % email address to receive email
            sendResult = varargin{i+1};
        otherwise
            warning(['Unknown parameter ' varargin{i} ' encountered']);
    end
end
% Check bitDepth
if bitDepth ~= 8 && bitDepth ~= 10
    error('Unknown color bit depth, can be either 8 or 10');
end

%% Init Experiment Parameters
%  Get subject info
subjectInfo = getSubjectParams();

%  Set fixed parameters
if ~isfield(cbParams, 'nTrials'),  cbParams.nTrials  = 5; end
if ~isfield(cbParams, 'bgColor'),  cbParams.bgColor  = [0.5 0.5 0.5]; end
if ~isfield(cbParams, 'refColor'), cbParams.refColor = [0.5 0.5 0.5]; end

% Init random 
if ~isfield(cbParams, 'initDir') % initial direction
    cbParams.initDir = round(rand(cbParams.nTrials,1)*360);
end

if ~isfield(cbParams, 'dist') % constrast distance in LM plane
    cbParams.dist    = rand(cbParams.nTrials,1)*0.04 + 0.01; 
end

if ~isfield(cbParams, 'patchSz') % patch size in degrees
    cbParams.patchSz = [8 8]; 
end

% Malloc for output
angle = zeros(cbParams.nTrials,1);

%% Init PsychToolbox Window
%  Load display
display  = initDisplay;
display.backColorRgb = cbParams.bgColor*255;

display   = openScreen(display,'hideCursor',false, 'bitDepth',bitDepth);

%% Start Trial
for curTrial = 1 : cbParams.nTrials
     cbParams.curTrial = curTrial;
     % Do trial
     angle(curTrial) = cbDirectionOnCircleTrial(display, ...
                                        display.windowPtr, cbParams);
end

%% Close PsychToolbox Window
closeScreen(display);

%% Plot
if showPlot
    % Init figure
    figure('Name',['Colorblind Direction Test - ' subjectInfo.name],...
        'NumberTitle','off',...
        'Resize','on'); 
    grid on; axis equal; hold on;
    % Plot data
    plot(cos(angle).*cbParams.dist, sin(angle).*cbParams.dist, '.r');
    % Set axis info to plot
    title('Colorblind Direction Test');
    xlabel('L-contrast');
    ylabel('M-contrast');
end

%% Send Results
if ~isempty(sendResult)
    %  Save results to file
    dataFileName = ['ColorDirection_' subjectInfo.name '.mat'];
    save(dataFileName,'angle','cbParams','subjectInfo');
    
    %  Send results via email
    sendMailAsHJ(sendResult, ...
             ['Color Vision Exp Data for ' subjectInfo.name], ...
             ['Experiment finished on ' date '. Data is attached'],...
             dataFileName);
    
    %  Delete result file
    delete(dataFileName);
end

end
%%END