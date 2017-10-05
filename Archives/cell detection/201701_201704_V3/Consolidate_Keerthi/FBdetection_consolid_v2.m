%% consolidating Keerthi's and Bingxing's code
function centroids1=FBdetection_consolid_v2(fluoroimg)
global bitinfo
%% 0. parameters
bitinfo=12;
thresh.count=200; % at least the size of one cell
clearpar=60;
eccpar=[.99,.95];
%% 1. Pre-processing
tic
% 1.1 boost intensity
blue=fluoroimg(:,:,3)-max(fluoroimg(:,:,1),fluoroimg(:,:,2)); % blueness
% 1.2 Remove background using gaussian filter
bg=imgaussfilt(blue,20); % generate background
img_nobak=blue-bg; % remove background
% 1.3 Remove saturation in the image
if (sum(sum(fluoroimg(:,:,3)>=2^bitinfo))<thresh.count) % Case 1: less than M saturated pixels in the image
    img_unsat=img_nobak; % get the monochrome image
else    % Case 2. If there are saturation in the image
    warning('There is saturation in the image!')
    [~,satumask]=satmask(fluoroimg,thresh.count); % generate the mask for saturated area
    img_unsat=img_nobak.*(1-satumask); % non-saturated area
end
% 1.4 Gamma correction (does not seem working well especially close to
% injection area)
% blue_adj=imadjust(blue,[0;2^12-1]./(2^16-1),[0;2^8-1]./(2^16-1),.5);
% 1.5 Denoise
img_denoise=imgaussfilt(img_unsat,1);
toc
clear bg imunsat
%% 2. Convert to binary image
tic
% 2.1 Calculate threshold and convert to binary image
thresh.cutoff=imgcutoff(single(img_denoise),bitinfo); % custom threshold based on the image
bwimg=img_denoise>=thresh.cutoff; %  thershold intensity
% 2.2 clear up the area and fill the binary mask
bwimg=bwareaopen(bwimg,clearpar); % remove small connected areas (one cell size)
bwimg=imfill(bwimg,'holes'); % fill holes
toc
%% 3. separately consider large patches and small patches
% tic
% 3.1 determine if there are large patches of cells
[bundleidx,bwimg_patch]=cellpatch(bwimg); 
% 3.2 Filter shape for large patch
if ~isempty(bundleidx)
    L=bwlabeln(bwimg_patch{2});
    L=eccentricity(L,eccpar(1)); 
    bwimg1=L>0;
    bwimg1=bwimg_patch{1}+bwimg1; % with large patches
else 
    bwimg1=bwimg; % no large patches
end
% toc
clear bwimg L
%% 4. Detect cells
% tic
% 4.1 Detect object perimeter
bwimg_smooth=imgaussfilt(single(bwimg1),.85); % smooth
bwimg1=im2bw(bwimg_smooth); % convert to binary
edg = bwperim(bwimg1); % generate edges of cells
% 4.2 Generate distance matrix
dist_tr = bwdist(edg); % generate the distance intensity map
% 4.3 Combine the mask and distance matrix
and = bwimg1.*dist_tr; % reconstruct
ind=imgaussfilt(and,1); % denoise 
% toc
%%
% tic
% 4.4 watershed
ind2=imregionalmax(and);
se=strel('disk',1);
ind2=imdilate(ind2,se);
D=imcomplement(ind);
D_mod=imimposemin(D,~bwimg1 | ind2);
L=watershed(D_mod);
L=L.*(L>1); % remove 1 which is the background
% 4.5 feature filters
stats = regionprops(L, 'Area','Eccentricity');
idx = find([stats.Area] > (2/.46)^2*pi & [stats.Eccentricity] < eccpar(2)); 
L1 = ismember(L, idx);
% L1=cellsize(L);
% L1=eccentricity(L1,eccpar(2));
% 4.6 detect centroids
S=regionprops(L1,'Centroid'); % get the centroids
centroids=cat(1,S.Centroid); % assemble the centroids
% 4.7 filter centroid distance
centroids1=centdistfilt(centroids);
% toc