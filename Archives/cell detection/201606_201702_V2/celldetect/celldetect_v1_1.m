function centroids=celldetect_v1(monoimg,varargin)
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
%% visualize
% clf
% ax1=subplot(1,2,1);imshow(rgbimg); hold on
%             ax2=subplot(1,2,2);imshow(imgtemp_mono); hold on
% ax2=subplot(1,2,2);
imshow(imgtemp_log); hold on
% axis image; axis off; 
caxis([3 5])
% linkaxes([ax1,ax2]);
%% Morphological operations
% 1. intensity threshold
bwimg=imgtemp_log>max(max(max(imgtemp_log))*.7,3.5); % 
%                                     bwimg=imgtemp_log>3.5;
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
% 6. find the centroids
Bstat=regionprops(bwimg,'Centroid');
centroids=cat(1,Bstat.Centroid);
