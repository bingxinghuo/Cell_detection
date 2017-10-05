%% cellmask.m
% Bingxing Huo, August 2016
% Version 5
% This code automatically detects the brain slice in the 12-bit fluorescent image
% and saves the mask as a .mat file.
function imgmask=brainmaskfun_16bit(fluoroimg)
%% 1. adjust image
% 1.1 convert color scale
fluoroimg1=single(fluoroimg)/2^12*2^8;
% 1.2 collect all the info in 3 channels
fluoroimg2=sum(fluoroimg1,3);
% 1.3 Gaussian filter
% for newer version of Matlab
% fluoroimg3=imgaussfilt(fluoroimg2,5);
% for older version of Matlab
sigma=5;
fluoroimg3 = imfilter(fluoroimg2,fspecial('gaussian',2*ceil(2*sigma)+1, sigma),'replicate');
% 1.4 Remove background noise by thresholding
dimg=fluoroimg3>20; % this is a manual threshold 
% 1.5 adjust the binary image
dimg=imfill(dimg,'holes');
dimg=bwareaopen(dimg,50);
%% 2. find objects
L=bwlabel(dimg);
rows=size(fluoroimg,1);
columns=size(fluoroimg,2);
% 2.1 Obtain the connectivity information
CC=bwconncomp(dimg);
% 2.2 Obtain the area of each object
num=zeros(CC.NumObjects,1);
for i=1:CC.NumObjects
    num(i)=length(CC.PixelIdxList{i});
end
%% 2.3 Threshold the area of each object
totpix=rows*columns;
[num1,numind]=find(num>totpix*.01); % the object is at least 0.1% of the whole image
imgmask=logical(zeros(rows, columns,'single')); % generate a blank binary image
parfor i=1:length(num1)
    imgmask=imgmask+(L==num1(i)); % include the object
end
