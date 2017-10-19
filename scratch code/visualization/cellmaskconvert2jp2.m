filelist=jp2lsread;
Nfiles=length(filelist);
for f=1:Nfiles
    tic;
    fileid=filelist{f};
    cellfile=[pwd,'/cellmasks/cellmask_',num2str(f),'.mat'];
    load(cellfile);
    jp2file=[pwd,'/cellmasks/jp2/',fileid(1:end-4),'_cells.jp2'];
    imwrite(savedata,jp2file,'jp2')
    toc
end