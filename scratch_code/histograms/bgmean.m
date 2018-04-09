%% bgmean.m
% This function accompanies contrastadj1.m
% calculate the mean of background in downsampled image
function bgimgmed=bgmean(tiffile,maskfile)
M=64;
fluimg=imread(tiffile);
[rows,cols,~]=size(fluimg);
% imgmask=imread(maskfile,'tif');
imgmask=load(maskfile);
maskvar=fieldnames(imgmask);
imgmask=getfield(imgmask,maskvar{1});
imgmask1=downsample_max(imgmask,M);
[rows1,cols1]=size(imgmask1);
if rows1>rows
    imgmask1=imgmask1(1:rows,:);
end
if cols1>cols
    imgmask1=imgmask1(:,1:cols);
end
% 2. generate background
se1=strel('disk',5);
imgmask1=imdilate(imgmask1,se1); % increase the size of the mask
imgmask1=uint16(imgmask1);
bgimg=fluimg.*cat(3,1-imgmask1,1-imgmask1,1-imgmask1); % background
se2=strel('disk',2);
bgimgmed=zeros(3,1);
for c=1:3
    bgimg(:,:,c)=imerode(bgimg(:,:,c),se2); % remove speckles
    bgimgmed(c)=mean(mean(bgimg(:,:,c)));
end