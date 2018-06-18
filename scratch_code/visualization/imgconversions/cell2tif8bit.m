%% cell2tif8bit.m
% This script converts cell coordinates into masks in 8-bit gray image 
% prepared for running on BNB cluster
% Save downsampled tif files for all images
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
    % input directory
    % jp2dir=['/Users/bingxinghuo/CSHLservers/mitragpu3/marmosetRIKEN/NZ/',brainid,'/',brainid,'F/JP2/']; % go to the directory of JP2
    jp2dir=['~/marmosetRIKEN/NZ/',brainid,'/',brainid,'F/JP2/']; % go to the directory of JP2
    cd(jp2dir)
    filelist=jp2lsread;
    Nfiles=length(filelist);
    % output directory
    celldir=['~/',brainid,'/cellmasks8bit/'];
    if ~exist(['~/',brainid],'dir')
        mkdir(['~/',brainid])
    end
    if ~exist(celldir,'dir')
        mkdir(celldir)
    end
    % cell coordinates
    FBcoord=load([jp2dir,'FBdetectdata_consolid.mat']);
    FBclear=FBcoord.FBclear;
    % downsample rate
    M=64;
    parfor f=1:Nfiles
        fileid=filelist{f}; % input file
        cellsave=[celldir,fileid(1:end-4),'.tif']; % output file
        if ~exist(cellsave,'file')
            cellind=FBclear{f};
            cellind=[cellind.x,cellind.y];
            celldown=cellmaskgen(cellind,fileid,cellsave,M);
            imwrite(celldown,cellsave,'tif');
        end
    end
end