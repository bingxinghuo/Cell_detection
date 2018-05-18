%% Parameters
M=64;
Ithresh=30;
sigma=[30,1];
sizepar=[40,5000];
brainid='m919';
secid='0306';
%% load image
% jp2dir=['~/marmosetRIKEN/NZ/',brainid,'/',brainid,'F/JP2/']; % go to the directory of JP2
jp2dir=['/Users/bingxinghuo/CSHLservers/mitragpu3/marmosetRIKEN/NZ/',brainid,'/',brainid,'F/JP2/']; % go to the directory of JP2
cd(jp2dir)
filelist=jp2lsread;
[f,jp2file]=jp2ind(filelist,secid);
fluoroimg=imread(jp2file);
%% Apply mask
maskfile=['imgmasks/imgmaskdata_',num2str(f)];
if exist([maskfile,'.tif'],'file')
    imgmask=imread(maskfile,'tif');
elseif exist([maskfile,'.mat'],'file')
    imgmask=load(maskfile);
    maskvar=fieldnames(imgmask);
    imgmask=getfield(imgmask,maskvar{1});
end
imgmask=uint16(imgmask);
fluoroimg=fluoroimg.*cat(3,imgmask,imgmask,imgmask);
%% Preprocess
% load standard median for 3 channels
load('background_standard') % this loads variable bgimgmed0
% calculate background median
tiffile=['../',upper(brainid),'F-STIF/',jp2file(1:end-4),'.tif'];
fluimg=imread(tiffile);
% load mask
maskfile=['imgmasks/imgmaskdata_',num2str(f)];
[~,bgimgmed]=bgmean3(tiffile,maskfile);
% Make background adjustment on raw image
adjmat=ones(size(fluoroimg));
for c=1:3
    adjmat(:,:,c)=adjmat(:,:,c)*(bgimgmed(c)-bgimgmed0(c));
end
fluoroimg1=double(fluoroimg);
fluoroimg1=fluoroimg1-adjmat;
%% Select ROI
figure, imagesc(uint8(fluimg))
ROIhandle=imrect(gca);
ROIpos=getPosition(ROIhandle);
ROIpos=round(ROIpos);
ROIpos1=ROIpos*64;
rgbimg=fluoroimg1(ROIpos1(2):ROIpos1(2)+ROIpos1(4),ROIpos1(1):ROIpos1(1)+ROIpos1(3),:);
%% remove background
rgbimg1=rmbg(rgbimg,sigma);
%% First weak screening
blueimg_down=downsample_max(rgbimg1(:,:,3),M);
FBmask=blueimg_down>Ithresh;
%% extract all MxM tiles
% FBmask contains all the coordinates of the signal tiles
[sigrow,sigcol]=find(FBmask);
sigrow1=(sigrow-1)*M+1;
sigcol1=(sigcol-1)*M+1;
Ntiles=size(sigrow,1); % number of tiles
tileimg=cell(Ntiles,1);
tilenorm=cell(Ntiles,1);
for t=1:Ntiles
    tileimg{t}=rgbimg1(sigrow1(t)+1:sigrow1(t)+M,sigcol1(t)+1:sigcol1(t)+M,:); % extract the tile image
    % color filter
    %     tilenorm{t}=hsvadj(tileimg{t});
end
%% reassemble
tilevis=tileimg;
FBimg=zeros(size(rgbimg));
for t=1:Ntiles
    FBimg(sigrow1(t)+1:sigrow1(t)+M,sigcol1(t)+1:sigcol1(t)+M,:)=tilevis{t};
    
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
idx1=zeros(length(idx),1);
boundbox=regionprops(L,'BoundingBox');
imgregion=regionprops(L,'Image');
% bufferpix=ceil(2/.46); % move half a cell in each direction
bufferpix=100;
[h,w,c]=size(rgbimg1);
broadimg=zeros(h+bufferpix*2,w+bufferpix*2,c);
broadimg(bufferpix+1:bufferpix+h,bufferpix+1:bufferpix+w,:)=rgbimg1; % outside of the image is 0
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
        cellbox=rgbimg1(boundbox(k).BoundingBox(2):boundbox(k).BoundingBox(2)+boundbox(k).BoundingBox(4)-1,...
            boundbox(k).BoundingBox(1):boundbox(k).BoundingBox(1)+boundbox(k).BoundingBox(3)-1,:);
        imgk=single(imgregion(k).Image);
        cellsignal{k}=cellbox.*cat(3,imgk,imgk,imgk);
        % surrounding area of every cell
        broadbox{k}=broadimg(bufferpix+boundbox(k).BoundingBox(2)-bufferpix:boundbox(k).BoundingBox(2)+boundbox(k).BoundingBox(4)-1+bufferpix*2,...
            bufferpix+boundbox(k).BoundingBox(1)-bufferpix:boundbox(k).BoundingBox(1)+boundbox(k).BoundingBox(3)-1+bufferpix*2,:);
    end
