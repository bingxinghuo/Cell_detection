H=size(fluoroimg,1);
W=size(fluoroimg,2);
win.width=500; % columns
win.height=400; % rows
figure, imagesc(blue)
area=imrect(gca,[round(H/2),round(W/2),win.width,win.height]); % pre-define a box size, moveable and draggable
% area=imrect;
pause % this is a trick just to let the box moveable and draggable in Matlab
okarea=input(['Region ok? (y/n) '],'s'); % confirm
pos=getPosition(area);
pos=round(pos);
xedge=[pos(1),pos(1)+pos(3)];
yedge=[pos(2),pos(2)+pos(4)];
    imgtemp_rgb=fluoroimg(yedge(1):yedge(2),xedge(1):xedge(2),:);
    hsvimg=rgb2hsv(imgtemp_rgb); % convert to hsv image
        hsvimg(:,:,3)=hsvimg(:,:,3)*100; % adjust intensity map
        newrgb=uint16(hsv2rgb(hsvimg)*2^16);
%%
figure('Color',[0 0 0]) % black background for easier visualization of fluorescent images
for i=1:2
    axind{i}=subplot(1,2,i);
    imagesc(newrgb); axis image; axis off
    hold on
end
linkaxes([axind{1};axind{2}])
%%
FBautocell=centroids1;
% find the x and y coordinates of cell bodies within the current window
automasky=(FBautocell(:,2)>yedge(1)).*(FBautocell(:,2)<=min(yedge(2),H));
automaskx=(FBautocell(:,1)>xedge(1)).*(FBautocell(:,1)<=min(xedge(2),W));
automask=automaskx.*automasky; % both x and y coordinates need to be inside the window
ind=find(automask==1); % identify the indices of cells
if ~isempty(ind)
%    scatter(axind{1},FBautocell(ind,1)-xedge(1),FBautocell(ind,2)-yedge(1),'r*')
 scatter(axind{2},FBautocell(ind,1)-xedge(1),FBautocell(ind,2)-yedge(1),'m*')
end