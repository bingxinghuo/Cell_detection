%%
function centroids_a=celldetect_s2(varargin)
%% 1. inputs
img=varargin{1};
if nargin>1
    bitinfo=varargin{2};
else
    bitinfo=12; % 12-bit is the default
end
%% 2. manual parameters
% clearpar=[10,20];
clearpar=60;
eccpar=[.99,.95];
%% 3. convert to bits
img=img.*(img>0);
imgbit=log2(single(img)); %% use gamma
%% 4. Morphological operations
% 4.1 Low pass filter
sigma=1;
imgbit1 = imfilter(imgbit,fspecial('gaussian',2*ceil(2*sigma)+1, sigma),'replicate');
% 4.2 threshold
thresh=imgcutoff(imgbit,bitinfo); % find cutoff point for threshold
bwimg=imgbit1>thresh;
% 4.3 clear up
bwimg=bwareaopen(bwimg,clearpar);
% 4.4 close
bwimg=imfill(bwimg,'holes');
%% 5. detect: considering if there are large patches of cells
% 5.1 initialize
bwimg1=cell(2,1);
centroids=cell(2,1);
% 5.2 determine if there are large patches of cells
[bundleidx,bwimg_patch]=cellpatch(bwimg); 
% 5.3 detect cells in every part of the image
if ~isempty(bundleidx)
    bwimg1=bwimg_patch; % with large patches
else 
    bwimg1{1}=bwimg; % no large patches
end
for i=1:2
    if ~isempty(bwimg1{i}) 
        centroids{i}=cellfeatures(bwimg1{i},imgbit,eccpar,i); % apply all the features to detect cells
    end
end
%% 6. assemble all the centroids
centroids_a=[centroids{1};centroids{2}];