%% celldetect1.m
% This function detects only about cell bodies in the image
% This is a revised version from the previous celldetect.m by adding in
% cell compactness calculation.
function centroids=celldetect_v2(monoimg,varargin)
%  median filter
monoimg=medfilt2(monoimg);
if nargin<2
    rgbimg=monoimg;
else
    rgbimg=varargin{1};
    % Color selection
    hsvimg=rgb2hsv(rgbimg);
    bluemask=hsvimg(:,:,1)>.5 & hsvimg(:,:,1)<.8;
    monoimg=double(monoimg).*bluemask;
end
% take logarithm
imgtemp_log=log(double(monoimg));
%%
% imshow(imgtemp_log); hold on
% axis image; axis off; 
% caxis([3 5])
%% Morphological operations
% 1. intensity threshold
logmean=trimmean(imgtemp_log(~isinf(imgtemp_log)),10);
logsd=std(imgtemp_log(~isinf(imgtemp_log)));
bwimg=imgtemp_log>max(logmean+logsd,3.5);
% bwimg=imgtemp_log>max(max(max(imgtemp_log))*.7,3.5); % 
% 2. clear up
initial_clear=5;
bwimg=bwareaopen(bwimg,initial_clear);
% 3. dilate
se_dia=2;
se=strel('disk',se_dia);
bwimg=imdilate(bwimg,se);
% 4. close
bwimg=imfill(bwimg,'holes');
% 5. clear up again
final_clear=initial_clear*se_dia;
bwimg=bwareaopen(bwimg,final_clear);
%%
imshow(bwimg)
%% 6. calculate compactness
L=bwlabeln(bwimg,4); % label connected pixels as objects
c = compactness(L); % calculate the compactness
% if the compactness is within a certain range, consider it a cell body
idx = find(c > 0.8*4*pi & c < 1.2*4*pi); 
bw1 = ismember(L,idx); % pick out only cell bodies
% % 7. exclude cell bodies that are too big
cellsizes=regionprops(bw1,'Area');
for k=1:length(cellsizes)
    if cellsizes(k).Area>1000 % ad hoc threshold of 1000 pixels (very generous)
        idx(k)=0; % remove the index
    end
end
idx=nonzeros(idx); % remove the index
bw1 = ismember(L,idx); % pick out only small enough cell bodies
% 8. find the centroids
Bstat=regionprops(bwimg,'Centroid');
centroids=cat(1,Bstat.Centroid);
