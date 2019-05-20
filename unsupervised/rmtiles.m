function signalimg=rmtiles(jp2file,imgmask,tiffile,bgimgmed0,thresh)
M=64;
% load images
% jp2file=filelist{f};
fluoroimg=imread(jp2file);
% smooth to remove sharp noise
% fluoroimg1=imfilter(single(fluoroimg),fspecial('gaussian',2*ceil(2*1)+1, 1),'same'); % mitragpu3
fluoroimg1=imgaussfilt(single(fluoroimg),1);
[H,W,C]=size(fluoroimg1);
%% downsample using *maximum* method
for c=1:C
    flumax(:,:,c)=downsample_max(fluoroimg1(:,:,c),M);
end
%% brain mask
% maskfile=['imgmasks/imgmaskdata_',num2str(f)];
% if exist([maskfile,'.tif'],'file')
%     imgmask=imread(maskfile,'tif');
% elseif exist([maskfile,'.mat'],'file')
%     imgmask=load(maskfile);
%     maskvar=fieldnames(imgmask);
%     imgmask=getfield(imgmask,maskvar{1});
% else
%     imgmask=brainmaskfun_16bittif(jp2file,tiffile);
% end
imgmask1=downsample_mean(imgmask,M);
%% threshold for signals
bgimgmed=bgmean3_tif(tiffile,imgmask1);
flumax1=baselineadj(flumax,bgimgmed,bgimgmed0);
sigmask=flumax1>thresh; % thresh=30 for foreground/background distinction
%% composite mask
signalimg=uint16(size(fluoroimg));
for c=1:C
    signalmask=repelem(sigmask(:,:,c).*imgmask1);
    signalimg(:,:,c)=uint16(signalmask).*fluoroimg(:,:,c);
end