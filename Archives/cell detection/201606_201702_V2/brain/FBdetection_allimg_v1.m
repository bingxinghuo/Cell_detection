%% FB_detection.m
% This script detects the FB labeled cell bodies in 12-bit RGB images using
% color segmentation and watershed method
%% 1. read in files
fid=fopen('filenames.txt');
filelist=textscan(fid,'%q');
fclose(fid);
filelist=filelist{1};
Nfiles=length(filelist);
%%
FBdetected=cell(Nfiles,1);
FBclear=cell(Nfiles,1);
injarea=cell(Nfiles,1);
win.width=500; % columns
win.height=400; % rows
% load FBdetectdata
fileinf=imfinfo(filelist{1});
bitinfo=fileinf.BitsPerSample;
if bitinfo==[8,8,8]
    bitinfo=8;
elseif bitinfo==[16, 16, 16]
    bitinfo=12;
end
%%
parfor f=1:Nfiles
    fileid=filelist{f};
    fluoroimg=imread(fileid,'jp2');
    %% 1. mask
    imgmask=cellmaskfun_16bit(fluoroimg); % generate a mask for the brain region
    % save
    maskname=['imgmasks/imgmaskdata_',num2str(f)];
    parsave(maskname,imgmask)
    %% 2. detect cells
    FBclear=layer2fun(fluoroimg,imgmask,win,f);
end
save('FBdetectdata','FBdetected')
%%
if bitinfo==8
    save('FBdetectdata','FBclear','injarea','-append')
end