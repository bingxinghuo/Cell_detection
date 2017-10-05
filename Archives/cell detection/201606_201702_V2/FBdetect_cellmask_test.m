load FBdetectdata
% load imgmaskdata
FBclear=cell(length(FBdetected),1);
%% 1. read in files
fid=fopen('filenames.txt');
filelist=textscan(fid,'%q');
fclose(fid);
filelist=filelist{1};
imgmask=cell(length(filelist),1);
for f=1:length(filelist)
    fileid=filelist{f};
    fluoroimg=imread(fileid,'jp2');
    %% morphological operations 
    dimg=diff(diff(fluoroimg,1,1),1,2);
    dimg=sum(dimg,3);
    level=graythresh(dimg);
    dimg=im2bw(dimg,level);
    dimg=imfill(dimg,'holes');
    dimg=bwareaopen(dimg,50);
    %% use bwlabel to find the largest connected areas
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
    %% save data
    maskname=['imgmaskdata_',num2str(f)];
    save(maskname,'imgmask','-v7.3')
    %% Apply the mask to detected cells
    FBclear{f}.x=[];
    FBclear{f}.y=[];
    % check existence cell by cell
    for j=1:length(FBdetected{f}.x)
        if imgmask(round(FBdetected{f}.y(j)),round(FBdetected{f}.x(j)))==1
            FBclear{f}.x=[FBclear{f}.x;FBdetected{f}.x(j)];
            FBclear{f}.y=[FBclear{f}.y;FBdetected{f}.y(j)];
        end
    end
end
save('FBdetectdata','FBclear','-append')