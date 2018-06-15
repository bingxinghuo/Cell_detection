%%  fluorimgadj_bnb.m
% Bingxing Huo, May 2018
%
% This script performs batch background correction on BNB
function []=fluorimgadj_bnb()
%% Set up environment
myCluster = parcluster('local'); % cores on compute node to be "local"
addpath(genpath('~/'))
poolobj=parpool(myCluster, 12);
%% parameters
animalid='m919';
datadir='/nfs/mitraweb2/mnt/disk125/main/marmosetRIKEN/NZ/';
sec0='0234';
sec1='0378';
savedir='~/m919/m919Fadj/';
%% set up directory
if ~exist(savedir,'dir')
    mkdir(savedir)
end
animalid=lower(animalid); % in case the input is upper case
fludir=[datadir,animalid,'/',animalid,'F/JP2/'];
cd(fludir)
%% identify files
filelist=jp2lsread;
[f0,~]=jp2ind(filelist,sec0);
[f1,~]=jp2ind(filelist,sec1);
%% Run image background adjustment
% load standard median for 3 channels
bgmed0=load('background_standard'); % this loads variable bgimgmed0
bgimgmed0=bgmed0.bgimgmed0;
%
parfor f=f0:f1
    fluoroimg1=fluorimgadj(animalid,datadir,f,bgimgmed0)
    % save
    imwrite(fluoroimg1,[savedir,filelist{f}])
end
delete(poolobj)
