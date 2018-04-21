<<<<<<< HEAD
function centroids=cellfeatures(bwimg,imgbit,eccpar,i)
L=bwlabeln(bwimg); % label all objects in the image
if i==2 % large patches
    L=eccentricity(L,eccpar(1)); % as long as they are not a line
    L=cellsep(L,imgbit); % watershed method
end
L=cellsize(L); % filter for cell sizes
L=eccentricity(L,eccpar(2)); % the cell need to be more round than linear
L=cellSNR(L,imgbit,bitinfo); % filter for SNR
S=regionprops(L,'Centroid'); % get the centroids
centroids=cat(1,S.Centroid); % assemble the centroids
centroids=centdistfilt(centroids); % cell center distance
=======
function centroids=cellfeatures(bwimg)
global eccpar
bwimg=cellsize(bwimg); % filter for cell sizes
bwimg=eccentricity(bwimg,eccpar(2)); % the cell need to be more round than linear
% L=cellSNR(L,imgbit,bitinfo); % filter for SNR
cc=bwconncomp(bwimg);
rprops = regionprops(cc,'centroid');
centroids=reshape([rprops.Centroid],2,[])';
>>>>>>> e5d0bdbddf523e435e56c4836761d554711cd2bd
