%% mask generation for the large registered jp2 images
function imgmask=brainmaskfun_nissl(nisslimg)
%% 1. convert to binary
%  collect all the info in 3 channels
nisslimg1=mean(nisslimg,3);  
    nisslimg1=uint8(nisslimg1);
    level=multithresh(nisslimg1,2);
    dimg=nisslimg1<level(2);
%%
dimg=imfill(dimg,'holes');
dimg=bwareaopen(dimg,50);
cc=bwconncomp(dimg);
% [rows,cols]=size(dimg);
totpix=sum(sum(dimg));
num=cellfun(@numel,cc.PixelIdxList);
idx=find(num>totpix*.01); % due to the expansion of the image space, take 0.01% as the threshold
imgmask=ismember(labelmatrix(cc),idx);

%%

