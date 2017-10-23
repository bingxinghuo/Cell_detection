function []=svmcellwrapper_bnb()
myCluster = parcluster('local'); % cores on compute node to be "local"
addpath(genpath('~/'))
brainids={'m920';'m919'};
poolobj=parpool(myCluster, 12);
for d=2:2
    
    brainid=brainids{d};
    % read JP2 files from mitraweb2
    cd(['/nfs/mitraweb2/mnt/disk125/main/marmosetRIKEN/NZ/',brainid,'/',brainid,'F/JP2-REG'])
    svmmodel=load('../cellsvm.mat');
    svmmodel=svmmodel.svmmodel;
    % read file list
    filelist=jp2lsread;
    Nf=length(filelist);
    failmsg=cell(Nf,1); % allocate a vector to catch failures
    parfor f=1:Nf
        try
            fileid=filelist{f};
            fileout=['~/',brainid,'/cells/',fileid(1:end-4),'_cells.jp2'];
            if ~exist(fileout,'file') % avoid re-processing detections
                fluoroimg=imread(fileid,'jp2');
                svmcellblock(fluoroimg,2,svmmodel,fileout)
            end
        catch ME
            f
            failmsg{f}=ME;
        end
    end
    save(['~/',brainid,'/failimgs'],'failmsg')
end
delete(poolobj)
