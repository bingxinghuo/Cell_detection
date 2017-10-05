%% 1. read file names
fid=fopen('filenames.txt');
filelist=textscan(fid,'%q');
fclose(fid);
filelist=filelist{1};
Nfiles=length(filelist);
%% 2. load data
parfor f=1:Nfiles
    % 1.1 load image
    fileid=filelist{f};
    fluoroimg=imread(fileid,'jp2');
    % 1.2 generate and save the mask
    maskname=['imgmasks/imgmaskdata_',num2str(f),'.mat'];
    if exist([pwd,'/',maskname],'file')==2
        imgmask=load(maskname);
        maskvar=fieldnames(imgmask);
        imgmask=getfield(imgmask,maskvar{1});
    else
        %     imgmask=load(maskname);
        imgmask=brainmaskfun_reg(fluoroimg);
        parsave(maskname,imgmask)
    end
    % 1.3 generate and save outline
    outfile=['outlines/M820_outline_',num2str(f)];
    if exist([pwd,'/',outfile],'file')~=2
        imgout=bwperim(imgmask); % detect outline
        % expand the outline for easier visualization
        se=strel('disk',10);
        imgout=imdilate(imgout,se);
        parsave(outfile,imgout)
    end
end