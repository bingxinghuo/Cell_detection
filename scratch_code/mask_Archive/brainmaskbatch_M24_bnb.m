function []=brainmaskbatch_M24_bnb()
myCluster = parcluster('local'); % cores on compute node to be "local"
addpath(genpath('~/'))
% brainids={'m1146';'m1148';'m920';'m1145';'m1147';'m1231';'m1232'};
brainids={'m820'};
D=length(brainids);
poolobj=parpool(myCluster, 12);
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
    % read file list
    filelist=jp2lsread;
    Nfiles=length(filelist);
    %% Generate the masks for brain section
    % generate the directory to save masks, if needed
    maskdir=['~/',brainid,'/imgmasks/'];
    if ~exist(maskdir)
        mkdir(maskdir)
    end
    %     failname=['~/',brainid,'/imgmasks/failmask.mat'];
    %     failcatch=zeros(Nfiles,1); % allocate a vector to catch failures
    parfor f=1:Nfiles
        try
            % load image
            fileid=filelist{f};
            %             maskname=[pwd,'/imgmasks/imgmaskdata_',num2str(f),'.tif'];
            masksave=[maskdir,'imgmaskdata_',num2str(f),'.tif'];
            % load/generate brain section mask (note: there are errors in some images)
            if exist(masksave,'file')~=2  % no mask file yet
%                 fluoroimg=imread(fileid,'jp2');
                imgmask=brainmaskfun_16bittif(fileid,[pwd,'/',upper(brainid),'F-STIF/'],jp2dir);
                %                 parsave(masksave,imgmask)
                imwrite(imgmask,masksave,'tif')
            end
        catch ME
            warning(num2str(f))
            %             failcatch(f)=1;
            rethrow(ME)
        end
    end
    %     save(failname,'failcatch')
    
end
delete(poolobj)
