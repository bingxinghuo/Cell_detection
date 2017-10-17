% this is a wrapper function for cell detection across the whole brain
cd('/nfs/data/main/M25/marmosetRIKEN/NZ/m920/m920F/JP2-REG/')
load('../cellsvm.mat')
filelist=jp2lsread;
Nf=length(filelist);
parfor f=1:Nf
    fileid=filelist{f};
    fileout=['/scratch/marmosets/m920/',fileid(1:end-4),'_cells.jp2'];
    if exist([pwd,'/',fileout],'file')~=2 % avoid re-processing detections
        fluoroimg=imread(fileid,'jp2');
        svmcellblock(fluoroimg,2,svmmodel,fileid)
    end
end
