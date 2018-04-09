function [brainimg,bgimgmed]=bgmean2(fluoroimg,maskfile)
M=64;
fluimgpix=cell(3,1);
for c=1:3
    fluimg(:,:,c)=downsample_min(fluoroimg(:,:,c),M);
    fluimgpix{c}=nonzeros(fluimg(:,:,c)); % collect all nonzeros pixels
end
if exist([maskfile,'.tif'],'file')
    imgmask=imread(maskfile,'tif');
elseif exist([maskfile,'.mat'],'file')
    imgmask=load(maskfile);
    maskvar=fieldnames(imgmask);
    imgmask=getfield(imgmask,maskvar{1});
end
imgmask1=downsample_max(imgmask,M);
imgmask1=uint16(imgmask1);
% get tissue
brainimg=fluimg.*cat(3,imgmask1,imgmask1,imgmask1);
bgimgmed=zeros(3,1);
for c=1:3
    bgimgmed(c)=median(fluimgpix{c});
end