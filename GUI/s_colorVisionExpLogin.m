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
fprintf('Available experiment are listed below\n');
for i = 1 : length(expList)
    fprintf('\t %d - %s\n', i, expList{i}.expName);
end

userChoice = input('Which experiment do you want to run?');
eval(expList{userChoice}.expFunc);