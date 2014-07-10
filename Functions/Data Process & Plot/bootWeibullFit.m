function [mu, sd] = bootWeibullFit(stimLevels, nCorrect, nTrials, varargin)
%% function bootWeibullFit(stimLevels, nCorrect, nTrials, nBoot)
%    fit Weibull function and estimate standard deviation of the parameters
%    by bootstraping pairs in data
%
%  Inputs:
%    stimLevels  - stimulus levels tested
%    nCorrect    - number of times subject get the answer correct
%    nTrials     - number of total trials on each level
%    nBoot       - number of bootstraps to be done
%    beta        - fixed beta to be used in Weibull fit
%
%  Outputs:
%    mu  - 2x1 vector, containing estimate of alpha, beta on the original
%          data set
%    sd  - 2x1 vector, containing standard deviation of alpha, beta
%
%  Note:
%    Since the experiment is usually done with staircase control, bootstrap
%    method might have a little bias.
%
%  (HJ) May, 2014

%% Init
if notDefined('stimLevels'), error('stimLevels required'); end
if notDefined('nCorrect'), error('number of correctness required'); end
if notDefined('nTrials'), error('number of total trials required'); end
if ~isempty(varargin), nBoot = varargin{1}; end
if isempty(nBoot), nBoot = 1000; end
if length(varargin) > 1, beta = varargin{2}; end
if isempty(beta), beta = 4; end
if numel(stimLevels) ~= numel(nCorrect) || ...
        numel(stimLevels) ~= numel(nTrials)
    error('Inputs should be vectors of same length');
end

% Convert to column vectors
stimLevels = stimLevels(:); nCorrect = nCorrect(:); nTrials = nTrials(:);

% Eliminate entries with zero trials
indx = (nTrials > 0);
stimLevels = stimLevels(indx);
nCorrect = nCorrect(indx);
nTrials = nTrials(indx);

%% Setup data format
xData  = zeros(sum(nTrials), 2);
sIndex = [1; cumsum(nTrials)];
for curLevel = 1 : length(stimLevels)
    xData(sIndex(curLevel):sIndex(curLevel+1), 1) = stimLevels(curLevel);
    xData(sIndex(curLevel):sIndex(curLevel) + nCorrect(curLevel), 2) = 1;
end

%% Weibull fit
[alpha, beta,~] = FitWeibAlphTAFC(stimLevels, nCorrect, ...
    nTrials - nCorrect,[], beta);
mu = [alpha; beta];

%% Bootstrap
N = length(xData);
bAlpha = zeros(nBoot, 1);
for b = 1 : nBoot
   indx = randsample(N, N, true); % sample with replacement
   bData = xData(indx, :);
   
   % Group by stimLevels
   [bLevels, ~, ic] = unique(bData(:,1));
   n = length(bLevels);
   bCorrect = zeros(n, 1); bTrials = zeros(n, 1);
   for ii = 1 : n
       bCorrect(ii) = sum(bData(ic == ii, 2));
       bTrials(ii) = sum(ic == ii);
   end
   
   % Weibull fit on the bootstrapped data
   [bAlpha(b), ~, ~] = FitWeibAlphTAFC(bLevels, bCorrect, ...
            bTrials - bCorrect,[], beta);
end

sd = [std(bAlpha); 0];

end