%% cell2tif8bit.m
% This script converts cell coordinates into masks in 8-bit gray image
% prepared for running on BNB cluster
% Save full-size tif files of specified images only
function []=cell2tif8bit_partial()
% myCluster = parcluster('local'); % cores on compute node to be "local"
% addpath(genpath('~/'))
% poolobj=parpool(myCluster, 12);

% brainids={'m820';'m822'};
% secinds={[86,89:96,98:101,103:112];[93,96:98,100,101]}; % files of interest
brainids={'m920'};
D=length(brainids);
for d=1:D
    brainid=brainids{d};
    
    % Identify sections
    %     secind=secinds{d};
    % intput directory
    jp2dir=['/Users/bingxinghuo/CSHLservers/mitragpu3/marmosetRIKEN/NZ/',brainid,'/',brainid,'F/JP2/']; % go to the directory of JP2
    %         jp2dir=['~/marmosetRIKEN/NZ/',brainid,'/',brainid,'F/JP2/']; % go to the directory of JP2
    %     jp2dir=['/nfs/mitraweb2/mnt/disk123/main/marmosetTEMP/JP2/',brainid,'/']; % go to the temporary directory of JP2 on M24
    % NOTE: need to generate filenames.txt before running this from BNB
    %     filelist=jp2lsread; % get all the file names, including F and N
    %     Nfiles=length(secind);
    % output directory
    brainid=upper(brainid);
    outdir='/Users/bingxinghuo/Dropbox (Marmoset)/BingxingHuo/Marmoset Brain Architecture/Paul Martin/';
    cellmaskdir=[outdir,brainid,'/cellmasks8bit/'];
    if ~exist([outdir,brainid],'dir')
        mkdir([outdir,brainid])
    end
    if ~exist(cellmaskdir,'dir')
        mkdir(cellmaskdir)
    end
    
    % Get cell coordinates
    cellannodir=[outdir,brainid,'/',brainid,'_cells/cellanno/'];
    cellcoorddata=load([cellannodir,'cellfullcoord.mat']);
    cellcoordfull=cellcoorddata.cellcoordfull;
    % file list
    cd(cellannodir)
    filelist=filelsread('*.jp2.txt');
    Nfiles=length(filelist);
    cd(jp2dir)
    parfor f=1:Nfiles
        try
            %         [~,fileid]=jp2ind(filelist,['F',num2str(secind(f))]);
            fileid=filelist{f};
            fileid=fileid(9:end-4); % remove 'Marking-' and '.txt'
            cellsave=[cellmaskdir,fileid(1:end-4),'.tif'];
            if ~exist(cellsave,'file')
                cellind=cellcoordfull{f};
                cellmask=cellmaskgen(cellind,fileid,cellsave,1);
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
% delete(poolobj)