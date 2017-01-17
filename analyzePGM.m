clc;
clear all;
close all;

pgmFile = 'snapshot000.pgm';
analyzeColumn = 1024;
columnsTotal = 1024; %1024
artOffset = 0;

imageIn = double(imread(pgmFile)/16); % div by 16 to scale 16bit to 12bit

imageIn = imageIn(:,1:columnsTotal);


% Histograms

column = imageIn(:,analyzeColumn);
% 2D
figure();
hist(column+artOffset);

meanColumn = mean(column);
stdColumn = std(column);
varColumn = var(column);

xlabel(['Mean: ' num2str(meanColumn+artOffset) '; Stdev: ' num2str(stdColumn) '; Var: ' num2str(varColumn) ]);
ylabel('N');
title(['Noise spread for column: ' num2str(analyzeColumn)]);

% 3D
[count,bins] = hist(imageIn,10);

figure();

b = bar3c(bins, count, 'detached');

binColumn = dec2bin(column)-'0';

% Analyze column FPN

for k = 1:columnsTotal
  
  column = imageIn(:,k);
  
  meanColumn(k) = mean(column+artOffset);
  
  end
figure();  
  plot(meanColumn);
  xlabel('Column ADC Nr (X)');
  xlim([0 columnsTotal]);
  ylabel(['Mean value of column over ' num2str(length(column)) ' samples']);
  title(['Mean columns (X) for ' num2str(length(column)) ' samples']);
