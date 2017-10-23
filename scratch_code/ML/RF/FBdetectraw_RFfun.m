function [FBcellmask,centroids]=FBdetectraw_RFfun(rgbimg,n)
global sigma sizepar eccpar
%% 0. parameters
sizepar=[40,5000];
eccpar=[.99,.95];
sigma=[20,1];
N=2*n+1;
%% 1. Global linear filter
% 1.1 Remove a blurred background
% h1=fspecial('gaussian',[1,2*3*20+1],20);
% h2=fspecial('gaussian',[1,2*3*20+1],1);
% h=h2-h1;
%  bg=imgaussfilt(single(rgbimg),sigma(1));
% img_nobak=single(rgbimg)-bg;
% img_nobak=img_nobak.*(img_nobak>0);
% [rows,cols,~]=size(img_nobak);
[rows,cols,~]=size(rgbimg);
%% 2. Color and intensity classification
ensemv=contextimg(rgbimg,n);
imgenname=['imgen',num2str(N)];
save(imgenname,'ensemv','-v7.3')
  %%      
% 2.4 Apply classifier
% group=predict(svmmodel,pixvector_int);
status=system(['python ~/python_code/RFsample.py ',num2str(n)]);
groupfile=['samplegroup',num2str(N),'.txt'];
group=dlmread(groupfile);
groupimg=reshape(group,rows,cols);
%% 3. Operate on the grayscale mask
groupmask=groupimg;
se=strel('disk',3);
groupmask=imclose(groupmask,se);
groupmask=imfill(groupmask,'holes'); % fill holes
groupmask=bwareaopen(groupmask,sizepar(1)); % remove small connected areas (one cell size)

% 
%         groupmask=imgaussfilt(single(groupmask),1);
%         groupmask=groupmask>0;
%         groupmask=imerode(groupmask,se);
%% 3.1 cell separation
    % separate connected cells and single cells
    [bwimg_patch,gradimg,localmax]=cellpatch(groupmask);
%     [bwimg_patch,gradimg,localmax]=cellpatch1(groupmask,pixintimg);
    bwimg_new=[];
    % Separate individual cells in the connected patches
    if ~isempty(bwimg_patch{2}) % there exist connected cells
        bwimg_new=eccentricity(bwimg_patch{2},eccpar(1)); % filter shape
        bwimg_new=cellsize(bwimg_new); % filter size
        bwimg_new=cellsep(bwimg_new,gradimg,localmax);
    end
    % combine all individual cells
    bwimg_new=bwimg_new+bwimg_patch{1}; % all individual cells now
%     clear bwimg_patch
    % 3.2 feature filters
    bwimg_filt=cellsize(bwimg_new); % filter for cell sizes
    bwimg_filt=eccentricity(bwimg_filt,eccpar(2)); % the cell need to be more round than linear
    % L=cellSNR(L,imgbit,bitinfo); % filter for SNR
%     clear bwimg_new
    % 3.3 reveal cell boundaries
    img_edge=bwperim(bwimg_filt);
    FBcellmask=imfill(img_edge,'holes');
    % 3.4 detect centroids
    cc=bwconncomp(bwimg_filt);
    rprops = regionprops(cc,'centroid');
    centroids=reshape([rprops.Centroid],2,[])';
%% 4. Visualization
% h=imoverlay(uint8(rgbimg),img_edge,'r');
% figure, imagesc(h)