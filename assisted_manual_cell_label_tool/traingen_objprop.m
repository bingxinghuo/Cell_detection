function [cellsignal,cellid,boundbox]=traingen_objprop(rgbimg,Ithresh)
% Outputs:
%   - cellsignal: all the bounding boxes containing some signal
%   - cellid: classification of a cell (1) or no cell (0)
%   - boundbox: position of all these cellsignal images on the full image
%% Parameters
M=64;
% Ithresh=30;
sigma=[30,1];
sizepar=[40,5000];
%% object proposal from FBdetection_threshold_iter
%% remove background
rgbimg=rmbg(rgbimg,sigma);
% rgbimg1=rgbimg;
%% First weak screening
blueimg_down=downsample_max(rgbimg(:,:,3),M);
FBmask=blueimg_down>Ithresh;
%% extract all MxM tiles
[h,w,c]=size(rgbimg);
% FBmask contains all the coordinates of the signal tiles
[sigrow,sigcol]=find(FBmask);
sigrow1=(sigrow-1)*M+1;
sigcol1=(sigcol-1)*M+1;
Ntiles=size(sigrow,1); % number of tiles
tileimg=cell(Ntiles,1);
tilenorm=cell(Ntiles,1);
for t=1:Ntiles
    if sigrow1(t)+M<=h && sigcol1(t)+M<=w
        tileimg{t}=rgbimg(sigrow1(t)+1:sigrow1(t)+M,sigcol1(t)+1:sigcol1(t)+M,:); % extract the tile image
        % color filter
            tilenorm{t}=hsvadj(tileimg{t});
    end
end
%% reassemble
tilevis=tilenorm;
FBimg=zeros(size(rgbimg));
for t=1:Ntiles
    if sigrow1(t)+M<=h && sigcol1(t)+M<=w
        FBimg(sigrow1(t)+1:sigrow1(t)+M,sigcol1(t)+1:sigcol1(t)+M,:)=tilevis{t};
    end
end
%     figure, imagesc(uint8(FBimg))
%% Pixel-level filtering and get connected objects
FBmask1=FBimg(:,:,3)>Ithresh;
% se=strel('disk',3);
% FBmask1=imclose(FBmask1,se);
FBmask1=imfill(FBmask1,'holes'); % fill holes
FBmask1=bwareaopen(FBmask1,sizepar(1)); % remove small connected areas (one cell size)
cc=bwconncomp(FBmask1);
L=labelmatrix(cc);
%% get the bounding box for each "cell" and the surrounding area
idx=1:max(max(L));
% idx1=zeros(length(idx),1);
boundbox=regionprops(L,'BoundingBox');
imgregion=regionprops(L,'Image');
% bufferpix=ceil(2/.46); % move half a cell in each direction
bufferpix=100;
[h,w,c]=size(rgbimg);
broadimg=zeros(h+bufferpix*2,w+bufferpix*2,c);
broadimg(bufferpix+1:bufferpix+h,bufferpix+1:bufferpix+w,:)=rgbimg; % outside of the image is 0
%
cellsignal=cell(length(boundbox),1);
broadbox=cell(length(boundbox),1);
for k=1:length(boundbox)
    %%
    if boundbox(k).BoundingBox(3)==w
        idx(k)=0;
    else
        % cells
        boundbox(k).BoundingBox=round(boundbox(k).BoundingBox);
        cellbox=rgbimg(boundbox(k).BoundingBox(2):boundbox(k).BoundingBox(2)+boundbox(k).BoundingBox(4)-1,...
            boundbox(k).BoundingBox(1):boundbox(k).BoundingBox(1)+boundbox(k).BoundingBox(3)-1,:);
        imgk=cast(imgregion(k).Image,'like',cellbox);
        cellsignal{k}=cellbox.*cat(3,imgk,imgk,imgk);
        % surrounding area of every cell
        broadbox{k}=broadimg(bufferpix+boundbox(k).BoundingBox(2)-bufferpix:boundbox(k).BoundingBox(2)+boundbox(k).BoundingBox(4)-1+bufferpix*2,...
            bufferpix+boundbox(k).BoundingBox(1)-bufferpix:boundbox(k).BoundingBox(1)+boundbox(k).BoundingBox(3)-1+bufferpix*2,:);
    end
end
%% Manual identification
figure('Color',[0 0 0]) % black background for easier visualization of fluorescent images
cellid=zeros(length(boundbox),1);
for k=1:length(boundbox)
    if max(boundbox(k).BoundingBox(3:4)>10)
        ax1=subplot(1,2,1); imagesc(uint8(cellsignal{k})); axis image; hold on
        ax2=subplot(1,2,2); imagesc(uint8(broadbox{k})); axis image; hold on
        %     hold on, rectangle('Position',[bufferpix,bufferpix,boundbox(k).BoundingBox(3),boundbox(k).BoundingBox(4)],'EdgeColor','w')
        scatter(ax2,bufferpix+boundbox(k).BoundingBox(3)/2,bufferpix+boundbox(k).BoundingBox(4)/2,'w')
        % autoamtic identifcation to speed up the process
        brightimg=rmbg(cellsignal{k},[30,1]);
        brightbw=brightimg(:,:,3)>255;
        cc=bwconncomp(brightbw);
        brightcent=regionprops(cc,'centroid');
        brightcoord=[brightcent.Centroid];
        brightcoord=reshape(brightcoord,2,'');
        brightcoord=brightcoord';
        scatter(ax1,brightcoord(:,1),brightcoord(:,2),'m*')
        
        if ~isempty(brightcoord)
           cellyn='y'; 
           disp('Automatically identified as a cell.')
%            pause
        else
           cellyn=input('Is this (ABSOLUTELY) a cell? (y/n) ','s');
        end
        if cellyn=='y'
            cellid(k)=1;
        end
        clf
    else
        cellid(k)=0;
    end
end

