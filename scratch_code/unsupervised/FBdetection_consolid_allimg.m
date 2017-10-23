%% FBdetection_consolid_allimg.m
% Bingxing Huo
% This script detects the FB labeled cell bodies in all fluorescent images
% This script calls the following functions:
%     - brainmaskfun_16bit.m or brainmaskfun_8bit.m depending on the images bit depth
%     - FBdetection_consolid_v5_2014.m based on consolidating Keerthi &
%       Bingxing's code
%     - parsave.m to save the results while still within the parfor loop
%% 0. Preparation
global bitinfo
% 0.1 read in file list
fid=fopen('filenames.txt');
filelist=textscan(fid,'%q');
fclose(fid);
filelist=filelist{1};
Nfiles=length(filelist);
% 0.2 initialize
FBclear=cell(Nfiles,1);
% % FBclear=load('FBdetectdata_consolid.mat');
% % dataname=fieldnames(FBclear);
% % FBclear=getfield(FBclear,dataname{1});
% % Nrestart=zeros(size(FBclear,1),1);
% % for i=1:size(FBclear,1)
% %     Nrestart(i)=~isempty(FBclear{i});
% % end
% % Nrestart=sum(Nrestart)+1;
Nrestart=1;
% info on bits
fileinf=imfinfo(filelist{1});
bitinfo=fileinf.BitsPerSample;
if bitinfo==[8,8,8]
    bitinfo=8;
elseif bitinfo==[16, 16, 16]
    bitinfo=12;
end
%% 1. Go through every image
parfor f=Nrestart:Nfiles
    try
        % 1.1 load image
        fileid=filelist{f};
        fluoroimg=imread(fileid,'jp2');
        % 1.2 generate and save the mask
        maskname=['imgmasks/imgmaskdata_',num2str(f),'.mat']; % save the mask
        if exist([pwd,'/',maskname],'file')==2
            imgmask=load(maskname);
            maskvar=fieldnames(imgmask);
            imgmask=getfield(imgmask,maskvar{1});
        else
            if bitinfo==12
                imgmask=brainmaskfun_16bit(fluoroimg); % generate a mask for the brain region
            elseif bitinfo==8
                imgmask=brainmaskfun_8bit(fluoroimg);
            end
            parsave(maskname,imgmask)
        end
        % 1.3 detect cells
        centroids=FBdetection_consolid_v5_2014(fluoroimg,imgmask);
        if ~isempty(centroids)
            FBclear{f}.x=centroids(:,1);
            FBclear{f}.y=centroids(:,2);
        else
            FBclear{f}.x=[];
            FBclear{f}.y=[];
        end
%         save([pwd,'/FBdetectdata_consolid.mat'],'FBclear')
%         parsave([pwd,'/FBdetectdata_consolid.mat'],FBclear)
    catch ME
        f
        rethrow(ME)
    end
end
%% E. Save all detected cells into one variable
save('FBdetectdata_consolid','FBclear')