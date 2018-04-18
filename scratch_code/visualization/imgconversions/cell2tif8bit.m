function []=cell2tif8bit()
myCluster = parcluster('local'); % cores on compute node to be "local"
addpath(genpath('~/'))
poolobj=parpool(myCluster, 12);
% brainids={'m1144';'m917';'m918';'m919';'m922'};
% brainids={'m921';'m1146';'m1148';'m920'};
brainids={'m1148'};
D=length(brainids);
for d=1:D
    brainid=brainids{d};
    % jp2dir=['/Users/bingxinghuo/CSHLservers/mitragpu3/marmosetRIKEN/NZ/',brainid,'/',brainid,'F/JP2/']; % go to the directory of JP2
    jp2dir=['~/marmosetRIKEN/NZ/',brainid,'/',brainid,'F/JP2/']; % go to the directory of JP2
    cd(jp2dir)
    celldir=['~/',brainid,'/cellmasks8bit/'];
    if ~exist(['~/',brainid],'dir')
        mkdir(['~/',brainid])
    end
    if ~exist(celldir,'dir')
        mkdir(celldir)
    end
    load([jp2dir,'FBdetectdata_consolid.mat'])
    filelist=jp2lsread;
    Nfiles=length(filelist);
    M=64;
    parfor f=1:Nfiles
        fileid=filelist{f};
        cellsave=[celldir,fileid(1:end-4),'.tif'];
        if ~exist(cellsave,'file')
            jp2info=imfinfo(fileid);
            cellmask=uint8(false(jp2info.Height,jp2info.Width));
            cellind=FBclear{f};
            cellind.x=round(cellind.x);
            cellind.y=round(cellind.y);
            if ~isempty(cellind.x)
                for c=1:size(cellind.x,1)
                    cellmask(cellind.y(c),cellind.x(c))=255;
                end
            end
            celldown=downsample_max(cellmask,M);
            imwrite(celldown,cellsave,'tif');
        end
    end
end