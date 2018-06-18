function tfcellcoord=readtfcellcoord(tfcellimgfile)
% 5.1 get cell coordinates from transformed cell masks
% 5.1.1 load cell image
cellimg=imread(tfcellimgfile);
% cellimg=imread([animalid,'/',animalid,'_cells/cellmask2Nissl/cell',fileid{s}(end-7:end)]);
% 5.1.2 generate a mask to crop the cell image
% tfimg=imread([animalid,'/',animalid,'F2N/tf',fileid{s}(end-7:end)]);
% tfimg=imread(tffluimgfile);
% secmask=tfimg>0;
% se=strel('disk',5);
% secmask=imerode(secmask,se);
% secmask(:,1:5)=0;
% secmask(1:5,:)=0;
% 5.1.3 crop the image
% cellimg=cellimg.*secmask;
% 5.1.4 find cell centers
if sum(sum(cellimg>10))>0
    bw=imregionalmax(cellimg.*(cellimg>10));
    [cellx,celly]=find(bw);
    tfcellcoord=[cellx,celly];
else
    tfcellcoord=[];
end