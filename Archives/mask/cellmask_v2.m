%% cellmask1.m
% This is a modified version of cellmask.m. Instead of using the center
% point of the image to find the connected area as the mask, we find the
% largest connected area (>0.1%; this number may be subject to change) as
% the brain mask. 
%% 1. read in files
fid=fopen('filenames.txt');
filelist=textscan(fid,'%q');
fclose(fid);
filelist=filelist{1};
imgmask=cell(length(filelist),1);
for f=1:length(filelist)
    fileid=filelist{f};
    fluoroimg=imread(fileid,'jp2');
    dimg=diff(diff(fluoroimg,1,1),1,2);
    dimg=sum(dimg,3);
    level=graythresh(dimg);
    dimg=im2bw(dimg,level);
    dimg=imfill(dimg,'holes');
    dimg=bwareaopen(dimg,50);
    L=bwlabel(dimg);
    rows=size(fluoroimg,1);
    columns=size(fluoroimg,2);
    %     bw2=bwselect(dimg,round(columns/2),round(rows/2),8);
    CC=bwconncomp(dimg);
    num=zeros(CC.NumObjects,1);
    for i=1:CC.NumObjects
        num(i)=length(CC.PixelIdxList{i});
    end
    totpix=rows*columns;
    [num1,numind]=find(num>totpix*.001);
        bw2=zeros(rows-1, columns-1);
    for i=1:length(num1)
        bw2=bw2+(L==num1(i));
    end
    imgmask=zeros(rows, columns);
    imgmask(1:end-1,1:end-1)=bw2;
    maskname=['imgmaskdata_',num2str(f)];
    save(maskname,'imgmask','-v7.3')
    %     clear dimg bw2
end