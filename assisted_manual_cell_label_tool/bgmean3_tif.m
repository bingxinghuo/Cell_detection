function bgimgmed=bgmean3_tif(tifimg,tifmask)
% Adjust background on, based on bgmean3.m
% This script is specifically for using small tif images to calculate the
% background intensity median
% get tissue
threshmask=tifimg<50; % threshold for forground/backgrond distinction
% threshold background
tifimg=tifimg.*cast(threshmask,'like',tifimg);
tifmask=cast(tifmask,'like',tifimg);
brainimg=tifimg.*cat(3,tifmask,tifmask,tifmask);
% calculate median
fluimgpix=cell(3,1);
bgimgmed=zeros(3,1);
for c=1:3
    fluimgpix{c}=nonzeros(brainimg(:,:,c)); % collect all nonzeros pixels
    bgimgmed(c)=median(fluimgpix{c});
end