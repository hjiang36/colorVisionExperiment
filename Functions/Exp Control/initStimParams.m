function stimParams = initStimParams(varargin)
%% function stimParams = initStimParams([varargin])
%    initialize stimulus parameters
%
%  Input:
%    varargin   - name value pair, could be anything you want to be saved
%                 in stimParams
%  
%  Output:
%    stimParams - stimulus structure
%
%  Example:
%    stimParams = initStimParams('cbType',2,'Gsig',10);
%  
% (HJ) Aug, 2013

%% Check inputs
if mod(length(varargin),2)~=0, 
    error('Inputs should be in name-value pairs'); 
end

%% Initialize default values
% type of color blind
% 0-normal, 1-protan, 2-deuteran, 3-tritan
stimParams.cbType = 0;

% size of stimulus
% in color++ mode, the width will get doubled by bits++ box
stimParams.visualSize = [5 0.5]; %(deg)

% gapSize
stimParams.gapSize = 1/6;

% Spacial Blur
stimParams.Gsig = 0;

% duration of stimulus presentation
stimParams.duration = 0.5; % seconds

% init reference color
stimParams.refColor = [0.5346    0.5675    0.4945]';

% init isi
stimParams.isi = 0.01;

%% Parse varargin and set to stimParams
for i = 1 : 2 : length(varargin)
    stimParams.(varargin{i}) = varargin{i+1};
end

%% END