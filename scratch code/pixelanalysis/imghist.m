%% imghist.m
% This script interactively show the histogram and SNR within the selected area of an image
function [partialimg,pos,N,X]=imghist(originimg)
figure
%% Left panel shows the image
imagesc(originimg,[0 2^12])
axis image
axis off
title('Please select an ROI','fontsize',20)
roicheck='n';
roi=[];
while roicheck=='n'
    if ~isempty(roi)
        delete(roi)
    end
roi=imrect(gca);
pos=getPosition(roi);
pos=round(pos);
roicheck=input('Are you sure of your selection? (y/n) ','s');
end
ax1=subplot(1,3,1);
partialimg=originimg(pos(2):pos(2)+pos(4),pos(1):pos(1)+pos(3));
partialimg1=log2(single(partialimg));
% original image
imagesc(partialimg1,[0 12])
colormap gray
axis image
axis off
%% Right panel shows the histogram
ax3=subplot(1,3,3); 
[N,X]=pixelhistview1(partialimg);
maxind=find(N==max(N));
ylims=get(ax3,'ylim');
line(ax3,[X(maxind),X(maxind)],ylims,'color','r')
set(ax3,'XTick',sort([X(maxind),get(ax3,'XTick')])); % add the tick
%
ax2=subplot(1,3,2);
imagesc(partialimg1,[0 12])
colormap gray
axis image
axis off
caxis(ax2,[X(maxind),12])
%% signal-to-noise ratio
cell=partialimg1(partialimg1>=X(maxind));
bg=partialimg1(partialimg1<X(maxind));
mean(single(cell))/mean(single(bg))