function bwimg=cellsize(bwimg)
global sizepar
cc=bwconncomp(bwimg);
area=regionprops(cc,'Area');
% if area(k).Area < (2/.46)^2*pi   % cell diameter > 4 microns, with 0.46 microns/pixel resolution
%         idx(k)=0; % remove the index
%     end
idx=find([area.Area]>sizepar(1) & [area.Area]<sizepar(2));
bwimg = ismember(labelmatrix(cc),idx); % pick out only small enough cell bodies
