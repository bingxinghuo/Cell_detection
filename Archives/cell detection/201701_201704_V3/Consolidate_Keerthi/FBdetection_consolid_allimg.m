%% FBdetection_consolid_allimg.m
% Bingxing Huo
% This script detects the FB labeled cell bodies in all fluorescent images 
%% 0. Preparation
global bitinfo
% 0.1 read in file list
fid=fopen('filenames.txt');
filelist=textscan(fid,'%q');
fclose(fid);
filelist=filelist{1};
Nfiles=length(filelist);
% 0.2 initialize
FBdetected=cell(Nfiles,1);
FBclear=cell(Nfiles,1);
% info on bits
fileinf=imfinfo(filelist{1});
bitinfo=fileinf.BitsPerSample;
if bitinfo==[8,8,8]
    bitinfo=8;
elseif bitinfo==[16, 16, 16]
    bitinfo=12;
end
%% 1. Go through every image
parfor f=1:Nfiles
    try
    % 1.1 load image
    fileid=filelist{f};
    fluoroimg=imread(fileid,'jp2');
    % 1.2 generate and save the mask
    imgmask=brainmaskfun_16bit(fluoroimg); % generate a mask for the brain region
    maskname=['imgmasks/imgmaskdata_',num2str(f)]; % save the mask
    parsave(maskname,imgmask)
    % 1.3 detect cells
    centroids=FBdetection_consolid_v2_2014(fluoroimg);
    FBdetected{f}.x=centroids(:,1);
    FBdetected{f}.y=centroids(:,2);
    % 1.4 clean up
    FBclear{f}=maskclean(FBdetected{f},imgmask);
    catch
        f
    end
end
%% E. Save all detected cells into one variable
save('FBdetectdata_consolid','FBclear')