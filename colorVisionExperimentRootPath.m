function rootPath = colorVisionExperimentRootPath()
%% Return the path to the root color vision experiment directory
%
%    This function must reside in the directory at the base of the color
%    vision experiment folder. It is used to determine the location of
%    various files and sub-directories.
% 
%  Example:
%    fullfile(colorVisionExperimentRootPath,'data')
%
%  (HJ) ISETBIO TEAM, 2015

rootPath = mfilename('fullpath');
[rootPath, ~, ~]=fileparts(rootPath);

end