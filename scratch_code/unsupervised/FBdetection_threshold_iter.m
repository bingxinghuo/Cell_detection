filelist=jp2lsread;
[f,jp2file]=jp2ind(filelist,'491');
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
% Make background adjustment on raw image
adjmat=ones(size(fluoroimg));
for c=1:3
    adjmat(:,:,c)=adjmat(:,:,c)*(bgimgmed(c)-bgimgmed0(c));
end
fluoroimg1=double(fluoroimg);
fluoroimg1=fluoroimg1-adjmat;
% Image contrast boost by applying DoG
% ****Note: Use at least 128G RAM to run Gaussian filters***
fluoroimg_bg=imgaussfilt(fluoroimg1,30);
fluoroimg_fg=imgaussfilt(fluoroimg1,1);
fluoroimg1=fluoroimg_fg-fluoroimg_bg;
%% signal threshold for filtered image
Ithresh=30;
%% Cascade 1: on entire image
M=64;
%% 1.1 downsample using *maximum* method
clear flumax
for c=1:3
    flumax(:,:,c)=downsample_max(fluoroimg1(:,:,c),M);
end
%% 1.2 threshold for signals
sigmask=flumax>Ithresh; 
imgmask1=downsample_mean(imgmask,M);
% composite mask
imgmask1=logical(imgmask1);
sigmask1=sigmask.*cat(3,imgmask1,imgmask1,imgmask1);
%% 1.3 Apply back to original resolution image
FBmask=sigmask1(:,:,3);
FBmask1=repelem(FBmask,M,M);
FBmask1=uint16(FBmask1);
FBimg=fluoroimg1.*cat(3,FBmask1,FBmask1,FBmask1);
%% 1.4 extract all MxM tiles
% FBmask contains all the coordinates of the signal tiles
[sigrow,sigcol]=find(FBmask);
sigrow1=(sigrow-1)*M+1;
sigcol1=(sigcol-1)*M+1;
Ntiles=size(sigrow,1); % number of tiles
tileimg=cell(Ntiles,1);
for t=1:Ntiles
    tileimg{t}=FBimg(sigrow1(t)+1:sigrow1(t)+M,sigcol1(t)+1:sigcol1(t)+M,:); % extract the tile image
end
%% Cascade 2: on individual tile ***Note effective 
% M2=2;
% tileimg1=cell(size(tileimg));
% FBimg1=zeros(size(FBimg));
% FBmask2=zeros(size(FBimg(:,:,3)));
% for t=1:Ntiles
%     Stile=tileimg{t};
%     % 2.1 downsample
%     clear flumax
%     for c=1:3
%         flumax(:,:,c)=downsample_max(Stile(:,:,c),M2);
%     end
%     % 2.2 threshold for signals
%     sigmask=flumax>Ithresh;
%     % 2.3 Apply back to original resolution image
%     Smask=sigmask(:,:,3);
%     Smask1=repelem(Smask,M2,M2);
%     Smask1=uint16(Smask1);
%     tileimg1{t}=Stile.*cat(3,Smask1,Smask1,Smask1);
%     % 2.4 reassemble
%     FBimg1(sigrow1(t)+1:sigrow1(t)+M,sigcol1(t)+1:sigcol1(t)+M,:)=tileimg1{t};
%     FBmask2(sigrow1(t)+1:sigrow1(t)+M,sigcol1(t)+1:sigcol1(t)+M,:)=logical(Smask1);
% end
% %% 2.5 extract all M2xM2 tiles
% FBmask2ds=downsample_max(FBmask2,M2);
% [sigrow,sigcol]=find(FBmask2ds);
% sigrow1=(sigrow-1)*M2+1;
% sigcol1=(sigcol-1)*M2+1;
% Ntiles=size(sigrow,1); % number of tiles
% tileimg2=cell(Ntiles,1);
% for t=1:Ntiles
%     tileimg2{t}=FBimg1(sigrow1(t)+1:sigrow1(t)+M2,sigcol1(t)+1:sigcol1(t)+M2,:); % extract the tile image
% end
%% Pixel-level filtering and get connected objects
FBmask2=FBimg(:,:,3)>Ithresh;
%% detect centroids
    cc=bwconncomp(FBmask2);
    rprops = regionprops(cc,'centroid');
    centroids=reshape([rprops.Centroid],2,[])';
%% 2.1 downsample

%%
fluoroimgit=flumax1;
sigmask=cell(4,1);
for i=1:4
    % feature extraction
    % color
    % intensity
    % max pooling
    clear flumax
    for c=1:3
        flumax(:,:,c)=downsample_max(fluoroimgit(:,:,c),m);
    end
    % rectifier
    sigmask{i}=flumax1>50; % same threshold for foreground/background distinction
    fluoroimgit=flumax.*cat(3,sigmask{i},sigmask{i},sigmask{i});
end