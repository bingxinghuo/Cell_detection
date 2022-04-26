function [brainimg0,bgimgmed0,jp2file0]=bgstandard(filelist,tifdir,maskdir,M,savedir)
secid0=input('Please set a section as the standard: ','s');
[f0,jp2file0]=jp2ind(filelist,secid0);
[~,filename,~]=fileparts(jp2file0);
tiffile0=[tifdir,'/',filename,'.tif'];
maskfile0=[maskdir,'/',filename,'.tif'];
if ~exist(maskfile0,'file')
    maskfile0=[maskdir,'/imgmaskdata_',num2str(f0)];
    if ~exist(maskfile0,'file')
        maskfile0=[maskfile0,'.tif'];
        if ~exist(maskfile0,'file')
            disp('Please generate mask images for jp2 files first!')
            disp('Hint: Run following code locally: brainmaskbatch.m')
        end
    end
end
[brainimg0,bgimgmed0]=bgmean3(tiffile0,maskfile0,M);
if nargin>3
    save([savedir,'/background_standard.mat'],'bgimgmed0','brainimg0','jp2file0')
end