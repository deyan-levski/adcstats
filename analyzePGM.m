clc;
clear all;
close all;

useUSBStream = 0;

analyzeColumn = 39;
columnsTotal = 1024; %1024

doTotalArrayHist = 0;
do3DTotalArrayHist = 0;
doMeanOfCols = 1;
doColumnHist = 1;
doColumnProfile = 1;
doDNLLinearRamp = 0;
doDNLINLHist = 0;


if useUSBStream == 0

pgmFile = 'snapshots/DNL/snapshot000-w-dcds-2x-gain.pgm';


%   imageIn = [];
%   
%    pgmFile = 'snapshots/DNL/F/snapshot';
%    for a = 0:99
%       filename = [pgmFile num2str(a,'%03d') '.pgm'];
%       img = imread(filename);
%       % do something with img
%       imageIn = [imageIn; double(imread(filename)/16)]; % div by 16 to scale 16bit to 12bit
%    end
 
imageIn = double(imread(pgmFile)/16); % div by 16 to scale 16bit to 12bit
imageIn = imageIn(:,1:columnsTotal);

else
    
    data = dlmread('/media/storage/simdrive/streams/250M/stream250M_50-HIST-227Hz-CAT.csv',',',1,0);
    imageIn = data(:,2);
    
end
    
%% Histograms

% Total array histogram
if doTotalArrayHist == 1
figure();
bins = max(max(imageIn)) - min(min(imageIn));
histogram(imageIn, round(bins/4));
xlabel('Code [LSB]');
ylabel('Density [N]');
title('Code Density Histogram');
end;


% 2D Histogram
if useUSBStream == 0
column = imageIn(:,analyzeColumn);
bins = max(column) - min(column);
else
column = imageIn;
bins = max(column) - min(column);
end

if doColumnHist == 1
    
figure();
histogram(column, bins);
histfit(column,bins,'normal');
meanColumn = mean(column);
stdColumn = std(column);
varColumn = var(column);

xlabel(['Mean: ' num2str(meanColumn) '; Stdev: ' num2str(stdColumn) '; Var: ' num2str(varColumn) ]);
ylabel('N');
title(['Noise spread for column: ' num2str(analyzeColumn)]);

end;

    
if doColumnProfile == 1
% 2D Column Profile
figure();
L = stairs(column);
grid on;
L = get(gca,'YTickLabel');
set(gca,'YTickLabel',cellfun(@(x) dec2bin(str2num(x),12),L,'UniformOutput',false));

zh = zoom(gcf);
set(zh,'ActionPreCallBack',@(source,event,s) set(gca,'YTickLabelMode','auto'))
set(zh,'ActionPostCallBack',@(source,event,s) set(gca,'YTickLabel',cellfun(@(x) dec2bin(str2num(x)),get(gca,'YTickLabel'),'UniformOutput',false)));

xlabel('Sample');
ylabel('Code');
title(['Column profile for column: ' num2str(analyzeColumn)]);

end;

if do3DTotalArrayHist == 1
    
% 3D
[count,bins] = hist(imageIn, 25);

figure();

b = bar3c(bins, count, 'detatched');
xlabel('Column Nr (X)');
ylabel('DN (Y)');
zlabel('Occurrences N (Z)');

binColumn = dec2bin(column)-'0';

end;

% Analyze column FPN

if doMeanOfCols == 1 
for k = 1:columnsTotal
  
  column = imageIn(:,k);
  
  meanColumn(k) = mean(column);
  
end
  figure();  
  plot(meanColumn);
  xlabel('Column ADC Nr (X)');
  xlim([0 columnsTotal]);
  ylabel(['Mean value of column over ' num2str(length(column)) ' samples']);
  title(['Mean columns (X) for ' num2str(length(column)) ' samples']);
end
  
  % Analyze DNL Linear Ramp Method
  
  if doDNLLinearRamp == 1
      
  column = imageIn(:,analyzeColumn);
  colSamples = length(column);
  hitsTheory = colSamples/(2^12 - 2);
  figure();
  
  H = histogram(column,(max(column)-min(column)));
  
  DNL = (H.Values/hitsTheory) - 1;
  close();
   
  figure();
  plot(DNL);
  xlabel('Code /w offset');
  ylabel('DNL [LSB]');
  title(['Differential Nonlinearity for column: ' num2str(analyzeColumn)]);
  
  figure();
  imageIn = imageIn(:,1:columnsTotal);
  [x y] = size(imageIn);
  colSamples = x*y;
  hitsTheory = colSamples/(2^12 - 2);

  bins = max(max(imageIn)) - min(min(imageIn));
  D = histogram(imageIn, bins);
 
  DNL = D.Values/hitsTheory - 1;
  close();
   
  figure();
  plot(DNL);
  xlabel('Code /w offset');
  ylabel('DNL [LSB]');
  title(['Differential Nonlinearity for array set of: ' num2str(columnsTotal) ' columns or ' num2str(colSamples) ' samples']);
  
  end
  
  
  if doDNLINLHist == 1
  
[dnl,inl] = dnl_inl_sin(imageIn);

  figure();
  plot(dnl);
  grid on;
  xlabel('Code /w offset');
  ylabel('DNL [LSB]');
  
  figure();
  plot(inl);
  grid on;
  xlabel('Code /w offset');
  ylabel('INL [LSB]');
  
  
  for y=1:length(dnl)
      
     if dnl(y) > 0.4
     dnl(y) = dnl(y)*0.65;
     else
     dnl(y) = dnl(y);
     end
           
  end
  
  figure();
  plot(dnl);
  grid on;
  xlabel('Code /w offset and compensation');
  ylabel('DNL [LSB]');
  
  end
  
  
function [dnl,inl] = dnl_inl_sin(y)
%DNL_INL_SIN
% dnl and inl ADC output
% input y contains the ADC output
% vector obtained from quantizing a
% sinusoid
% Boris Murmann, Aug 2002
% Bernhard Boser, Sept 2002
% histogram boundaries
minbin=min(y);
maxbin=max(y);
% histogram
h = hist(y, minbin:maxbin);
% cumulative histogram
ch = cumsum(h);
% transition levels
T = -cos(pi*ch/sum(h));
% linearized histogram
hlin = T(2:end) - T(1:end-1);
% truncate at least first and last
% bin, more if input did not clip ADC
trunc=2;
hlin_trunc = hlin(1+trunc:end-trunc);
% calculate lsb size and dnl
lsb= sum(hlin_trunc) / (length(hlin_trunc));
dnl= [0 hlin_trunc/lsb-1];
misscodes = length(find(dnl<-0.9));
% calculate inl
inl= cumsum(dnl);
end