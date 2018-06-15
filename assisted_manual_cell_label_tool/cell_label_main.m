function [cellobj,cellboundbox,cellcentroids]=cell_label_main(jp2dir,tifdir,secstartid,secendid)
% Main function to label cells manually on local machine
% This process is designed for labeling cells in only a subregion of the
% entire image.
% developed based on FBdetection_threshold_iter.m
% utilizes threshold method to assist with the manual cell labelng process
% sample syntax: [cellobj,cellboundbox,cellcentroids]=cell_label_main(jp2dir,tifdir,'F96','F115');
%% inputs
% brainid='m820';
% secstartid='F96';
% secendid='F115';
%
% jp2dir=['~/marmosetRIKEN/NZ/',brainid,'/',brainid,'F/JP2/']; % go to the directory of JP2
% jp2dir=['/Users/bingxinghuo/CSHLservers/mitragpu3/marmosetRIKEN/NZ/',brainid,'/',brainid,'F/JP2/']; % go to the directory of JP2
% jp2dir=['/Users/bingxinghuo/CSHLservers/CSHLcompute/M25/marmosetRIKEN/NZ/',brainid,'/',brainid,'F/JP2-16/'];
% jp2temp='/Users/bingxinghuo/CSHLservers/CSHLcompute/M24/marmosetTEMP/JP2/m820/m820F/JP2/';
% cd(jp2temp)
cd(jp2dir)
filelist=jp2lsread;
[f0,~]=jp2ind(filelist,secstartid);
[f1,~]=jp2ind(filelist,secendid);
%% parameters
M=64;
Ithresh=30;
%%
% tifdir=['/Users/bingxinghuo/CSHLservers/CSHLcompute/M24/TempForTrasfer/',upper(brainid),'F-STIF/'];
% tifdir=['/Users/bingxinghuo/CSHLservers/mitragpu3/marmosetRIKEN/NZ/',brainid,'/',brainid,'F/',upper(brainid),'F-STIF/'];
cd(tifdir)
tiflist=filelsread('M*.tif');
% load standard median for 3 channels
bgmed=load('background_standard'); % this loads variable bgimgmed0
%%
cellcentroids=cell(f1-f0+1,1);
cellboundbox=cell(f1-f0+1,1);
cellobj=cell(f1-f0+1,1);
bgmed.bgimgmed=cell(f1-f0+1,1);
%%
for f=f0:f1
    fluoroimg=imread([jp2dir,filelist{f}]);
    % 3.2 select a region using STIF file
    fid(1)=strfind(filelist{f},'F');
    fid(2)=strfind(filelist{f},'--')-1;
    [~,tiffile]=jp2ind(tiflist,filelist{f}(fid(1):fid(2)));
    %     tiffile=[filelist{f}(1:end-4),'.tif'];
    fluimg=imread([tifdir,tiffile]);
    %% Select ROI
    [subimg,ROIpos]=ROIselect(fluoroimg,fluimg,M);
    %% Calculate background intensity
    tifmask=imgmaskgen(fluimg,1);
    bgmed.bgimgmed{f-f0+1}=bgmean3_tif(fluimg,tifmask);
    %% Make background adjustment on raw image
    subimg=baselineadj(subimg,bgmed.bgimgmed{f-f0+1},bgmed.bgimgmed0);
    %% identify cells within ROI
    tic;
    [proposedimgs,cellid,boundbox]=traingen_objprop(subimg,Ithresh);
    toc
    %% cut connected cells
    tic;
    [singlecells,bbpos,singlecellmasks]=cellcut_manual(proposedimgs,cellid,boundbox,Ithresh);
    toc
    %% Project cell positions back to the full size image
    if ~isempty(singlecells{1})
        cellcent=cell(length(singlecells),1);
        cellbb=cell(length(singlecells),1);
        for i=1:length(singlecells)
            
            cellcent{i}=regionprops(singlecellmasks{i},'centroid');
            cellcent{i}=round(cellcent{i}.Centroid+bbpos{i}(1:2)+ROIpos(1:2));
            cellbb{i}=[bbpos{i}(1:2)+ROIpos(1:2),bbpos{i}(3:4)];
        end
        %%
        cellcentroids{f-f0+1}=cell2mat(cellcent);
        cellboundbox{f-f0+1}=cell2mat(cellbb);
        cellobj{f-f0+1}=singlecells;
    end
end