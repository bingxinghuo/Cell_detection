%% contrastadj1.m
% Use downsampled image background to adjust histogram
% March 23, 2018
% Does not always work. Aborted.
brainid='m919';
bgimgmed0=[6;6;6]; % define a background mean
%%
filelist=jp2lsread;
for f=1:length(filelist)
    %% 1. load images
    %     jp2file=filelist{f};
    tiffile=['../',upper(brainid),'F-STIF/',jp2file(1:end-4),'.tif'];
    fluimg=imread(tiffile);
    maskfile=['imgmasks/imgmaskdata_',num2str(f)];
    bgimgmed=bgmean(tiffile,maskfile); % get the mean of the background
    [rows,cols,~]=size(fluimg);
    adjmat=ones(rows,cols,3);
    adjmat=single(adjmat);
    for c=1:3
        adjmat(:,:,c)=adjmat(:,:,c)*(bgimgmed(c)-bgimgmed0(c));
    end
    fluimg1=single(fluimg)-adjmat;
end
