%% consolidating Keerthi's and Bingxing's code
function centroids1=FBdetection_consolid_v4_2014(fluoroimg,imgmask)
% tic
global bitinfo
%% 0. parameters
bitinfo=12;
thresh.int=100;
thresh.count=200; % at least the size of one cell
sizepar=[20,5000];
eccpar=[.99,.95];
sigma=[20,1];
%% 1. Pre-processing
% tic
blueint=fluoroimg(:,:,3).*uint16(imgmask);
if sum(sum(blueint>thresh.int))>thresh.count
    tic
    % 1.1 boost intensity
    blue=fluoroimg(:,:,3)-max(fluoroimg(:,:,1),fluoroimg(:,:,2)); % blueness
    blue=blue.*uint16(imgmask);
    % 1.2 Remove background using gaussian filter
    % bg=imgaussfilt(blue,sigma(1)); % generate background
    bg=imfilter(blue,fspecial('gaussian',2*ceil(2*sigma(1))+1, sigma(1)),'same');
    img_nobak=blue-bg; % remove background
    % 1.3 Remove saturation in the image
    if (sum(sum(fluoroimg(:,:,3)>=2^bitinfo))<thresh.count) % Case 1: less than M saturated pixels in the image
        img_unsat=img_nobak; % get the monochrome image
    else    % Case 2. If there are saturation in the image
        warning('There is saturation in the image!')
        satumask=fluoroimg(:,:,3)>=2^bitinfo; % generate the mask for saturated area
        satumask=uint16(satumask);
        img_unsat=img_nobak.*(1-satumask); % non-saturated area
    end
    % 1.4 Gamma correction (does not seem working well especially close to
    % injection area)
    % blue_adj=imadjust(blue,[0;2^12-1]./(2^16-1),[0;2^8-1]./(2^16-1),.5);
    % 1.5 Denoise
    % img_denoise=imgaussfilt(img_unsat,sigma(2));
    img_denoise=imfilter(img_unsat,fspecial('gaussian',2*ceil(2*sigma(2))+1, sigma(2)),'same');
    toc
    clear bg imunsat
    %% 2. Convert to binary image
    % tic
    % 2.1 Calculate threshold and convert to binary image
    thresh.cutoff=imgcutoff(single(img_denoise)); % custom threshold based on the image
    pixcount=sum(sum(img_denoise>=thresh.cutoff));
    if pixcount>0
        bwimg=img_denoise>=thresh.cutoff; %  thershold intensity
        % 2.2 clear up the area and fill the binary mask
        bwimg=bwareaopen(bwimg,sizepar(1)); % remove small connected areas (one cell size)
        bwimg=imfill(bwimg,'holes'); % fill holes
        % toc
        %% 3. separately consider large patches and small patches
        [bwimg_patch,localmax]=cellpatch(bwimg,sigma(2));
        
        %% 4. detect centroids
        for i=1:2
            centroids{i}=cellfeatures(bwimg_patch{i},localmax,sizepar,eccpar,i);
        end
        centroids1=[centroids{1};centroids{2}];
    else
        centroids1=[];
    end
else
    centroids1=[];
end

% 4.7 filter centroid distance
% centroids1=centdistfilt(centroids1);
toc