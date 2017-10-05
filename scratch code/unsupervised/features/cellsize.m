function bwimg=cellsize(bwimg)
global sizepar
cc=bwconncomp(bwimg);
area=regionprops(cc,'Area');
idx=find([area.Area]>sizepar(1) & [area.Area]<sizepar(2));
bwimg = ismember(labelmatrix(cc),idx); % pick out only small enough cell bodies