filelist=jp2lsread;
Nfiles=length(filelist);
parfor f=1:Nfiles
    newcellfile=[pwd,'/cellmask/',filelist{f}(1:end-4),'_cells.jp2'];
    if ~exist(newcellfile,'file')
        cellfile=[pwd,'/cellmaskraw/',filelist{f}(1:end-4),'_cells.jp2'];
        cellmask=imread(cellfile,'jp2');
        maskfile=[pwd,'/imgmasks/imgmaskdata_',num2str(f),'.mat'];
        brainmask=load(maskfile);
        % combine
        cellmasknew=logical(logical(cellmask).*brainmask.savedata);
        % save
        imwrite(cellmasknew,newcellfile)
    end
end