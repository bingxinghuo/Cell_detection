%% fluorimgadj.m
% Bingxing Huo, May 2018
% This script performs background correction for individual sections
% Can work with fluorimgadj_bnb.m
% brainid='m919';
%
% jp2dir=['/Users/bingxinghuo/CSHLservers/mitragpu3/marmosetRIKEN/NZ/',brainid,'/',brainid,'F/JP2/']; % go to the directory of JP2
function fluoroimg1=fluorimgadj(animalid,datadir,f,bgimgmed0)
animalid=lower(animalid); % in case the input is upper case
fludir=[datadir,animalid,'/',animalid,'F/JP2/'];
if ~exist(fludir,'dir')
    fludir=[datadir,animalid,'/',animalid,'F/JP2-8bit/'];
end
cd(fludir)
sigma=[30,1];
%% read new image
filelist=jp2lsread;
jp2file=filelist{f};
fluoroimg=imread(jp2file);
%% Apply mask
maskfile=[fludir,'imgmasks/imgmaskdata_',num2str(f)];
if exist([maskfile,'.tif'],'file')
    imgmask=imread(maskfile,'tif');
elseif exist([maskfile,'.mat'],'file')
    imgmask=load(maskfile);
    maskvar=fieldnames(imgmask);
    imgmask=getfield(imgmask,maskvar{1});
end
imgmask=cast(imgmask,'like',fluoroimg);
fluoroimg=fluoroimg.*cat(3,imgmask,imgmask,imgmask);
%% Preprocess
% calculate background median
tiffile=['../',upper(animalid),'F-STIF/',jp2file(1:end-4),'.tif'];
fluimg=imread(tiffile);
% get background info
[~,bgimgmed]=bgmean3(tiffile,maskfile);
% Make background adjustment on raw image
adjmat=ones(size(fluoroimg));
for c=1:3
    adjmat(:,:,c)=adjmat(:,:,c)*(bgimgmed(c)-bgimgmed0(c));
end
fluoroimg1=double(fluoroimg);
fluoroimg1=fluoroimg1-adjmat;
% Image contrast boost by applying DoG
% ****Note: Use at least 128G RAM to run Gaussian filters***
fluoroimg_bg=imgaussfilt(fluoroimg1,sigma(1));
fluoroimg_fg=imgaussfilt(fluoroimg1,sigma(2));
fluoroimg1=fluoroimg_fg-fluoroimg_bg;
fluoroimg1=cast(fluoroimg1,'like',fluoroimg);
end
