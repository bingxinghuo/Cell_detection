%% color segmentation
function blueimg=cellcolor(bwimg,rgbimg)
cc=bwconncomp(bwimg);
stats=regionprops(cc,'Boundingbox');
blueimg=logical(zeros(size(bwimg)));
[xL,yL]=size(bwimg);
for n=1:length(stats)
    bbox=round(stats(n).BoundingBox);
    xmax=min(bbox(2)+bbox(4),xL);
    ymax=min(bbox(1)+bbox(3),yL);
    rgbbox=rgbimg(bbox(2):xmax,bbox(1):ymax,:);
    hsvimg=rgb2hsv(rgbbox);
    bluemask=hsvimg(:,:,1)>.5 & hsvimg(:,:,1)<.75; % from cyan to violet, all consider to be blue
    blue_box=rgbbox(:,:,3).*uint16(bluemask);
    blueimg(bbox(2):xmax,bbox(1):ymax,:)=blue_box>0;
end
