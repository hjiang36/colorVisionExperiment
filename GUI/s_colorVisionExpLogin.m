%% s_colorVisionExpLogin
%
%  COMMENTS TO BE ADDED HERE
%
%  (HJ) Oct, 2013

%% Get user name & validate login
prompt = {'User Name'};
dlg_title = 'Welcome - Login';
def = {'Name'};
answer = inputdlg(prompt, dlg_title, 1, def);

subjectInfo = colorVisionUserInfoGet(answer{1});
if isempty(subjectInfo)
    error('Invalid user name'); 
end

%% Get uncompleted experiment list for the user
expList = colorVisionExpListGet(subjectInfo);


%% Choose and start experiment
userChoice = 3;
eval(expList{userChoice}.expFunc);