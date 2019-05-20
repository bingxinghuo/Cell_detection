%% contrastadj3.m
% Use downsampled image background to adjust histogram
% March 23, 2018
brainid='m919';
M=64;
%%
filelist=jp2lsread;
%% 1. set standard
tifdir=['../',upper(brainid),'F-STIF/'];
maskdir=[pwd,'/imgmasks'];
bgstandard(filelist,tifdir,maskdir,pwd);
%% 2. match tissue medians of the rest images
% for f=1:length(filelist)
% load images
%     jp2file=filelist{f};
secid=input('Please select a test section: ','s'); % sec 200 for m919
[f,jp2file]=jp2ind(filelist,secid);
tiffile=['../',upper(brainid),'F-STIF/',jp2file(1:end-4),'.tif'];
fluimg=imread(tiffile);
% load mask
maskfile=['imgmasks/imgmaskdata_',num2str(f)];
[brainimg,bgimgmed]=bgmean3(tiffile,maskfile);
[rows,cols,~]=size(brainimg);
adjmat=ones(rows,cols,3);
adjmat=single(adjmat);
for c=1:3
    adjmat(:,:,c)=adjmat(:,:,c)*(bgimgmed(c)-bgimgmed0(c));
end
fluimg1=single(fluimg)-adjmat;
% end