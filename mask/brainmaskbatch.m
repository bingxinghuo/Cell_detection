% function brainmaskbatch(brainid,nslots)
function brainmaskbatch(brainid)
% myCluster = parcluster('local'); % cores on compute node to be "local"

% cd(['~/marmosetRIKEN/NZ/',brainid,'/',brainid,'F/JP2-REG']) % go to the directory of JP2
% jp2dir=['~/marmosetRIKEN/NZ/',brainid,'/',brainid,'F/JP2/']; % go to the directory of JP2
jp2dir=['/Users/bingxinghuo/CSHLservers/mitragpu3/marmosetRIKEN/NZ/',brainid,'/',brainid,'F/JP2/']; % go to the directory of JP2
cd(jp2dir)
%%
filelist=jp2lsread;
Nfiles=length(filelist);
% Generate the masks for brain section
if ~exist([pwd,'/imgmasks/'])
    mkdir('imgmasks')
end
failcatch=zeros(Nfiles,1); % allocate a vector to catch failures
% poolobj=parpool(myCluster, nslots);
for f=1:Nfiles
    try
        % load image
        fileid=filelist{f};
        %         fluoroimg=imread(fileid,'jp2');
        maskname=['imgmasks/imgmaskdata_',num2str(f),'.tif'];
        % load/generate brain section mask (note: there are errors in some images)
        if exist([pwd,'/',maskname],'file')~=2  % no mask file yet
            %             imgmask=brainmaskfun_reg(fluoroimg)
            imgmask=brainmaskfun_16bittif(fileid,['../',upper(brainid),'F-STIF/'],jp2dir);
            %             parsave(maskname,imgmask)
            imwrite(imgmask,maskname,'tif')
        end
    catch ME
        f
        failcatch(f)=1;
        rethrow(ME)
    end
end
% delete(poolobj)
