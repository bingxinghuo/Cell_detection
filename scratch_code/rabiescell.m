% imgfile='DL17_242.jp2';
% annofile='../annotation/DL17_242_full.txt';
% sizepar=[2,1000]; % radius in microns
% sigma=[200 1]; % s.d. in microns
% resolution=.25;
function [cellmask1,cellannotile,hitscoretile]=rabiescell(imgfile,annofile,sigma,sizepar,resolution,outputfile)
img=imread(imgfile);
fid=fopen(annofile);
cellanno=textscan(fid,'%d',2);
fclose(fid);
cellanno=cell2mat(cellanno); % annotation
sigma1=sigma(1)*resolution;
sigma2=sigma(2)*resolution;
sizepar=round(sizepar.^2*pi/resolution^2);
sizepar1=sizepar(1);
%% cut into tiles
N=10000;
[rows,cols]=size(img);
imgtile=cell(ceil(rows/N),ceil(cols/N));
for r=1:floor(rows/N)
    for c=1:floor(cols/N)
        imgtile{r,c}=img((r-1)*N+1:r*N,(c-1)*N+1:c*N);
    end
    imgtile{r,c+1}=img((r-1)*N+1:r*N,c*N+1:cols);
end
for c=1:floor(cols/N)
    imgtile{r+1,c}=img(r*N+1:rows,(c-1)*N+1:c*N);
end
imgtile{r+1,c+1}=img(r*N+1:rows,c*N+1:cols);
%% detect cells
[R,C]=size(imgtile);
imgtiles=reshape(imgtile,R*C,1);
cellmasks=cell(R*C,1);
tic
parfor n=1:R*C
    img1=imgtiles{n,1};
    img2=max(max(img1))-img1; % invert intensity
    bg=imgaussfilt(img2,sigma1);
    img_nobak=img2-bg; % remove background
    img_denoise=imgaussfilt(img_nobak,sigma2); % remove sharp noise
    threshcutoff=imgcutoff(single(img_denoise)); % calculate threshold
    bwimg=img_denoise>=threshcutoff; % binarize
    bwimg=bwareaopen(bwimg,sizepar1); % remove small patches
    bwimg=imfill(bwimg,'holes'); % close gaps
    bwimg=bwareaopen(bwimg,sizepar1); % remove small patches
    [~,gradimg,~]=cellpatch(bwimg); % calculate distance map
    cellmasks{n}=gradimg;
end
cellmask=reshape(cellmasks,R,C);
toc
%% tilewise binarization
cellannotile=cell(R,C);
cutoff=zeros(R,C);
cellmask1=cell(R,C);
hitscoretile=zeros(R,C);
TPR=zeros(R,C);
for r=1:R
    for c=1:C
        % annotation/ground truth
        cellannotile{r,c}=cellanno-ones(size(cellanno))*[(r-1)*N,0;0,(c-1)*N];
        cellannotile{r,c}=cellannotile{r,c}.*(cellannotile{r,c}>0);
        cellannotile{r,c}=cellannotile{r,c}.*(cellannotile{r,c}<=10000);
        cellannotile{r,c}=cellannotile{r,c}((cellannotile{r,c}(:,1).*cellannotile{r,c}(:,2))>0,:);
        % binarize to mask
        cutoff(r,c)=imgcutoff(cellmask{r,c}); % calculate threshold
        cellmask1{r,c}=cellmask{r,c}>=cutoff(r,c);
        % morphological manipulation
        %         cellmask1{r,c}=eccentricity(cellmask1{r,c},.99);
        se=strel('square',round(cutoff(r,c)/sqrt(2)*2)); % compensate for the removal on the distance map
        cellmask1{r,c}=imdilate(cellmask1{r,c},se);
        cellmask1{r,c}=cellsize(cellmask1{r,c},sizepar);
        % record TP
        if ~isempty(cellannotile{r,c})
            L=size(cellannotile{r,c},1);
            hitscore=zeros(L,1);
            for l=1:L
                hitscore(l)=cellmask1{r,c}(cellannotile{r,c}(l,1),cellannotile{r,c}(l,2));
            end
            hitscoretile(r,c)=sum(hitscore);
        end
    end
end
for r=1:R
    for c=1:C
        TPR(r,c)=sum(hitscoretile(r,c))/size(cellannotile{r,c},1);
    end
end
%% save output
if nargin>5
    save([outputfile,'.mat'],'cellmask1','cellannotile','hitscoretile')
    imwrite(TPR,[outputfile,'.png'])
end
