%% contrastadj2.m
% Use downsampled image background to adjust histogram
% March 23, 2018
% Does not always work. Aborted.
brainid='m919';
M=64;
%%
filelist=jp2lsread;
%% 1. set standard
secid=input('Please set a section as the standard: ','s');
[f0,jp2file0]=jp2ind(filelist,secid);
fluoroimg0=imread(jp2file0);
maskfile0=['imgmasks/imgmaskdata_',num2str(f0)];
[brainimg0,bgimgmed0]=bgmean2(fluoroimg0,maskfile0);
%% 2. match tissue medians of the rest images
for f=1:length(filelist)
    % load images
    jp2file=filelist{f};
    fluoroimg=imread(jp2file);
    % load mask
    maskfile=['imgmasks/imgmaskdata_',num2str(f)];
    [brainimg,bgimgmed]=bgmean2(fluoroimg,maskfile);
    [rows,cols,~]=size(brainimg);
    adjmat=ones(rows,cols,3);
    adjmat=single(adjmat);
    for c=1:3
        adjmat(:,:,c)=adjmat(:,:,c)*(bgimgmed(c)-bgimgmed0(c));
    end
    brainimg1=single(brainimg)-adjmat;
end