%%
function centroids=celldetect_s1(varargin)
%% 1. inputs
img=varargin{1};
if nargin>1
    bitinfo=varargin{2};
else
    bitinfo=12; % 12-bit is the default
end
%% 2. manual parameters
clearpar=[10,20];
eccpar=[.99,.95];
%% 3. take log
img=img.*(img>0);
imgbit=log2(single(img));
%% 4. Morphological operations
% 4.1 Low pass filter
sigma=1;
imgbit1 = imfilter(imgbit,fspecial('gaussian',2*ceil(2*sigma)+1, sigma),'replicate');
% 4.2 threshold
thresh=imgcutoff(imgbit,bitinfo); % find cutoff point for threshold
% visualize
% if nargin>2
%     if varargin{3}==1
%         imagesc(imgbit1,[thresh,12]); hold on
%         axis image; axis off; axis ij;
%     end
% end
%
bwimg=imgbit1>thresh;
% 4.3 clear up
bwimg=bwareaopen(bwimg,clearpar(1));
% 4.4 close
bwimg=imfill(bwimg,'holes');
% 4.5 clear up again
bwimg=bwareaopen(bwimg,clearpar(2));
%% 5. detect
[bundleidx,bwimg_patch]=cellpatch(bwimg); % determine if there are large patches of cells
if isempty(bundleidx) % no large patches
    centroids=cellfeatures(bwimg,imgbit,eccpar);
else
    % small parts
    centroids1=cellfeatures(bwimg_patch{1},imgbit,eccpar);
    % large parts
    centroids2=cellfeatures(bwimg_patch{2},imgbit,eccpar);
    % assemble
    centroids=[centroids1;centroids2];    
end
%% 6. final filter for cell center distance
centroids=centdistfilt(centroids);
% figure, imagesc(img)
% hold on, scatter(centroids(:,1),centroids(:,2),'r*')