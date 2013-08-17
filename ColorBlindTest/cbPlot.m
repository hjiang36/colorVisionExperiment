function cbPlot(dataSum,stairParams,fileName,colorHistory,cbType)
% cbPlot(dataSum)
%   function used to visualize the color test data

%   Parameters: dataSum - output structure from color
%               blind staircase test
%               stairParams - parameters for staircase
%               fileName - Log file Name
%               colorHistory - Record for color displayed

for i = 1 : length(dataSum)
    subplot(length(dataSum),1,i);
    plot(dataSum(i).history, 'o-');    
    ylabel(stairParams.adjustableVarName); xlabel('Trial number');
end

try
    figure; hold on;
    dataHistory = importdata(fileName);
    correct     = dataHistory.textdata(4:end,4);
    deltaE      = dataHistory.textdata(4:end,3);
    %points(:,1) = colorHistory(:,2) ./ sqrt(1 + colorHistory(:,1).^2);
    %points(:,2) = points(:,1).* colorHistory(:,1);
    points = colorHistory;
    for i = 1:length(correct)
        if (correct{i} == '1')
            plot(points(i,1),points(i,2),'ro');
        else
            plot(points(i,1),points(i,2),'bo');
        end
    end
    %if cbType == 'normal'
    %hold on;
    %th = 0 : pi/50 : 2*pi;
    %plot(cos(th)*2.3,sin(th)*2.3,'k--');
    %plot(cos(th)*2.3*1.25,sin(th)*2.3*1.25,'k--');
    %plot(cos(th)*2.3*1.5,sin(th)*2.3*1.5,'k--');
    %hold off;
    %end
catch err
    disp('Error in parsing log file');
    disp(err);
end

figure;
deltaE = str2num(cell2mat(deltaE));
correct = str2num(cell2mat(correct));
xE = unique(deltaE);
yE = zeros(1,length(xE));
for i = 1 : length(xE)
    ind = deltaE == xE(i);
    yE(i) = sum(correct(ind))/sum(ind);
end
plot(xE,yE);

