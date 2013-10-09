function dataDir = initDataDir(useDefault)
%% function dataDir = initDataDir([useDefault])
%    initialize the directory to store data
%
%  Inputs:
%    useDefault - bool, use default directory or interactive choose
%                 data directory, default value true
%  
%  Outputs:
%    dataDir    - initialized data directory
%
%  Example:
%    dataDir = initDataDir(false);
%
%  (HJ) Aug, 2013

%% Check inputs
if nargin < 1, useDefault = true; end

%% Set up data directory
if useDefault % Use default directory, 'colorVisionExperimentPath/Exp Data'
    dataDir = mfilename('fullpath');
    oldPath = cd(fileparts(dataDir)); % Change to mfile location
    if ~exist('../../Exp Data', 'dir')
        mkdir('../../', 'Exp Data');
    end
    cd('../../Exp Data'); % Change to data directory
    dataDir = pwd;
    cd(oldPath); % Restore settings
else
    % Choose one interactively
    dataDir = uigetdir(pwd, 'Choose Data Folder');
end

%% Check existance 
if(~exist(dataDir,'dir')),
    mkdir(dataDir);
end

return