%% s_systemErrorEstimate
%
%    This script is used to estimate system error of the staircase
%    controlled color vision experiment
%
%  (HJ) ISETBIO TEAM

%% Init
nBoot      = 5000; % bootstrap replications
nTrials    = 300;  % number of trials per replication
% nReversals = 24;   % max number of reversals

% discrimination probability
alpha = 0.0208; beta = 2.2;
discr_prob = @(x) 1 - exp(-(x/alpha).^beta)/2; 

% staircase parameters
stairParams = initStaircaseParams;
stim_levels = stairParams.adjustableVarValues(:);
cur_level   = stairParams.adjustableVarStart(1) * ones(nBoot, 1);
num_levels  = length(stim_levels);

num_consecutive_correct = zeros(nBoot, 1);
correct_step   = stairParams.correctStepSize(:);
incorrect_step = stairParams.incorrectStepSize(:);
step_index     = ones(nBoot, 1);

% init space for computing statistics
num_correct   = zeros(nBoot, num_levels);
num_trials    = zeros(nBoot, num_levels);
num_reversals = zeros(nBoot, 1);

%% Simulate staircase controlled experiment
for ii = 1 : nTrials
    % stim_levels(cur_level) is presented, thus the discrimination
    % probability could be computed as
    %   p = discr_prob(stim_levels(cur_level));
    % Thus, the experiment could be simulated as
    is_correct = rand(nBoot, 1) < discr_prob(stim_levels(cur_level));
    
    % update num_correct and num_trials
    index = sub2ind([nBoot num_levels], (1:nBoot)', cur_level);
    num_trials(index)  = num_trials(index) + (num_reversals <= nReversals);
    num_correct(index) = num_correct(index) + ...
                            is_correct .* (num_reversals <= nReversals);
    
    % update cur_level for incorrects
    is_reversal = num_consecutive_correct > 0 & ~is_correct;
    num_reversals = num_reversals + is_reversal;
    step_index(is_reversal) = max(step_index(is_reversal) - 1, 1); 
    
    num_consecutive_correct(~is_correct) = 0;
    cur_level(~is_correct) = cur_level(~is_correct) + ...
                                incorrect_step(step_index(~is_correct));
    
    % update cur_level for corrects
    is_reversal = num_consecutive_correct == 2 & is_correct;
    num_reversals = num_reversals + is_reversal;
    
    step_index(is_reversal) = max(step_index(is_reversal) - 1, 1);
    
    num_consecutive_correct(is_correct) = ...
            num_consecutive_correct(is_correct) + 1;
    
    index = num_consecutive_correct > 2;
    cur_level(index) = cur_level(index) + correct_step(step_index(index));
    
    % make sure current level is within range [1, num_levels]
    cur_level = max(cur_level, 1);
    cur_level = min(cur_level, num_levels);
end

if any(num_reversals <= nReversals)
    fprintf('Still, some boot replication does not reach nReversals\n');
else
    fprintf('All boot replications reached nReversals\n');
end

%% Weibull fit and compute statistics for alpha
alpha_boot = zeros(nBoot, 1);

fprintf('Weibull fit and compute statistics:     ');
for ii = 1 : nBoot
    if mod(ii, 50) == 0, fprintf('\b\b\b\b%.2f', ii/nBoot); end
    index = num_trials(ii, :) > 0;
    alpha_boot(ii) = FitWeibAlphTAFC(stim_levels(index)', ...
                num_correct(ii, index), ...
                num_trials(ii, index) - num_correct(ii, index), ...
                alpha, 4);
end
fprintf('\n');

% hist(alpha_boot, 50);
% figure; grid on; hold on;
% pCorrect = 0.5:0.01:0.99;
% plot(alpha*(-log(2*(1-pCorrect))).^(1/beta), pCorrect, 'r');
% ah = quantile(alpha_boot, 0.975);
% plot(ah*(-log(2*(1-pCorrect))).^(1/beta), pCorrect, '--k');
% al = quantile(alpha_boot, 0.025);
% plot(al*(-log(2*(1-pCorrect))).^(1/beta), pCorrect, '--k');