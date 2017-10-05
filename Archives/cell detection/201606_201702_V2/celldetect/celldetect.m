%% celldetect.m
% This function detects only about cell bodies in the image
% This is a revised version from the previous celldetect.m by adding in
% the watershed method
function centroids=celldetect(monoimg,varargin)
%  median filter
sigma=1;
% monoimg=medfilt2(monoimg);
monoimg=imfilter(monoimg,fspecial('gaussian',2*ceil(2*sigma)+1, sigma),'replicate');
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
%% visualize
% imagesc(imgtemp_log); hold on
% axis image; axis off; axis ij;
% caxis([3.5 5])
%% General patches
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
% 6. Restrict sizes
L0=bwlabeln(bwimg,4);
cellsizes=regionprops(L0,'Area');
idx=1:max(max(L0));
for k=1:length(cellsizes)
    if cellsizes(k).Area>1000 % ad hoc threshold of 1000 pixels (very generous)
        idx(k)=0; % remove the index
    end
end
idx=nonzeros(idx);
bwimg = ismember(L0,idx);
%% Strict cores
imgtemp_core=imgtemp_log.*(imgtemp_log>max(logmean+logsd,3.5));
imgtemp_core(isnan(imgtemp_core))=0;
imgtemp_core=imfill(imgtemp_core,'holes');
cores = imextendedmax(imgtemp_core, .1);
% morphological operations
% cores=imclose(cores,ones(5,5));
cores = imfill(cores, 'holes');
cores = bwareaopen(cores, 5);
%% Watershed
imgtemp_core_comp=imcomplement(imgtemp_core);
I_mod = imimposemin(imgtemp_core_comp, cores | ~bwimg);
L=watershed(I_mod);
idx=1:max(max(L));
% 7. exclude cell bodies that are too big
cellsizes=regionprops(L,'Area');
for k=1:length(cellsizes)
    if cellsizes(k).Area>1000 % ad hoc threshold of 1000 pixels (very generous)
        idx(k)=0; % remove the index
    end
end
idx=nonzeros(idx); % remove the index
[~,L1] = ismember(L,idx); % pick out only small enough cell bodies
%% shape selection
% c = compactness(L1);
% idx = find(c > 0.5*4*pi & c < 1.5*4*pi);
% [~,L2]=ismember(L1,idx);
%% 8. find the centroids
Bstat=regionprops(L1,'Centroid');
centroids=cat(1,Bstat.Centroid);
