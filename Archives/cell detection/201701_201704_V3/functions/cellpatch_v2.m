function [bwimg_patch,and,localmax]=cellpatch(bwimg)
global  sigma
%% initialize
bwimg_patch=cell(2,1);
%% 1. Sukhendu's transformation
% 1.1 Detect object perimeter
% denoise
% bwimg_smooth=imgaussfilt(single(bwimg),sigma(2));
bwimg_smooth=imfilter(single(bwimg),fspecial('gaussian',2*ceil(2*sigma(2))+1, sigma(2)),'same');
bwimg1=im2bw(bwimg_smooth); % convert to binary
edg = bwperim(bwimg1); % generate edges of cells
% 1.2. Generate distance matrix
dist_tr = bwdist(edg); % generate the distance intensity map
% 1.3. Combine the mask and distance matrix
and = bwimg1.*dist_tr; % reconstruct
and(isnan(and))=0;
% ind=imgaussfilt(and,sigma(2)); % denoise
ind=imfilter(single(and),fspecial('gaussian',2*ceil(2*sigma(2))+1, sigma(2)),'same');
%% 2. detect bright spots
% 2.1 get regional maxima
localmax=imregionalmax(ind);
% 2.2 get centroids
cc=bwconncomp(localmax,8);
rprops = regionprops(cc,'centroid');
centroids=reshape([rprops.Centroid],2,[])';
% 2.3 filter centroids by distance
centroids1=centdistfilt(centroids); % remove too close points
centroids1=round(centroids1); % get coordinates
localmax=logical(zeros(size(localmax)));
for i=1:length(centroids1)
    localmax(centroids1(i,2),centroids1(i,1))=1;
end
%% 3. analyze individual objects
% 3.1 convert to label matrix
L=bwlabel(and); % this is the same as bwlabel(bwimg1)
%% 3.2 get the label for each local maximum
Npix=size(centroids1,1);
peaklabels=zeros(Npix,1);
for n=1:Npix
    peaklabels(n)=L(centroids1(n,2),centroids1(n,1));
end
% 3.3 separate individual neurons and connected neurons
Num=max(max(L));
singleidx=[];
bundleidx=[];
for n=1:Num
    if sum(peaklabels==n)==1
        singleidx=[singleidx;n];
    else
        bundleidx=[bundleidx;n];
    end
end
bwimg_patch{1}=ismember(L,singleidx);
bwimg_patch{2}=ismember(L,bundleidx);