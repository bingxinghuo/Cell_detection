%% consolidating Keerthi's and Bingxing's code
function centroids1=FBdetection_consolid_v2_2014(fluoroimg)
global bitinfo
%% 0. parameters
bitinfo=12;
thresh.count=10;
clearpar=60;
eccpar=[.99,.95];
sigma=[20,1];
%% 1. Pre-processing
% tic
% 1.1 boost intensity
blue=fluoroimg(:,:,3)-max(fluoroimg(:,:,1),fluoroimg(:,:,2)); % blueness
% 1.2 Remove background using gaussian filter
% bg=imgaussfilt(blue,sigma(1)); % generate background
bg=imfilter(blue,fspecial('gaussian',2*ceil(2*sigma(1))+1, sigma(1)),'same');
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
% img_denoise=imgaussfilt(img_unsat,sigma(2));
img_denoise=imfilter(img_unsat,fspecial('gaussian',2*ceil(2*sigma(2))+1, sigma(2)),'same');
% toc
%% 2. Convert to binary image
% tic
% 2.1 Calculate threshold and convert to binary image
thresh.cutoff=imgcutoff(single(img_denoise),bitinfo); % custom threshold based on the image
bwimg=img_denoise>=thresh.cutoff; %  thershold intensity
% 2.2 clear up the area and fill the binary mask
bwimg=bwareaopen(bwimg,clearpar); % remove small connected areas (one cell size)
bwimg=imfill(bwimg,'holes'); % fill holes
% toc
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
%% 4. Detect cells
% tic
% 4.1 Detect object perimeter
% bwimg_smooth=imgaussfilt(single(bwimg1),.85); % smooth
bwimg_smooth=imfilter(single(bwimg1),fspecial('gaussian',2*ceil(2*sigma(2))+1, sigma(2)),'same');
bwimg1=im2bw(bwimg_smooth); % convert to binary
edg = bwperim(bwimg1); % generate edges of cells
% 4.2 Generate distance matrix
dist_tr = bwdist(edg); % generate the distance intensity map
% 4.3 Combine the mask and distance matrix
and = bwimg1.*dist_tr; % reconstruct
and(isnan(and))=0;
% ind=imgaussfilt(and,1); % denoise 
ind=imfilter(single(and),fspecial('gaussian',2*ceil(2*sigma(2))+1, sigma(2)),'same');
% toc
% tic
% 4.4 watershed
ind2=imregionalmax(and);
D=imcomplement(ind);
D(~bwimg1)=-Inf;
L=watershed(D);
% 4.5 feature filters
L1=cellsize(L);
L1=eccentricity(L1,eccpar(2));
% 4.6 detect centroids
S=regionprops(L1,'Centroid'); % get the centroids
centroids=cat(1,S.Centroid); % assemble the centroids
% 4.7 filter centroid distance
centroids1=centdistfilt(centroids);
% toc