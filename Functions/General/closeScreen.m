function display = closeScreen(display)
%% function display = closeScreen(display)
%    Close PTB screen and restore it to its original status
%  
%  Input:
%    display - returned display structure from function openScreen
%
%  Output:
%    display - display structure with fields resetted
%
%  See also:
%    openScreen
%
%  History:
%    ( RFD) ###, #### - write first version
%    ( HJ ) Aug, 2013 - clean up, comment, and re-organize

%% Check inputs
if nargin < 1, error('Display structure required'); end
if ~isfield(display,'screenNumber'), error('Unknown screen number'); end

%% Reset Gamma and close screen
if isfield(display,'oldGamma') && ~isempty(display.oldGamma)
    Screen('LoadNormalizedGammaTable', ...
        display.screenNumber, display.oldGamma);
end

Screen('CloseAll');

%% Remove fields for old settings
%  remove window pointer
if isfield(display,'windowPtr')
    display = rmfield(display, 'windowPtr');
end

%  remove dst rect
if isfield(display,'rect')
    display = rmfield(display,'rect');
end

% remove old gamma table
if isfield(display,'oldGamma')
    display = rmfield(display,'oldGamma');
end

% Restore cursor
ShowCursor;

end