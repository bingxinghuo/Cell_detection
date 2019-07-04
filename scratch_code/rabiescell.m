% filedir='/Users/bhuo/CSHLservers/gpu2_Mdrives/M29/PeterStrickData/';
% sampleid='DL17_242';
% sizepar=[2,1000]; % radius in microns
% sigma=[200 1]; % s.d. in microns
% resolution=.25;
function [cellmask,cellannotile,hitscoretile]=rabiescell(filedir,sampleid,sigma,sizepar,resolution,N)
imgfile=[filedir,'Normalized/',sampleid,'.jp2'];
img=imread(imgfile);
annofile=[filedir,'annotation/',sampleid,'.txt'];
if ~exist(annofile,'file')
    annofile=[filedir,'annotation/',sampleid,'_full.txt'];
end

sigma1=sigma(1)*resolution;
sigma2=sigma(2)*resolution;
sizepar=round(sizepar.^2*pi/resolution^2);
sizepar1=sizepar(1);
if nargin<=5 % set granularity of tiles
    N=10000;
end
outputdir=[filedir,'unsupervised/'];
if ~exist(outputdir,'dir')
    mkdir(outputdir)
end
%% cut into tiles
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
cellimgs=cell(R*C,1);
cellmasks=cell(R*C,1);
cutoff=zeros(R*C,1);
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
    cellimgs{n}=gradimg;
    % binarize to mask
    if sum(sum(cellimgs{n}))>sizepar1
        cutoff(n)=imgcutoff(cellimgs{n}); % calculate threshold
        cellmasks{n}=cellimgs{n}>=cutoff(n);
        se=strel('disk',round(cutoff(n)/sqrt(2)*2)); % compensate for the removal on the distance map
        cellmasks{n}=imdilate(cellmasks{n},se);
        cellmasks{n}=cellsize(cellmasks{n},sizepar);
    else
        cellmasks{n}=zeros(size(cellimgs{n}));
    end
    
end
cellimg=reshape(cellimgs,R,C);
cellmask=reshape(cellmasks,R,C);
toc
%% add annotation info, if exists
if ~exist(annofile,'file')
    cellannotile={};
    hitscoretile={};
else
    fid=fopen(annofile);
    cellanno=textscan(fid,'%f %f');
    fclose(fid);
    cellanno=cell2mat(cellanno); % annotation
    cellannotile=cell(R,C);
    hitscoretile=zeros(R,C);
    for r=1:R
        for c=1:C
            % annotation/ground truth
            cellannotile{r,c}=cellanno-ones(size(cellanno))*[(r-1)*N,0;0,(c-1)*N];
            cellannotile{r,c}=cellannotile{r,c}.*(cellannotile{r,c}>0);
            cellannotile{r,c}=cellannotile{r,c}.*(cellannotile{r,c}<=N);
            cellannotile{r,c}=cellannotile{r,c}((cellannotile{r,c}(:,1).*cellannotile{r,c}(:,2))>0,:);
            
            % record TP
            if ~isempty(cellannotile{r,c})
                L=size(cellannotile{r,c},1);
                hitscore=zeros(L,1);
                for l=1:L
                    hitscore(l)=cellmask{r,c}(cellannotile{r,c}(l,1),cellannotile{r,c}(l,2));
                end
                hitscoretile(r,c)=sum(hitscore);
            end
        end
    end
end
%% save output
outputmat=[outputdir,sampleid,'.mat'];
save(outputmat,'cellimg','cellmask','cellannotile','hitscoretile','-v7.3')

