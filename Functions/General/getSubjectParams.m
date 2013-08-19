function subjectParams = getSubjectParams(dataDir, subjectParams)
%% function subjectParams = getSubjectParams([dataDir],[subjectParams])
%    get subject name & comments
%
%  Inputs:
%    dataDir       - path to data folder, default is set by initDataDir
%    subjectParams - subject parameters
%
%  Output:
%    subjectParams - subject name / comment structure
%
%  Example:
%    subjectParams = getSubjectParams;
%
%  See also:
%    initDataDir
%
%  (HJ) Aug, 2013

%% Check inputs
if nargin < 1, dataDir = initDataDir; end
if nargin < 2, subjectParams = []; end

%% Load and set subject name / comment
if ~exist('subjectParams','var') || ~isfield(subjectParams,'name') 
    subjectParams.name = 'demo';
end

% Show dialog
subjectParams.comment = 'none';
dlgPrompt = {'Enter the subject name: ','Enter a comment: '};
dlgTitle = 'Set Subject Parameters';

resp = inputdlg(dlgPrompt,dlgTitle,1,...
    {subjectParams.name,subjectParams.comment});

% Set parameters to subjectParams structure
subjectParams.name          = resp{1};
subjectParams.comment       = resp{2};
subjectParams.dataFileName  = fullfile(dataDir,subjectParams.name);

end