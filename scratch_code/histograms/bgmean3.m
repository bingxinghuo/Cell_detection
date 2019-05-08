function [brainimg,bgimgmed]=bgmean3(imgfile,maskfile)
M=64;
rgbimg=imread(imgfile);
threshmask=rgbimg<50; % threshold for forground/backgrond distinction
% threshold background
rgbimg=rgbimg.*cast(threshmask,'like',rgbimg);
% background mask
if exist([maskfile,'.tif'],'file')
    imgmask=imread(maskfile,'tif');
elseif exist([maskfile,'.mat'],'file')
    imgmask=load(maskfile);
    maskvar=fieldnames(imgmask);
    imgmask=getfield(imgmask,maskvar{1});
end
imgmask1=downsample_max(imgmask,M,M);
imgmask1=cast(imgmask1,'like',rgbimg);
% get tissue
brainimg=rgbimg.*cat(3,imgmask1,imgmask1,imgmask1);
% calculate median
fluimgpix=cell(3,1);
bgimgmed=zeros(3,1);
for c=1:3
    fluimgpix{c}=nonzeros(brainimg(:,:,c)); % collect all nonzeros pixels
    bgimgmed(c)=median(fluimgpix{c});
end