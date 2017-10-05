%% 1. read in files
fid=fopen('filenames.txt');
filelist=textscan(fid,'%q');
fclose(fid);
filelist=filelist{1};
imgmask=cell(length(filelist),1);
parfor f=1:length(filelist)
    fileid=filelist{f};
    fluoroimg=imread(fileid,'jp2');
    dimg=diff(diff(fluoroimg,1,1),1,2);
    dimg=sum(dimg,3);
    level=graythresh(dimg);
    dimg=im2bw(dimg,level);
    dimg=imfill(dimg,'holes');
    dimg=bwareaopen(dimg,50);
    rows=size(fluoroimg,1);
    columns=size(fluoroimg,2);
    bw2=bwselect(dimg,round(columns/2),round(rows/2),8);
    imgmask{f}=zeros(rows, columns);
    imgmask{f}(1:end-1,1:end-1)=bw2;
%     clear dimg bw2
end
save('imgmaskdata','imgmask')