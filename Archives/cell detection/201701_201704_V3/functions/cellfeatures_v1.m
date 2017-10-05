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