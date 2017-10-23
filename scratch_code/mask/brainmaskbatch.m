% function brainmaskbatch(brainid,nslots)
% myCluster = parcluster('local'); % cores on compute node to be "local"

cd(['~/marmosetRIKEN/NZ/',brainid,'/',brainid,'F/JP2-REG']) % go to the directory of JP2
if ~exist([pwd,'/','filenames.txt'])
    system('ls -h M*.jp2 | sort -t"_" -k3 > filenames.txt');
end
fid=fopen('filenames.txt');
filelist=textscan(fid,'%q');
fclose(fid);
filelist=filelist{1};
Nfiles=length(filelist);
% Generate the masks for brain section
if ~exist([pwd,'/imgmasks/'])
    mkdir('imgmasks')
end
failcatch=zeros(Nfiles,1); % allocate a vector to catch failures
% poolobj=parpool(myCluster, nslots);
parfor f=1:Nfiles
    try
        % load image
        fileid=filelist{f};
        fluoroimg=imread(fileid,'jp2');
        maskname=['imgmasks/imgmaskdata_',num2str(f),'.mat'];
        % load/generate brain section mask (note: there are errors in some images)
        if exist([pwd,'/',maskname],'file')~=2  % no mask file yet
            imgmask=brainmaskfun_reg(fluoroimg)
            parsave(maskname,imgmask)
        end
    catch ME
        f
        failcatch(f)=1;
        rethrow(ME)
    end
end
% delete(poolobj)
