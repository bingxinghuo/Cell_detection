%%
function centroids=celldetect_v6(varargin)
img=varargin{1};
if nargin>1
    bitinfo=varargin{2};
else
    bitinfo=12; % 12-bit is the default
end
% take log
img=img.*(img>0);
imgbit=log2(single(img));

%% Morphological operations
% 0. Low pass filter
sigma=1;
imgbit1 = imfilter(imgbit,fspecial('gaussian',2*ceil(2*sigma)+1, sigma),'replicate');
% 1. apply the threshold
thresh=2^Xpeak;
%% visualize
if nargin>2
    if varargin{3}==1
        imagesc(imgbit1,[thresh,12]); hold on
        axis image; axis off; axis ij;
    end
end
%%
bwimg=imgbit1>thresh;
% 2. clear up
% bwimg=medfilt2(bwimg);
% 2. clear up
initial_clear=10;
bwimg=bwareaopen(bwimg,initial_clear);
% 3. dilate
se_dia=2;
se=strel('disk',se_dia);
% bwimg=imdilate(bwimg,se);
% 4. close
bwimg=imfill(bwimg,'holes');
% 5. clear up again
final_clear=initial_clear*se_dia;
bwimg=bwareaopen(bwimg,final_clear);
%%
CC=bwconncomp(bwimg);
num=zeros(CC.NumObjects,1);
bundleidx=[];
for i=1:CC.NumObjects
    num(i)=length(CC.PixelIdxList{i});
    if num(i)>500
        bundleidx=[bundleidx;i];
    end
end
if isempty(bundleidx)
    L=bwlabeln(bwimg);
    L=cellsize(L);
    L=eccentricity(L,.95);
    L=cellSNR(L,imgbit,bitinfo);
    S=regionprops(L,'Centroid');
    centroids=cat(1,S.Centroid);
else
    % small parts
    bwimg1=bwimg;
    for b=1:length(bundleidx)
        bwimg1(CC.PixelIdxList{bundleidx(b)})=0;
    end
    L1=bwlabeln(bwimg1);
    L1=cellsize(L1);
    L1=eccentricity(L1,.95);
    L1=cellSNR(L1,imgbit,bitinfo);
    S1=regionprops(L1,'Centroid');
    centroids1=cat(1,S1.Centroid);
    %% large parts
    bwimg2=bwimg-bwimg1;
    L2=bwlabeln(bwimg2);
    L2=eccentricity(L2,.99);
    bwimg2=bwimg2.*(L2>0);
    bwimg2 = imfill(bwimg2, 'holes');
    %     D=bwdist(~bwimg2);
    %     D=-D;
    %     D(~bwimg2)=-Inf;
    %     L2=watershed(D);
    %
    %     L2(L2==1)=0;
    L2=cellsep(L2,imgbit);
    %
    L2=cellsize(L2);
    L2=eccentricity(L2,.95);
    L2=cellSNR(L2,imgbit,bitinfo);
    S2=regionprops(L2,'Centroid');
    centroids2=cat(1,S2.Centroid);
    %%
    centroids=[centroids1;centroids2];
    centroids=centdistfilt(centroids);
end
% figure, imagesc(img)
% hold on, scatter(centroids(:,1),centroids(:,2),'r*')