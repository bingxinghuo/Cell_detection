%% cellmask.m
% Bingxing Huo, August 2016
% Version 3
% This code automatically detects the brain slice in the fluorescent image
% and saves the mask as a .mat file.
%% 1. read in files
fid=fopen('filenames.txt');
filelist=textscan(fid,'%q');
fclose(fid);
filelist=filelist{1};
if strcmp(filelist{1},'filenames.txt')==1
    filelist=filelist(2:end);
end
%% 2. Find mask for every slice
% imgmask=cell(length(filelist),1);
parfor f=1:length(filelist)
    fileid=filelist{f};
    fluoroimg=imread(fileid,'jp2');
    % collect all the info in 3 channels
    fluoroimg1=sum(fluoroimg,3);
    % take first derivative
    dimg=diff(diff(fluoroimg1,1,1),1,2);
    % Find the threshold using Otsu's method
    level=graythresh(dimg);
    % Apply threshold to remove noise
    dimg=im2bw(dimg,level);
    % Connect adjacent bojects
    dimg=imfill(dimg,'holes');
    % Clear up scattered noise
    dimg=bwareaopen(dimg,50);
    % Detect objects
    L=bwlabel(dimg);
    rows=size(fluoroimg,1);
    columns=size(fluoroimg,2);
    % Obtain the connectivity information
    CC=bwconncomp(dimg);
    % Obtain the area of each object
    num=zeros(CC.NumObjects,1);
    for i=1:CC.NumObjects
        num(i)=length(CC.PixelIdxList{i});
    end
    % Threshold the area of each object
    totpix=rows*columns;
    [num1,numind]=find(num>totpix*.001);
    bw2=logical(zeros(rows-1, columns-1,'single'));
    for i=1:length(num1)
        bw2=bw2+(L==num1(i));
    end
    % Pad with zeros to obtain a mask for the original image
    imgmask=logical(zeros(rows, columns,'single'));
    imgmask(1:end-1,1:end-1)=bw2;
    % Save
    parsave(f,imgmask)
end
