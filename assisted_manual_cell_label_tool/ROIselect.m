function [rgbimg,ROIpos1]=ROIselect(fullimg,fullimgds,dsrate)
% 
figure, imagesc(uint8(fullimgds))
ROIhandle=imrect(gca);
ROIpos=getPosition(ROIhandle);
ROIpos=round(ROIpos);
ROIpos1=ROIpos*dsrate;
rgbimg=fullimg(ROIpos1(2):ROIpos1(2)+ROIpos1(4),ROIpos1(1):ROIpos1(1)+ROIpos1(3),:);
close