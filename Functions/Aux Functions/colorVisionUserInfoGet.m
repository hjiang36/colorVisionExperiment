function result = colorVisionUserInfoGet(userName)
%% colorVisionUserInfoGet
%    This script gets color experiment user information.
%    To keep user information confidential, the content of this script
%    should not be disclosed to anyone
%
%  Inputs:
%    userName   - string, user name
%
%  Outputs:
%    result     - if user name is valide, then the corresponding user
%                 information structure is returned, otherwise, return 
%                 empty. User information structure contains sex,
%                 colorblind type, a list of experiment done and their
%                 finished time
%
%  Example:
%    userInfo = colorVisionUserInfoGet('HJ');
%
%  (HJ) Oct, 2013

%% Check inputs
if notDefined('userName'), error('User name required'); end
userName = ieParamFormat(userName);

%% Get user information structure
try
    result = load(userName);
    result = result.userInfo;
catch
    result = [];
end

end