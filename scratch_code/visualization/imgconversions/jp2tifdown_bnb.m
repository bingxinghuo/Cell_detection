function []=jp2tifdown_bnb()
myCluster = parcluster('local'); % cores on compute node to be "local"
addpath(genpath('~/'))
% brainids={'m1146';'m1148';'m920';'m1145';'m1147';'m1231';'m1232'};
brainids={'m820'};
D=length(brainids);
poolobj=parpool(myCluster, 12);
M=64;
for d=1:D
    brainid=brainids{d};
    if ~exist(['~/',brainid],'dir')
        mkdir('~/',brainid)
    end
    % read JP2 files from mitraweb2
    %     jp2dir=['/nfs/mitraweb2/mnt/disk125/main/marmosetRIKEN/NZ/',brainid,'/',brainid,'F/JP2/'];
    %     jp2dir=['~/marmosetRIKEN/NZ/',brainid,'/',brainid,'F/JP2/'];
    jp2dir=['/nfs/mitraweb2/mnt/disk123/main/marmosetTEMP/JP2/',brainid,'/',brainid,'F/JP2/'];
    cd(jp2dir)
    % generate the directory to save masks, if needed
    tifdir=['~/',brainid,'/STIF-16/'];
    if ~exist(tifdir)
        mkdir(tifdir)
    end
    % read file list
    filelist=jp2lsread;
    Nfiles=length(filelist);
    parfor f=1:Nfiles
        % load image
        fileid=filelist{f};
        fluoroimg=imread(fileid,'jp2');
        [rows,cols,channels]=size(fluoroimg);
        tifimg=zeros(round(rows/M),round(cols/M),channels);
        tifsave=[tifdir,fileid(1:end-4),'.tif'];
        for c=1:channels
            tifimg(:,:,c)=downsample_mean(fluoroimg(:,:,c),M);
        end
        imwrite(tifimg,tifsave,'tif')
    end
end
delete(poolobj)