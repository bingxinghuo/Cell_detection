%% batch background correction
% brainid='m919';
%
% jp2dir=['/Users/bingxinghuo/CSHLservers/mitragpu3/marmosetRIKEN/NZ/',brainid,'/',brainid,'F/JP2/']; % go to the directory of JP2
function fluorimgadj(animalid,animaldir,sec0,sec1,savedir)
% sigma=[30,1];
animalid=lower(animalid); % in case the input is upper case
fludir=[animaldir,'/',animalid,'F/JP2/'];
cd(fludir)
filelist=jp2lsread;
[f0,~]=jp2ind(filelist,sec0);
[f1,~]=jp2ind(filelist,sec1);
if ~exist(savedir)
    mkdir(savedir)
end
% load standard median for 3 channels
load('background_standard') % this loads variable bgimgmed0
parfor f=f0:f1
    jp2file=filelist{f};
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
    fluoroimg_bg=imgaussfilt(fluoroimg1,30);
    fluoroimg_fg=imgaussfilt(fluoroimg1,1);
    fluoroimg1=fluoroimg_fg-fluoroimg_bg;
    % save
    imwrite(fluoroimg1,[savedir,jp2file])
end
