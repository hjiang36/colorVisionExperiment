function userInfo = colorVisionCreateUser(userName, cbType)
%% function colorVisionCreateUser(userName, cbType)
%    create user information .mat file for color vision experiment
%
%  Inputs:
%    userName - string, contains First-Last initials of subject
%    cbType   - colorblind type, 0 for normal, and 1~3 for protan,
%               deuteran and tritan correspondingly
%
%  Outputs:
%    A userName.mat file is saved to data directory
%
%  (HJ) Oct, 2013

%% Check inputs
if nargin < 1, error('user name is required'); end
if notDefined('cbType'), cbType = 0; end

userInfo.name = userName;

dataDir = initDataDir;
userDataFileDir = fullfile(dataDir, 'UserData', ieParamFormat(userName));
userDataDir = fullfile(dataDir, 'ExpResults', ieParamFormat(userName));

if ~exist(userDataDir, 'dir')
    mkdir(userDataDir);
    addpath(userDataDir);
end

userInfo.dataDir = userDataDir;
userInfo.cbType  = cbType; 
save(userDataFileDir, 'userInfo');

end