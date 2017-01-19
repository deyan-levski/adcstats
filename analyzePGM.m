clc;
clear all;
close all;

pgmFile = 'snapshots/snapshot000.pgm';
pgmFile1 = 'snapshots/snapshot001.pgm';
pgmFile2 = 'snapshots/snapshot002.pgm';
pgmFile3 = 'snapshots/snapshot003.pgm';
pgmFile4 = 'snapshots/snapshot004.pgm';
pgmFile5 = 'snapshots/snapshot005.pgm';
pgmFile6 = 'snapshots/snapshot006.pgm';
pgmFile7 = 'snapshots/snapshot007.pgm';
pgmFile8 = 'snapshots/snapshot008.pgm';
pgmFile9 = 'snapshots/snapshot009.pgm';
pgmFile10 = 'snapshots/snapshot010.pgm';
pgmFile11 = 'snapshots/snapshot011.pgm';

analyzeColumn = 68;
columnsTotal = 128; %1024
artOffset = 0;

imageIn = double(imread(pgmFile)/16); % div by 16 to scale 16bit to 12bit
imageIn = [imageIn; double(imread(pgmFile1)/16)]; % div by 16 to scale 16bit to 12bit
imageIn = [imageIn; double(imread(pgmFile2)/16)]; % div by 16 to scale 16bit to 12bit
imageIn = [imageIn; double(imread(pgmFile3)/16)]; % div by 16 to scale 16bit to 12bit
imageIn = [imageIn; double(imread(pgmFile4)/16)]; % div by 16 to scale 16bit to 12bit
imageIn = [imageIn; double(imread(pgmFile5)/16)]; % div by 16 to scale 16bit to 12bit
imageIn = [imageIn; double(imread(pgmFile6)/16)]; % div by 16 to scale 16bit to 12bit
imageIn = [imageIn; double(imread(pgmFile7)/16)]; % div by 16 to scale 16bit to 12bit
imageIn = [imageIn; double(imread(pgmFile8)/16)]; % div by 16 to scale 16bit to 12bit
imageIn = [imageIn; double(imread(pgmFile9)/16)]; % div by 16 to scale 16bit to 12bit
imageIn = [imageIn; double(imread(pgmFile10)/16)]; % div by 16 to scale 16bit to 12bit
imageIn = [imageIn; double(imread(pgmFile11)/16)]; % div by 16 to scale 16bit to 12bit


imageIn = imageIn(:,1:columnsTotal);

% Histograms

% Total array histogram
figure();

histogram(imageIn);
xlabel('Code [LSB]');
ylabel('Density [N]');
title('Code Density Histogram');


% 2D

column = imageIn(:,analyzeColumn);

figure();
histogram(column+artOffset);

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
