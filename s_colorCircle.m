%% s_colorCircle

%% Compute color in each direction
d = displayCreate('CRT-NEC');

% L, S plane for deuteranope
[L,S] = meshgrid(-0.25:0.001:0.25, -0.25:0.001:0.25);
rgb = coneContrast2RGB(d, cat(3, L, zeros(size(L)), S));

indx = (L.^2 + S.^2) < 0.02 | (L.^2 + S.^2) > 0.06;
indx = repmat(indx, [1 1 3]);

rgb(indx) = .8;

vcNewGraphWin; 
subplot(1,2,1); imshow(rgb);

% M, S plane for protanope
[L,M] = meshgrid(-0.25:0.001:0.25, -0.25:0.001:0.25);
rgb = coneContrast2RGB(d, cat(3, L, M, zeros(size(L))));

indx = (L.^2 + M.^2) < 0.02 | (L.^2 + M.^2) > 0.06;
indx = repmat(indx, [1 1 3]);

rgb(indx) = .8;

subplot(1,2,2); imshow(rgb);