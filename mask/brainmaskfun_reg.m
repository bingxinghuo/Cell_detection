%% mask generation for the large registered jp2 images
function imgmask=brainmaskfun_reg(fluoroimg,resolution)
%% 1. convert to binary
%  collect all the info in 3 channels
fluoroimg1=sum(fluoroimg,3);
if isa(fluoroimg,'uint8')
    bitinfo=8;
    level=graythresh(fluoroimg1);
    dimg=fluoroimg1>2^bitinfo*level;
elseif isa(fluoroimg,'uint16')
    fluoroimg1=uint8(fluoroimg1);
    level=multithresh(fluoroimg1,2);
    dimg=fluoroimg1>level(1);
end
%%
dimg=imfill(dimg,'holes');
dimg=bwareaopen(dimg,round(50/resolution));
cc=bwconncomp(dimg);
% [rows,cols]=size(dimg);
totpix=sum(sum(dimg));
num=cellfun(@numel,cc.PixelIdxList);
idx=find(num>totpix*.01); % due to the expansion of the image space, take 0.01% as the threshold
imgmask=ismember(labelmatrix(cc),idx);

%%

