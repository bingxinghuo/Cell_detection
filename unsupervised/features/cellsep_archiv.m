<<<<<<< HEAD
<<<<<<< HEAD
% use watershed method to detect cells
function L=cellsep(L,imgbit)
idx=max(max(L));
img_mod=zeros(size(L));
L=imfill(L,'holes');
for i=1:idx
    imobj=L==i;
    imobj=imobj.*imgbit;
    imobj(isnan(imobj))=0;
    coreimg=imextendedmax(imobj,1); % 1 bit difference
    %
    imobj_c=imcomplement(imobj);
    objmask=imobj_c<0;
    se_dia=2;
    se=strel('disk',se_dia);
    objmask=imdilate(objmask,se);
    %
    obj_mod=objmask-coreimg;
img_mod=img_mod+obj_mod;
end
L=watershed(img_mod);
=======
=======
>>>>>>> d8de4ff4e0929b6fdb51e28312f63c5645b96b3d
% cellsep.m
% Bingxing Huo, Feb 2017
% This function is to separate the connected cells
% Inputs come from the output of cellpatch.m
% Inputs:
%   bwimg - a binary image that contains patches of connected cells
%   and   - a gray-scale map containing the distance map 
%   localmax - individual points of local maxima
function bwimg1=cellsep(bwimg,and,localmax)
localmax_conn=localmax.*bwimg; % local maxima of the connected cells
% generate an inverse image of the distance map
bwimg_c=255-uint8(bwimg.*and);
% impose 0 to the background and local maxima
I_mod=bwimg_c.*uint8(1-localmax_conn).*uint8(bwimg);
% apply watershed to individual regions to speed up the process
cc=bwconncomp(bwimg);
stats=regionprops(cc,'Boundingbox');
bwimg1=logical(zeros(size(bwimg)));
[xL,yL]=size(I_mod);
for n=1:length(stats)
    bbox=round(stats(n).BoundingBox);
    xmax=min(bbox(2)+bbox(4),xL);
    ymax=min(bbox(1)+bbox(3),yL);
    I_box=I_mod(bbox(2):xmax,bbox(1):ymax);
    L_box=watershed(I_box);
    L_box=L_box.*uint8(bwimg(bbox(2):xmax,bbox(1):ymax));
    bwimg1(bbox(2):xmax,bbox(1):ymax)=L_box>0;
<<<<<<< HEAD
end
>>>>>>> e5d0bdbddf523e435e56c4836761d554711cd2bd
=======
end
>>>>>>> d8de4ff4e0929b6fdb51e28312f63c5645b96b3d
