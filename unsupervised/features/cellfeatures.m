function centroids=cellfeatures(bwimg)
global eccpar
bwimg=cellsize(bwimg); % filter for cell sizes
bwimg=eccentricity(bwimg,eccpar(2)); % the cell need to be more round than linear
% L=cellSNR(L,imgbit,bitinfo); % filter for SNR
cc=bwconncomp(bwimg);
rprops = regionprops(cc,'centroid');
centroids=reshape([rprops.Centroid],2,[])';