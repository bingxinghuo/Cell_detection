%% brainmaskfun_16bittif.m
% Bingxing Huo, March 2018
% modified from brainmaskfun_16bit.m
% This code automatically detects the brain slice in the 12-bit fluorescent image
% and saves the mask as a .mat file.
function imgmask0=brainmaskfun_16bittif(jp2file,tifdir,jp2dir,maskarea)
fluorotif=[tifdir,jp2file(1:end-4),'.tif'];
M=64;
if exist(fluorotif,'file')
    fluimg=imread(fluorotif,'tif');
else  % no small tif
    if ~exist(tifdir)
        mkdir(tifdir)
    end
    % generate small tif for future use
    fluoroimg=imread([jp2dir,jp2file]);
    for c=1:3
        fluimg(:,:,c)=downsample_mean(fluoroimg(:,:,c),M);
    end
    imwrite(fluimg,fluorotif,'tif')
end
%% 1. adjust image
% 1.1 convert color scale
fluimg1=single(fluimg)/2^12*2^8;
imgmask=imgmaskgen(fluimg1,1,maskarea/M^2);
%% convert back to original resolution
imgsize=imfinfo([jp2dir,jp2file]);
imgwidth=imgsize.Width;
imgheight=imgsize.Height;
imgmask0=false(imgheight, imgwidth);
imgmask1=repelem(imgmask,M,M);
[rows,cols]=size(imgmask1);
if rows>imgheight
    imgmask1=imgmask1(1:imgheight,:);
end
if cols>imgwidth
    imgmask1=imgmask1(:,1:imgwidth);
end
imgmask0(1:imgheight,1:imgwidth)=imgmask1;
% smooth the mask edge
% sigma=10;
% imgmask0 = imfilter(imgmask0,fspecial('gaussian',2*ceil(2*sigma)+1, sigma),'replicate');