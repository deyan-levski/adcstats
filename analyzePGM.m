clc;
clear all;
close all;

useUSBStream = 1;

analyzeColumn = 10;
columnsTotal = 128; %1024

doTotalArrayHist = 0;
do3DTotalArrayHist = 0;

doMeanOfCols = 0;
doColumnHist = 1;
doColumnProfile = 0;
doDNLLinearRamp = 0;
doCalcCFPN = 0;
doCalcCompNoise = 0;
doDNLINLHist = 1;
doDNLINLHist3d = 0;


if useUSBStream == 0

%pgmFile = 'snapshots/DNL/snapshot000-w-dcds-2x-gain.pgm';
pgmFile = '/media/storage/simdrive/streams/noise/snapshot000-no-dcds.pgm';
%pgmFile = 'measure/snapshot001.pgm';
%pgmFile = 'measure/snapshot000.pgm';
analyzeColumn = 44;
columnsTotal = 128; %1024

   imageIn = [];
   
%    pgmFile = 'snapshots/DNL/F/snapshot';
%    for a = 0:99
%       filename = [pgmFile num2str(a,'%03d') '.pgm'];
%       img = imread(filename);
%       % do something with img
%       imageIn = [imageIn; double(imread(filename)/16)]; % div by 16 to scale 16bit to 12bit
%    end
 
imageIn = double(fix(imread(pgmFile)/16)); % div by 16 to scale 16bit to 12bit
imageIn = imageIn(:,1:columnsTotal);

else
    
    %data = dlmread('/media/storage/simdrive/streams/250M/stream250M_50-HIST-227Hz-CAT.csv',',',1,0);
    %data = dlmread('/media/storage/simdrive/streams/250M/stream250M_58-HIST-71Hz-CAT.csv',',',1,0);
    data = dlmread('/media/storage/simdrive/streams/250M/nonlinear/nonlin4.csv',',',1,0);
    %data = dlmread('/media/storage/simdrive/streams/250M/cat.csv',',',1,0);
    %data = dlmread('/media/storage/simdrive/streams/250M/cat-256.csv',',',1,0);
    
    imageIn = data(:,2);
    %imageIn = data;    
    
end
    
%% Histograms

% Total array histogram
if doTotalArrayHist == 1
figure();
bins = max(max(imageIn)) - min(min(imageIn));
histogram(imageIn, bins);
xlabel('Code [LSB]');
ylabel('Density [N]');
title('Code Density Histogram');
end;

% Calculate CFPN in %
if doCalcCFPN == 1
    
    for u = 1:columnsTotal
        meanCol(u) = mean(imageIn(:,u));
    end
    
    maxMeanCol = max(meanCol);
    minMeanCol = min(meanCol);
    
    CFPN = (((maxMeanCol - minMeanCol)/4096)*100)/3.5;
    
    figure();    
    plot(meanCol);
    xlabel('Column Nr');
    ylabel('Mean Magnitude (avgd)');
    title(['Column Fixed Pattern Noise: ' num2str(CFPN) ' %']);
end;

% Calculate comparator noise

if doCalcCompNoise == 1
    
    compNoise = (imageIn(:,analyzeColumn) - mean(imageIn(:,analyzeColumn))) - (imageIn(:,analyzeColumn+1) - mean(imageIn(:,analyzeColumn+1)))/2; % subtract adjacent columns, 60/61 in this case
    %indices = find(abs(compNoise)>3.5);
    %compNoise(indices) = [];
    %indices = find(abs(compNoise)<-3.5);
    %compNoise(indices) = [];
    
    figure();
    bins = max(compNoise) - min(compNoise);
    histogram(compNoise, bins);
    histfit(compNoise, bins, 'normal');
    meanColumn = mean(compNoise);
    stdColumn = std(compNoise);
    varColumn = var(compNoise);

    xlabel(['Mean: ' num2str(meanColumn) '; Stdev: ' num2str(stdColumn) '; Var: ' num2str(varColumn) ]);
    ylabel('N');
    title(['Comparator Output Noise, cols(' num2str(analyzeColumn) '/' num2str(analyzeColumn+1) ')']);
    
    % Full group for paper in uV
    %
    %kb = 1:128;
    %bar(kb,(stdImgIn-0.5)*0.000317)
    
    
    
    
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
    
    bins = 50;
    