end
%% Manual identification
figure
cellid=zeros(length(boundbox),1);
for k=1:length(boundbox)
    subplot(1,2,1), imagesc(uint8(cellsignal{k}))
    subplot(1,2,2), imagesc(uint8(broadbox{k}))
    %     hold on, rectangle('Position',[bufferpix,bufferpix,boundbox(k).BoundingBox(3),boundbox(k).BoundingBox(4)],'EdgeColor','w')
    hold on, scatter(bufferpix+boundbox(k).BoundingBox(3)/2,bufferpix+boundbox(k).BoundingBox(4)/2,'w')
    cellyn=input('Is this (ABSOLUTELY) a cell? (y/n) ','s');
    if cellyn=='y'
        cellid(k)=1;
    end
    clf
end
%% identify images with more than 1 cells
cellind=find(cellid);
cellpix=zeros(1,length(cellind));
k=0;
clear cellsignal1
figure
for i=1:length(cellind)
    cellmask=cellsignal{cellind(i)}(:,:,3)>Ithresh;
    cellpix=sum(sum(cellmask));
    if cellpix<400 % likely only one cell
        k=k+1;
        cellsignal1{k}=cellsignal{cellind(i)}; % save in a new cell
    else % likely more than one cell
        ax1=subplot(1,2,1); imagesc(uint8(cellsignal{cellind(i)}))
        ax2=subplot(1,2,2);imagesc(cellmask)
        cellcut=input('Does this need further segmentation? (y/n) ','s');
        if cellcut=='y'
            % manual cut
            [h,w,c]=size(cellsignal{cellind(i)});
            cutmask=zeros(h,w);
            
            % identify pairs of points to cut the image
            [xi,yi]=getpts(ax2);
            N=length(xi);
            xi=reshape(xi,2,N/2);
            yi=reshape(yi,2,N/2);
            for p=1:N/2
                h=imline(gca,[xi(1,p),yi(1,p);xi(2,p),yi(2,p)]);
                cutmask=cutmask+createMask(h);
            end
            %
            se=strel('disk',1);
            cutmask=imdilate(cutmask,se);
            cutmask=1-cutmask;
            cellmask=cellmask.*cutmask; % new cut cell mask
            % get individual regions
            cc=bwconncomp(cellmask);
            Lcell=labelmatrix(cc);
            boundboxcell=regionprops(Lcell,'BoundingBox');
            cellregion=regionprops(Lcell,'Image');
            imagesc(Lcell)
            % identify cells
            title('Click on the cells','fontsize',20)
            [xi,yi]=getpts(ax2);
            yi=round(yi);
            xi=round(xi);
            % get the cell labels
            for p=1:length(xi)
                k=k+1;
                icell=Lcell(yi(p),xi(p));
                
                boundboxcell(icell).BoundingBox=round(boundboxcell(icell).BoundingBox);
                cellbox=cellsignal{cellind(i)}(boundboxcell(icell).BoundingBox(2):boundboxcell(icell).BoundingBox(2)+boundboxcell(icell).BoundingBox(4)-1,...
                    boundboxcell(icell).BoundingBox(1):boundboxcell(icell).BoundingBox(1)+boundboxcell(icell).BoundingBox(3)-1,:);
                imgk=single(cellregion(icell).Image);
                cellsignal1{k}=cellbox.*cat(3,imgk,imgk,imgk);
            end
        else
            k=k+1;
            cellsignal1{k}=cellsignal{cellind(i)};
        end
        clf
    end
end
    
    
