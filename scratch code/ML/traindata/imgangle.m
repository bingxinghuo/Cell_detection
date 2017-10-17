function [radius,angles]=imgangle(rgbimg)
[rows,cols,~]=size(rgbimg);
rgbimg=reshape(rgbimg,rows*cols,3,1);
rgbimg=rgbimg(rgbimg(:,1)>0,:);
rgbimg=double(rgbimg);
angles=acos(rgbimg./(sqrt(sum(rgbimg.^2,2))*ones(1,3)));
radius=sqrt(sum(rgbimg.^2,2));