% 3D
[count,bins] = hist(imageIn, bins);

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
  %plot(dnl);
  stem(dnl,'Marker', 'none');
  grid on;
  xlabel('Code /w offset');
  ylabel('DNL [LSB]');
  %ylim([-2 3]);
  %xlim([0 4096]);
  
  figure();
  plot(inl);
  grid on;
  xlabel('Code /w offset');
  ylabel('INL [LSB]');
  xlim([0 4096]);
  
  for y=1:length(dnl)
      
     if dnl(y) > 0.4
     dnl(y) = dnl(y)*0.65;
     else
     dnl(y) = dnl(y);
     end
           
  end
  
  figure();
  %plot(dnl);
  stem(dnl,'Marker', 'none');
  grid on;
  xlabel('Code /w offset and compensation');
  ylabel('DNL [LSB]');
  ylim([-2 2]);
  xlim([0 4096]);
  
  end
 
  
  if doDNLINLHist3d == 1

	  for r = 2:columnsTotal+1

	[dnl{r},inl{r}] = dnl_inl_sin(imageIn(:,r));

        dnl{r} = [dnl{r} zeros(size(dnl{r},1),4096-length(dnl{r}))]; % fill-in with zeros to 4096
           
      end
      
      %dnl(:,1) = []; % removing first cell element
      
      for y=1:length(dnl)
      
          for r=1:length(dnl{y})
          
            if dnl{y}(r) > 0.4
            dnl{y}(r) = dnl{y}(r)*0.55;
            elseif dnl{y}(r) < (-0.4)
            dnl{y}(r) = dnl{y}(r)*0.65;
            elseif dnl{y}(r) > 1.05
            dnl{y}(r) = dnl{y}(r)*0.65;    
            else
            dnl{y}(r) = dnl{y}(r);
            end
		
          end
          
      end
      
      [X,Y] = meshgrid(1:1:4096,1:columnsTotal);   
      B1 = cell2mat(arrayfun(@(x)permute(x{:},[2 1]),dnl,'UniformOutput',false));
      
      %surf(X,Y,rot90(B1));
      %stem3(X,Y,rot90(B1),'Marker','none');
      imagesc(X(1,:),Y(1,:),rot90(B1));
      xlabel('Code /w offset');
      ylabel('Column');
      %zlabel('DNL');
      title('Surface plot of DNL for 128 columns');
      
      %daspect([1,1,.3]);axis tight;
      %OptionZ.FrameRate=15;OptionZ.Duration=5.5;OptionZ.Periodic=true;
      %CaptureFigVid([0,95;-259,775], 'VidTest1',OptionZ)

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


%% Capture 3D rotating DNL surface plot video


