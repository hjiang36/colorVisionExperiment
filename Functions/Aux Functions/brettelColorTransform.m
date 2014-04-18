function imgLMS = brettelColorTransform(imgLMS, cbType, whiteLMS)
%% function brettelColorTransform(LMS, cbType)
%    This function implements brettel's color transform algorithm (1997)
%    A similar function could be found in xyz2lms
%    We implement this funciton because we don't want to detour to xyz
%    color space sometimes
%
%  (HJ) March 2014

if notDefined('imgLMS'), error('LMS color required'); end
if notDefined('cbType'), error('cbType required'); end

anchor_e = whiteLMS;

% These anchor values are derived in the paper and used to compute the
% missing cone value.  At the moment, they are sometimes negative, sigh.
%
% Load the LMS anchor-point values for lambda = 475 & 485 nm (for protans &
% deutans) and the LMS values for lambda = 575 & 660 nm (for tritans).  I
% think these anchor points are the Stockman fundamentals values. After
% checking, they are close.  See below.
%
% LMS for 475, I guess. Closest to 473. ieReadSpectra('stockman',[473])
anchor(1) = 0.08008;  anchor(2) = 0.1579;   anchor(3) = 0.5897;
% LMS for 485, I guess. Closest to 482. % ieReadSpectra('stockman',[482])
anchor(4) = 0.1284; anchor(5) = 0.2237; anchor(6) = 0.3636;
% LMS for 575.  Pretty good.   % ieReadSpectra('stockman',[576])
anchor(7) = 0.9856; anchor(8) = 0.7325; anchor(9) = 0.001079;
% LMS for 660, Good.% ieReadSpectra('stockman',[662])
anchor(10) = 0.0914;   anchor(11) = 0.007009;  anchor(12) = 0.0;
% To verify the the calculations and values, do this:
%  lms = ieReadSpectra('stockman',400:700);
%  g = 4; g = (g-1)*3 + 1; diff = lms - ones(301,3)*diag([anchor(g:(g+2))]);
%  err = sqrt(diag(diff*diff'));[v,idx] = min(err); 400 + idx

% Depending on color blindness type
switch cbType
    case 1          % Protanopia
        % These formula are Equation (8) in the Bretell paper.
        % find a,b,c for lam=575nm and lam=475
        
        % Less than inflection
        a1 = anchor_e(2) * anchor(9) - anchor_e(3) * anchor(8);
        b1 = anchor_e(3) * anchor(7) - anchor_e(1) * anchor(9);
        c1 = anchor_e(1) * anchor(8) - anchor_e(2) * anchor(7);
        % Greater than inflection
        a2 = anchor_e(2) * anchor(3) - anchor_e(3) * anchor(2);
        b2 = anchor_e(3) * anchor(1) - anchor_e(1) * anchor(3);
        c2 = anchor_e(1) * anchor(2) - anchor_e(2) * anchor(1);
        
        % Divides the space
        inflection = (anchor_e(3) / anchor_e(2));
        
        % Interpolate missing L values for protonate
        L = imgLMS(:,:,1); M = imgLMS(:,:,2); S = imgLMS(:,:,3);
        lst = ((S ./ M) < inflection);
        L(lst)  = -(b1*M(lst)  + c1*S(lst))  / a1;
        L(~lst) = -(b2*M(~lst) + c2*S(~lst)) / a2;
        imgLMS(:,:,1) = L;
        % vcNewGraphWin; imagescRGB(imgLMS);
        
        %             for rr = 1:sizeLMS(1)
        %                 for cc = 1:sizeLMS(2)
        %                     if((imgLMS(rr, cc, 3) / imgLMS(rr, cc, 2)) < inflection)
        %                         imgLMS(rr, cc, 1) = -(b1 * imgLMS(rr, cc, 2) + c1 * imgLMS(rr, cc, 3)) / a1;
        %                     else
        %                         imgLMS(rr, cc, 1) = -(b2 * imgLMS(rr, cc, 2) + c2 * imgLMS(rr, cc, 3)) / a2;
        %                     end
        %                 end
        %             end
        % vcNewGraphWin; imagescRGB(imgLMS);
        
        
    case 2          % Deuternopia
        % find a,b,c for lam=575nm and lam=475, again.
        % Less than inflection
        a1 = anchor_e(2) * anchor(9) - anchor_e(3) * anchor(8);
        b1 = anchor_e(3) * anchor(7) - anchor_e(1) * anchor(9);
        c1 = anchor_e(1) * anchor(8) - anchor_e(2) * anchor(7);
        % Greater than inflection
        a2 = anchor_e(2) * anchor(3) - anchor_e(3) * anchor(2);
        b2 = anchor_e(3) * anchor(1) - anchor_e(1) * anchor(3);
        c2 = anchor_e(1) * anchor(2) - anchor_e(2) * anchor(1);
        
        inflection = (anchor_e(3) / anchor_e(1));
        
        % Interpolate missing M values for deuteranope
        L = imgLMS(:,:,1); M = imgLMS(:,:,2); S = imgLMS(:,:,3);
        lst = ((S ./ L) < inflection);
        M(lst)  = -(a1*L(lst)  + c1*S(lst)) / b1;
        M(~lst) = -(a2*L(~lst) + c2*S(~lst))/ b2;
        imgLMS(:,:,2) = M;
        % vcNewGraphWin; imagescRGB(imgLMS);title('New formula');
        
        %             for i = 1:sizeLMS(1)
        %                 for n = 1:sizeLMS(2)
        %                     if((imgLMS(i, n, 3) / imgLMS(i, n, 1)) < inflection)
        %                         imgLMS(i, n, 2) = -(a1 * imgLMS(i, n, 1) + c1 * imgLMS(i, n, 3)) / b1;
        %                     else
        %                         imgLMS(i, n, 2) = -(a2 * imgLMS(i, n, 1) + c2 * imgLMS(i, n, 3)) / b2;
        %                     end
        %                 end
        %             end
        %             vcNewGraphWin; imagescRGB(imgLMS); title('Old formula');
        
    case 3          % Tritanopia
        
        % find for lam=660 and lam=485 */
        % Less than the inflection
        a1 = anchor_e(2) * anchor(12) - anchor_e(3) * anchor(11);
        b1 = anchor_e(3) * anchor(10)  - anchor_e(1) * anchor(12);
        c1 = anchor_e(1) * anchor(11) - anchor_e(2) * anchor(10);
        
        % Greater than the inflection
        a2 = anchor_e(2) * anchor(6)  - anchor_e(3) * anchor(5);
        b2 = anchor_e(3) * anchor(4)  - anchor_e(1) * anchor(6);
        c2 = anchor_e(1) * anchor(5)  - anchor_e(2) * anchor(4);
        
        % Inflection point
        inflection = (anchor_e(2) / anchor_e(1));
        
        % Interpolate missing M values for tritanope
        L = imgLMS(:,:,1); M = imgLMS(:,:,2); S = imgLMS(:,:,3);
        lst = ((M ./ L) < inflection);
        S(lst)  = -(a1*L(lst)  + b1*M(lst)) / c1;
        S(~lst) = -(a2*L(~lst) + b2*M(~lst))/ c2;
        imgLMS(:,:,3) = S;
        %vcNewGraphWin; imagescRGB(imgLMS);title('New formula');
        
        %             for i = 1:sizeLMS(1)
        %                 for n = 1:sizeLMS(2)
        %                     if((imgLMS(i, n, 2) / imgLMS(i, n, 1)) < inflection)
        %                         imgLMS(i, n, 3) = -(a1 * imgLMS(i, n, 1) + b1 * imgLMS(i, n, 2)) / c1;
        %                     else
        %                         imgLMS(i, n, 3) = -(a2 * imgLMS(i, n, 1) + b2 * imgLMS(i, n, 2)) / c2;
        %                     end
        %                 end
        %             end
        %             vcNewGraphWin; imagescRGB(imgLMS);title('Old formula');
        
end

end

