%% pixelhist_figs_v7_BNB.m
% This is for use on the BNB server
% This script reads the jp2 images within the directory and generate
% histograms for individual channels. The histogram information for all the
% images is stored in a common file called ****_histinfo.mat.
function []=pixelhist_figs_v7_BNB()
global bitinfo
myCluster = parcluster('local'); % cores on compute node to be "local"
addpath(genpath('~/'))
cd /nfs/mitraweb2/mnt/disk125/main/marmosetRIKEN/NZ/
dir0=pwd;
dirlist=dir('m*'); % generate a list of all brains to be processed
poolobj=parpool(myCluster, 12);
for d=14:length(dirlist)
    % generate a directory to save results
    mkdir('~/',dirlist(d).name)
    cd([dirlist(d).name,'/',dirlist(d).name,'F/JP2']) % go to the directory of JP2
%     % IMPORTANT! USE THE CUSTOM GENERATED FILELIST
%     if ~exist([pwd,'/','filenames.txt'])
%         system('ls -h M*.jp2 | sort -t"_" -k3 > filenames.txt');
%     end
% Read out the file list
    fid=fopen('filenames.txt'); 
    filelist=textscan(fid,'%q');
    fclose(fid);
    filelist=filelist{1};
    Nfiles=length(filelist);
    %% Generate the masks for brain section
    if ~exist([pwd,'/imgmasks/']) 
        mkdir(['~/',dirlist(d).name],'imgmasks') % generate a directory to save masks
    end
    histname=[pwd,'/',dirlist(d).name,'_histinfo.mat'];
    failsave=['~/',dirlist(d).name,'_failmask.mat'];
    if ~exist(histname)
        histsave=['~/',dirlist(d).name,'/',dirlist(d).name,'_histinfo.mat']; % save in the home directory
        fileinfo=imfinfo(filelist{1});
        if fileinfo.BitDepth==24 % 8-bit
            system('mv filenames.txt filenames_8bit.txt'); % mark and skip
        elseif fileinfo.BitDepth==48 % 16-bit
            bitinfo=12;
            failcatch=zeros(Nfiles,1); % allocate a vector to catch failures
            histN=cell(Nfiles,1);
            histX=cell(Nfiles,1);
            
            parfor f=1:Nfiles
                try
                    % load image
                    fileid=filelist{f};
                    fluoroimg=imread(fileid,'jp2');
                    maskload=[pwd,'/imgmasks/imgmaskdata_',num2str(f),'.mat'];
                    masksave=['~/',dirlist(d).name,'/imgmasks/imgmaskdata_',num2str(f),'.mat'];
                    % load/generate brain section mask (note: there are errors in some images)
                    if exist([maskload],'file')==2 % mask file already exists
                        imgmask=load(maskload); % get the mask
                        maskvar=fieldnames(imgmask); 
                        imgmask=getfield(imgmask,maskvar{1});
                    else % no mask file yet
                        imgmask=brainmaskfun_reg(fluoroimg)
                        parsave(masksave,imgmask)
                    end
                    [histN{f},histX{f}]=pixelhistview(fluoroimg,imgmask);

                catch ME
                    f
                    failcatch(f)=1;
                    rethrow(ME)
                end
            end
            save(histsave,'histN','histX')
            save(failsave,'failcatch')
        end
    end
    cd(dir0) % go back to the original directory
end
delete(poolobj)