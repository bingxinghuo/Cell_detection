function []=cell2tif8bit_A1V1()
myCluster = parcluster('local'); % cores on compute node to be "local"
addpath(genpath('~/'))
poolobj=parpool(myCluster, 12);
brainids={'m820';'m822'};
secinds={[86,89:96,98:101,103:112];[93,96:98,100,101]}; % files of interest
D=length(brainids);
for d=1:D
    brainid=brainids{d};
    % Identify JP2 directory
    % jp2dir=['/Users/bingxinghuo/CSHLservers/mitragpu3/marmosetRIKEN/NZ/',brainid,'/',brainid,'F/JP2/']; % go to the directory of JP2
    %     jp2dir=['~/marmosetRIKEN/NZ/',brainid,'/',brainid,'F/JP2/']; % go to the directory of JP2
    jp2dir=['/nfs/mitraweb2/mnt/disk123/main/marmosetTEMP/JP2/',brainid,'/']; % go to the temporary directory of JP2 on M24
    %
    cd(jp2dir)
    celldir=['~/',brainid,'/cellmasks8bit_A1V1/'];
    if ~exist(['~/',brainid],'dir')
        mkdir(['~/',brainid])
    end
    if ~exist(celldir,'dir')
        mkdir(celldir)
    end
    % Identify sections
    secind=secinds{d};
    
    
    % Get cells
    cellcoorddata=load([jp2dir,'cellfullcoord.mat']);
    cellcoordfull=cellcoorddata.cellcoordfull;
    % NOTE: need to generate filenames.txt before running this from BNB
    filelist=jp2lsread; % get all the file names, including F and N
    Nfiles=length(secind);
    %     M=64;
    parfor f=1:Nfiles
        try
        [~,fileid]=jp2ind(filelist,['F',num2str(secind(f))]);
        cellsave=[celldir,fileid(1:end-4),'.tif'];
        if ~exist(cellsave,'file')
            jp2info=imfinfo(fileid);
            cellmask=uint8(false(jp2info.Height,jp2info.Width));
            cellind=cellcoordfull{f};
            if ~isempty(cellind)
                for c=1:size(cellind,1)
                    cellmask(cellind(c,2),cellind(c,1))=255;
                end
            end
            %             celldown=downsample_max(cellmask,M);
            cellmask=uint8(cellmask);
            imwrite(cellmask,cellsave,'tif');
        end
        catch ME
            f
            fileid
            rethrow(ME)
        end
    end
end