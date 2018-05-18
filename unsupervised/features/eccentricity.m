function bwimg=eccentricity(bwimg,thresh)
cc=bwconncomp(bwimg);
ecc=regionprops(cc,'Eccentricity');
idx=find([ecc.Eccentricity]<thresh);
bwimg = ismember(labelmatrix(cc),idx);  % pick out only "round" enough cell bodies
