function [rgbimg,imgorigin,imgmask_bb]=maskadj_reg(fluoroimg,imgmask)
global bitinfo
bitinfo=12;
%% reduce the image size that we need to deal with
cc=bwconncomp(imgmask);
boundbox=regionprops(cc,'BoundingBox');
%%
Nbb=length(boundbox);
x0=size(Nbb,1);
y0=size(Nbb,1);
x1=size(Nbb,1);
y1=size(Nbb,1);
for i=1:Nbb
    x0(i)=boundbox(i).BoundingBox(1);
    y0(i)=boundbox(i).BoundingBox(2);
    x1(i)=boundbox(i).BoundingBox(1)+boundbox(i).BoundingBox(3);
    y1(i)=boundbox(i).BoundingBox(2)+boundbox(i).BoundingBox(4);
end
%% restrict the image
imgorigin=[min(y0),min(x0),max(y1),max(x1)];
bbimg=[min(x0),min(y0),max(x1)-min(x0),max(y1)-min(y0)];
bbimg=round(bbimg);
fluoroimg_bb=fluoroimg(bbimg(2):bbimg(2)+bbimg(4),bbimg(1):bbimg(1)+bbimg(3),:);
imgmask_bb=imgmask(bbimg(2):bbimg(2)+bbimg(4),bbimg(1):bbimg(1)+bbimg(3),:);
%% erode to avoid edge
se=strel('disk',5);
imgmask_bb=imerode(imgmask_bb,se);
if bitinfo==8
    rgbimg=fluoroimg_bb.*uint8(cat(3,imgmask_bb,imgmask_bb,imgmask_bb));
elseif bitinfo==12
    rgbimg=fluoroimg_bb.*uint16(cat(3,imgmask_bb,imgmask_bb,imgmask_bb));
end