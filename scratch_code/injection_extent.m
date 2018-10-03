%% 1. Use registered images
filelist=jp2lsread;
mkdir('imgmasks')
% 1.1 batch downsample on mitragpu3
% ~/scripts/shell_script/convert_jp2_tif.sh m1229 M >/dev/null 
fileid=filelist{f}(1:end-4);
fluimg=imread(fileid);
% 1.2 generate mask (brainmaskfun_16bittif.m)
fluimg1=single(fluimg)/2^12*2^8;
imgmask=imgmaskgen(fluimg1,1);
maskfile=['imgmasks/imgmaskdata_',num2str(f)];
imwrite(imgmask,maskfile,'tif')
%% 2. adjust background
load('../JP2/background_standard.mat') % load bgimgmed0
tiffile=[fileid,'.tif'];
[brainimg,bgimgmed]=bgmean3(tiffile,maskfile);
[rows,cols,~]=size(brainimg);
adjmat=ones(rows,cols,3);
adjmat=single(adjmat);
for c=1:3
    adjmat(:,:,c)=adjmat(:,:,c)*(bgimgmed(c)-bgimgmed0(c));
end
fluimg1=single(fluimg)-adjmat;
%% 3. threshold to get binary image
inj_sature=fluimg1>=255;
% FB, blue channel
inj_sature=inj_sature(:,:,3);
%% 3. image processing
% 3.1 find the biggest connected component as the injection site
cc=bwconncomp(inj_sature);
numPixels = cellfun(@numel,cc.PixelIdxList);
[biggest,idx] = max(numPixels);
inj_mask=false(size(inj_sature));
inj_mask(cc.PixelIdxList{idx})=inj_sature(cc.PixelIdxList{idx});
% 3.2 adjust the area
inj_mask=imfill(inj_mask,'holes');% fill holes
