cd('/scratch/celldetection')
%% 1. read file names
fid=fopen('../filenames.txt');
filelist=textscan(fid,'%q');
fclose(fid);
filelist=filelist{1};
Nfiles=length(filelist);
%% 2. load data
parfor f=1:Nfiles
    % load masks
    maskname=['imgmasks/imgmaskdata_',num2str(f),'.mat'];
    imgmask=load(maskname);
    imgout=bwperim(imgmask.savedata); % detect outline
    % expand the outline for easier visualization
    se=strel('disk',10);
    imgout=imdilate(imgout,se); 
    % load blue cells
    FBname=['cellmasks/cellmask_',num2str(f),'.mat'];
    FBcells=load(FBname);
    % load green processes
    fileid=filelist{f};
    GFPname=['../M820F_GreenOnly_process/',fileid(1:end-4),'_process'];
    GFPimg=imread(GFPname,'jp2');
    GFPimg=logical(GFPimg(:,:,2).*uint8(imgmask.savedata));
    % assemble the new image with outline
    fluoroimg_outline=cat(3,imgout,imgout,imgout);
    fluoroimg_outline(:,:,2)=logical(fluoroimg_outline(:,:,2)+GFPimg);
    fluoroimg_outline(:,:,3)=logical(fluoroimg_outline(:,:,3)+FBcells.savedata);
    %
    fluoroimgname1=['fluorooutline/',fileid(1:end-4),'_fluorooutline'];
    parsave(fluoroimgname1,fluoroimg_outline)
    % assemble the new image without outline
    [rows,cols]=size(GFPimg);
    fluoroimg_noline=cat(3,false(rows,cols),GFPimg,FBcells.savedata);
   fluoroimgname2=['fluoroonly/',fileid(1:end-4),'_fluoroonly'];
   parsave(fluoroimgname2,fluoroimg_noline)
end