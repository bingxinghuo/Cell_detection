%% Pre-processing
function bwimg=preprocess_AF(fluoroimg,imgmask,bitinfo)
tic
global sigma sizepar
%% parameters
sizepar=[20,5000];
sigma=[20,1];
thresh.int=2^8; % this number is learned from observation of a few sections
thresh.count=200; % at least the size of one cell
%%
if bitinfo==12
    rgbimg=fluoroimg.*uint16(cat(3,imgmask,imgmask,imgmask));
elseif bitinfo==8
    rgbimg=fluoroimg.*uint8(cat(3,imgmask,imgmask,imgmask));
end
%% 1 color segmentation
blueness=rgbimg(:,:,3)-max(rgbimg(:,:,1),rgbimg(:,:,2)); % blue channel is the max value
bluemask=blueness>0; % generate a mask of the blue image
if bitinfo==12
    blueimg=rgbimg(:,:,3).*uint16(bluemask);
elseif bitinfo==8
    blueimg=rgbimg(:,:,3).*uint8(bluemask);
end
%% 2 intensity thresholding
fluoro_pixels=sum(sum(blueimg>thresh.int));
% if fluoro_pixels<thresh.count
%     bwimg=[];
% else
%% 3 remove saturated part in the image
%     satu_mask=rgbimg(:,:,3)>=2^bitinfo;
satu_mask=blueimg>=2^bitinfo-1;
if bitinfo==12
    img_unsat=blueimg.*uint16(1-satu_mask);
elseif bitinfo==8
    img_unsat=blueimg.*uint8(1-satu_mask);
end
%% 4 Remove background using gaussian filter
% bg=imgaussfilt(imgunsat,sigma(1)); % generate background
bg=imfilter(img_unsat,fspecial('gaussian',2*ceil(2*sigma(1))+1, sigma(1)),'same');
img_nobak=img_unsat-bg; % remove background
%     clear bg img_unsat
%% 5 Gamma correction (does not seem working well especially close to
% injection area)
% blue_adj=imadjust(blue,[0;2^12-1]./(2^16-1),[0;2^8-1]./(2^16-1),.5);
%% 6 Denoise
% img_denoise=imgaussfilt(img_unsat,sigma(2));
img_denoise=imfilter(img_nobak,fspecial('gaussian',2*ceil(2*sigma(2))+1, sigma(2)),'same');
clear img_nobak
%% 2. Convert to binary image
% tic
% 2.1 Calculate threshold and convert to binary image
thresh.cutoff=imgcutoff(single(img_denoise)); % custom threshold based on the image
bwimg=img_denoise>=thresh.cutoff; %  thershold intensity
pixcount=sum(sum(bwimg));
if pixcount<thresh.count
    bwimg=[];
    %     else
    %         % 2.2 clear up the area and fill the binary mask
    %         bwimg=bwareaopen(bwimg,sizepar(1)); % remove small connected areas (one cell size)
    %         bwimg=imfill(bwimg,'holes'); % fill holes
end

% end
toc