function CaptureFigVid(ViewZ, FileName,OptionZ)
% CaptureFigVid(ViewZ, FileName,OptionZ) 
% Captures a video of the 3D plot in the current axis as it rotates based
% on ViewZ and saves it as 'FileName.mpg'. Option can be specified.
% 
% ViewZ:     N-rows with 2 columns, each row are the view angles in 
%            degrees, First column is azimuth (pan), Second is elevation
%            (tilt) values outside of 0-360 wrap without error, 
%            *If a duration is specified, angles are used as nodes and
%            views are equally spaced between them (other interpolation
%            could be implemented, if someone feels so ambitious). 
%            *If only an initial and final view is given, and no duration,
%            then the default is 100 frames. 
% FileName:  Name of the file of the produced animation. Because I wrote
%            the program, I get to pick my default of mpg-4, and the file
%            extension .mpg will be appended, even if the filename includes
%            another file extension. File is saved in the working
%            directory.
% (OptionZ): Optional input to specify parameters. The ones I use are given
%            below. Feel free to add your own. Any or all fields can be
%            used 
% OptionZ.FrameRate: Specify the frame rate of the final video (e.g. 30;) 
% OptionZ.Duration: Specify the length of video in seconds (overrides
%    spacing of view angles) (e.g. 3.5;) 
% OptionZ.Periodic: Logical to indicate if the video should be periodic.
%    Using this removed the final view so that when the video repeats the
%    initial and final view are not the same. Avoids having to find the
%    interval between view angles. (e.g. true;) 
% 
% % % % Example (shown in published results, video attached) % % % %
% figure(171);clf;
% surf(peaks,'EdgeColor','none','FaceColor','interp','FaceLighting','phong')
% daspect([1,1,.3]);axis tight;
% OptionZ.FrameRate=15;OptionZ.Duration=5.5;OptionZ.Periodic=true;
% CaptureFigVid([-20,10;-110,10;-190,80;-290,10;-380,10],'WellMadeVid',OptionZ)
% 
% Known issues: MPEG-4 video option only available on Windows machines. See
% fix where the VideoWriter is called.
% 
% Getframe is used to capture image and current figure must be on monitor 1
% if multiple displays are used. Does not work if no display is used.
% 
% Active windows that overlay the figure are captured in the movie.  Set up
% the current figure prior to calling the function. If you don't specify
% properties, such as tick marks and aspect ratios, they will likely change
% with the rotation for an undesirable effect.

% Cheers, Dr. Alan Jennings, Research assistant professor, 
% Department of Aeronautics and Astronautics, Air Force Institute of Technology

%% preliminaries 

% initialize optional argument
if nargin<3;     OptionZ=struct([]); end

% check orientation of ViewZ, should be two columns and >=2 rows
if size(ViewZ,2)>size(ViewZ,1); ViewZ=ViewZ.'; end
if size(ViewZ,2)>2
warning('AJennings:VidWrite',...
    'Views should have n rows and only 2 columns. Deleting extraneous input.');
ViewZ=ViewZ(:,1:2); %remove any extra columns
end

% Create video object 
daObj=VideoWriter(FileName,'MPEG-4'); %my preferred format
% daObj=VideoWriter(FileName); %for default video format. 
% MPEG-4 CANNOT BE USED ON UNIX MACHINES
% set values: 
% Frame rate
if isfield(OptionZ,'FrameRate')
    daObj.FrameRate=OptionZ.FrameRate;
end
% Durration (if frame rate not set, based on default)
if isfield(OptionZ,'Duration') %space out view angles
    temp_n=round(OptionZ.Duration*daObj.FrameRate); % number frames
    temp_p=(temp_n-1)/(size(ViewZ,1)-1); % length of each interval
    ViewZ_new=zeros(temp_n,2);
    % space view angles, if needed
    for inis=1:(size(ViewZ,1)-1)
        ViewZ_new(round(temp_p*(inis-1)+1):round(temp_p*inis+1),:)=...
            [linspace(ViewZ(inis,1),ViewZ(inis+1,1),...
             round(temp_p*inis)-round(temp_p*(inis-1))+1).',...
             linspace(ViewZ(inis,2),ViewZ(inis+1,2),...
             round(temp_p*inis)-round(temp_p*(inis-1))+1).'];
    end
    ViewZ=ViewZ_new;
end
% space view angles, if needed
if length(ViewZ)==2 % only initial and final given
    ViewZ=[linspace(ViewZ(1,1),ViewZ(end,1)).',...
           linspace(ViewZ(1,2),ViewZ(end,2)).'];
end
% Periodicity
if isfield(OptionZ,'Periodic')&&OptionZ.Periodic==true 
ViewZ=ViewZ(1:(end-1),:); %remove last sample
end
% open object, preparatory to making the video
open(daObj);

%% rotate the axis and capture the video
for kathy=1:size(ViewZ,1)
    view(ViewZ(kathy,:)); drawnow;
    writeVideo(daObj,getframe(gcf)); %use figure, since axis changes size based on view
end

%% clean up
close(daObj);

end


