function []=brainmaskbatch()
myCluster = parcluster('local'); % cores on compute node to be "local"
addpath(genpath('~/'))
brainids={'m919';'m920';'m921'};
poolobj=parpool(myCluster, 12);
for d=2
    
    brainid=brainids{d};
    if ~exist(['~/',brainid])
        mkdir('~/',brainid)
    end
    % read JP2 files from mitraweb2
    cd(['/nfs/mitraweb2/mnt/disk125/main/marmosetRIKEN/NZ/',brainid,'/',brainid,'F/JP2-REG']) 
%     if ~exist([pwd,'/','filenames.txt'])
%         system('ls -h M*.jp2 | sort -t"_" -k3 > filenames.txt');
%     end
% read file list
    fid=fopen('./filenames.txt');
    filelist=textscan(fid,'%q');
    fclose(fid);
    filelist=filelist{1};
    Nfiles=length(filelist);
    failname=['~/',brainid,'/imgmasks-REG/failmask.mat'];
    %% Generate the masks for brain section
    % generate the directory to save masks, if needed
    if ~exist([pwd,'/imgmasks/'])
        mkdir(['~/',brainid],'imgmasks-REG')
    end
    failcatch=zeros(Nfiles,1); % allocate a vector to catch failures
    
    parfor f=1:Nfiles
        try
            % load image
            fileid=filelist{f};
            fluoroimg=imread(fileid,'jp2');
            maskname=[pwd,'/imgmasks/imgmaskdata_',num2str(f),'.mat'];
            masksave=['~/',brainid,'/imgmasks-REG/imgmaskdata_',num2str(f),'.mat'];
            % load/generate brain section mask (note: there are errors in some images)
            if exist([maskname],'file')~=2  % no mask file yet
                imgmask=brainmaskfun_reg(fluoroimg)
                parsave(masksave,imgmask)
            end
        catch ME
            f
            failcatch(f)=1;
            rethrow(ME)
        end
    end
    save(failname,'failcatch')
    
end
delete(poolobj)
