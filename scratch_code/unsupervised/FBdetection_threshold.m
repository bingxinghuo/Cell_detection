animalid='m820';
M=64;
bitinfo=8;
% load images
% jp2file=filelist{f};
filelist=filelsread;
[fileind,fileid]=jp2ind(filelist,'131');
[filepath,filename,ext] = fileparts(fileid)
if bitinfo==8
fluoroimg=imread(['../JP2-8bit/',filename,'.jp2']);
elseif bitinfo==12
    fluoroimg=imread(['../JP2/',filename,'.jp2']);
end
[rows,cols,C]=size(fluoroimg);
% smooth to remove sharp noise
% fluoroimg1=imfilter(single(fluoroimg),fspecial('gaussian',2*ceil(2*1)+1, 1),'same'); % mitragpu3
fluoroimg1=imgaussfilt(single(fluoroimg),1);
%% downsample using *maximum* method
clear flumax
for c=1:C
    flumax(:,:,c)=downsample_max(fluoroimg1(:,:,c),M,M);
end
% brain mask
maskfile=['imgmasks/imgmaskdata_',num2str(f)];
if exist([maskfile,'.tif'],'file')
    imgmask=imread(maskfile,'tif');
elseif exist([maskfile,'.mat'],'file')
    imgmask=load(maskfile);
    maskvar=fieldnames(imgmask);
    imgmask=getfield(imgmask,maskvar{1});
elseif exist(maskfile,'file') % no extension
    imgmask=imread(maskfile);
end
tifmask=downsample_mean(imgmask,M);
tifimg=imread(fileid);
bgimgmed=bgmean3_tif(tifimg,tifmask);
flumax1=baselineadj(flumax,bgimgmed,bgimgmed0);
%% threshold for signals
sigmask=flumax1>30; % same threshold for foreground/background distinction

%% composite mask
sigmask1=sigmask.*cat(3,imgmask1,imgmask1,imgmask1);
% Apply back to original image
FBmask=sigmask1(:,:,1);
FBmask1=repelem(FBmask,M,M);
FBmask1=FBmask1(1:rows,1:cols,1:C);
FBmask1=cast(FBmask1,'like',fluoroimg);
fluoroimg1=cast(fluoroimg1,'like',fluoroimg);
FBimg=fluoroimg1.*cat(3,FBmask1,FBmask1,FBmask1);
% FBimg should include all FB cells, 0 missing.
%% extract all 64x64 tiles
% FBmask contains all the coordinates of the signal tiles
[sigrow,sigcol]=find(FBmask);
sigrow1=(sigrow-1)*M+1;
sigcol1=(sigcol-1)*M+1;
Ntiles=size(sigrow,1); % number of tiles
tileimg=cell(Ntiles,1);
for t=1:Ntiles
    tileimg{t}=FBimg(sigrow1(t)+1:sigrow1(t)+M,sigcol1(t)+1:sigcol1(t)+M,:); % extract the tile image
end
%% locally normalize individual tile
tilenorm=cell(Ntiles,1);
for t=1:Ntiles
    tilenorm{t}=hsvadj(tileimg{t});
end
% tiles are all double precision
%% locally remove background
tilefilt=cell(Ntiles,1);
for t=1:Ntiles
    bg=imgaussfilt(tilenorm{t},20);
    tilefilt{t}=imgaussfilt(tilenorm{t},1)-bg;
end
%% k-means clustering to generate a mask
tileidx=cell(Ntiles,1);
for t=1:Ntiles
    X=reshape(tilefilt{t}*2^8,[M^2,3])+ones(M^2,1)*[1,2,3];
    idx=kmeans(X,2,'Distance','correlation');
    %     idx_v1=(2-idx)'*X(:,3); % idx=1, background
    idx_v1=sum(2-idx); % 2->0, 1->1
    %     idx_v2=(idx-1)'*X(:,3); % idx=2, cell
    idx_v2=sum(idx-1); % 1->0, 2->1
    if idx_v1<idx_v2 % more pixels in category 1
        idx=3-idx; % switch: 2-> 1, 1-> 2
    end
    
    sigmask2=reshape(idx,[M,M]);
    tileidx{t}=tilefilt{t}.*cat(3,sigmask2,sigmask2,sigmask2);
end
%%
    
    %% reassemble for visualization
%     tilevis=tilefilt;
tilevis=tileimg1;
    
    FBimg1=zeros(size(FBimg));
    for t=1:Ntiles
        FBimg1(sigrow1(t)+1:sigrow1(t)+M,sigcol1(t)+1:sigcol1(t)+M,:)=tilevis{t};
        
    end
    figure, imagesc(uint8(FBimg1))
    %%
    FBimg1=zeros(size(FBimg(:,:,1)));
    for t=1:Ntiles
        FBimg1(sigrow1(t)+1:sigrow1(t)+M,sigcol1(t)+1:sigcol1(t)+M)=tileidx{t};
    end
    FBimg2=imbinarize(FBimg1-1);
    figure, imagesc(FBimg2)