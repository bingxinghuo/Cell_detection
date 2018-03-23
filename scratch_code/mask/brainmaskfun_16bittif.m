%% brainmaskfun_16bittif.m
% Bingxing Huo, March 2018
% modified from brainmaskfun_16bit.m
% This code automatically detects the brain slice in the 12-bit fluorescent image
% and saves the mask as a .mat file.
function imgmask0=brainmaskfun_16bittif(jp2file,tifdir,jp2dir)
fluorotif=[tifdir,jp2file(1:end-4),'.tif'];
fluimg=imread(fluorotif,'tif');
[rows,cols,~]=size(fluimg);
imgmask=false(rows, columns);
%% 1. adjust image
% 1.1 convert color scale
fluoroimg1=single(fluimg)/2^12*2^8;
% 1.2 collect all the info in 3 channels
fluoroimg2=sum(fluoroimg1,3);
% 1.3 Gaussian filter
% for newer version of Matlab
% fluoroimg3=imgaussfilt(fluoroimg2,5);
% for older version of Matlab
sigma=1;
fluoroimg3 = imfilter(fluoroimg2,fspecial('gaussian',2*ceil(2*sigma)+1, sigma),'replicate');
%% 1.4 Remove background noise by thresholding
fluoropix=reshape(fluoroimg3,rows*columns,1);
fluoropixbit=log2(fluoropix);
[n,x]=hist(fluoropixbit,100); % generate a histogram of the image
% gaussian smoothing
w=gausswin(5);
n1=conv(n,w,'same');
% find the end of first groove in the histogram
N=diff(n1);
k=1;
Ncross=[];
for i=2:length(N)
    if N(i-1)<0 && N(i)>0
        Ncross(k)=i;
        k=k+1;
    end
end
if ~isempty(Ncross)
    thresh=x(Ncross(1));
    dimg=fluoroimg3>2^thresh; % include only the second mode in the image histogram
    % 1.5 adjust the binary image
    dimg=imfill(dimg,'holes');
    dimg=bwareaopen(dimg,100);
    %% 2. find objects
    L=bwlabel(dimg);
    % 2.1 Obtain the connectivity information
    CC=bwconncomp(dimg);
    % 2.2 Obtain the area of each object
    num=zeros(CC.NumObjects,1);
    for i=1:CC.NumObjects
        num(i)=length(CC.PixelIdxList{i});
    end
    % 2.3 Threshold the area of each object
    totpix=rows*columns;
    [num1,numind]=find(num>totpix*.0001); % the object is at least 0.1% of the whole image
    % generate a blank binary image
    for i=1:length(num1)
        imgmask=imgmask+(L==num1(i)); % include the object
    end
    imgmask=logical(imgmask);
    se=strel('disk',4);
    imgmask=imerode(imgmask,se); % erode the outline to avoid pial vessels and dura
end
%% convert back to original resolution
imgsize=imfinfo([jp2dir,jp2file]);
imgwidth=imgsize.Width;
imgheight=imgsize.Height;
imgmask0=false(imgheight, imgwidth);
imgmask1=repelem(imgmask,M,M);
[rows,cols]=size(imgmask1);
if rows>imgheight
    imgmask1=imgmask1(1:imgheight,:);
end
if cols>imgwidth
    imgmask1=imgmask1(:,1:imgwidth);
end
imgmask0(1:imgheight,1:imgwidth)=imgmask1;
% smooth the mask edge
% sigma=10;
% imgmask0 = imfilter(imgmask0,fspecial('gaussian',2*ceil(2*sigma)+1, sigma),'replicate');
