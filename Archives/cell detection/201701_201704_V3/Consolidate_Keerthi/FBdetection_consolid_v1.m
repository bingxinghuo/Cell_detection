%% consolidating Keerthi's and Bingxing's code
function centroids1=FBdetection_consolid_v1(fluoroimg)
%% 1. adjust image intensity
blue=fluoroimg(:,:,3)-max(fluoroimg(:,:,1),fluoroimg(:,:,2)); % blueness
% This imadjust does not seem work well especially close to injection area
% blue_adj=imadjust(blue,[2^5;2^12-1]./(2^16-1),[0;2^8-1]./(2^16-1),.8);
% blue8=uint8(blue); % convert to 8-bit
%% remove background method 1: gaussian filter + intensity, size
bg=imgaussfilt(blue,20); % generate background
img_nobak=blue-bg; % remove background
thresh=imgcutoff(single(img_nobak),12); % custom threshold based on the image
bwimg=img_nobak>=thresh; %  thershold intensity
bwimg=bwareaopen(bwimg,60); % remove small connected areas (one cell size)
bwimg=imfill(bwimg,'holes'); % fill holes
%% remove background method 2: top hat + intensity, size & eccentricity
% dia = 51;
% [~,~,bwimg] = detect_bright_spots(blue8,dia);
%% Sukhendu's post processing
bwimg_smooth=imgaussfilt(single(bwimg),.85);
bwimg=im2bw(bwimg_smooth);
edg = edge(bwimg); % generate edges of cells
dist_tr = bwdist(edg); % generate the distance intensity map
and = bwimg.*dist_tr; % reconstruct
% method 1
ind2=imregionalmax(and);
cc=bwconncomp(ind2,8);
rprops = regionprops(cc,'centroid');
centroids=reshape([rprops.Centroid],2,[])';
%% method 2
% D=-and;
% D(~bwimg)=-Inf;
% L=watershed(D);
% S=regionprops(L,'Centroid'); % get the centroids
% centroids=cat(1,S.Centroid); % assemble the centroids
% centroids=centdistfilt(centroids); % cell center distance
%% filter centroid distance
centroids1=centdistfilt(centroids);