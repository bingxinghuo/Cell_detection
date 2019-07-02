%% FBdetection_consolid_allimg1_bnb.m
% Bingxing Huo
% This script detects the FB labeled cell bodies in all fluorescent images
% This script calls the following functions:
%     - brainmaskfun_16bit.m or brainmaskfun_8bit.m depending on the images bit depth
%     - FBdetection_consolid.m based on consolidating Keerthi &
%       Bingxing's code
%     - parsave.m to save the results while still within the parfor loop
function FBdetection_consolid_allimg1_bnb()
%%
myCluster = parcluster('local'); % cores on compute node to be "local"
addpath(genpath('~/'))
brainids={'m852'};
D=length(brainids);
poolobj=parpool(myCluster, 12);
global bitinfo
for d=1:D
    brainid=brainids{d};
    %% 0. Preparation
%     jp2dir=['~/marmosetRIKEN/NZ/',brainid,'/',brainid,'F/JP2/']; % go to the directory of JP2
    jp2dir=['~/marmosetRIKEN/NZ/',brainid,'/',brainid,'F/JP2-REG/']; % go to the directory of JP2
    cd(jp2dir)
    % 0.1 read in file list
    filelist=jp2lsread;
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
    % fileinf=imfinfo(filelist{1});
    % bitinfo=fileinf.BitsPerSample;
    % if bitinfo==[8,8,8]
    %     bitinfo=8;
    % elseif bitinfo==[16, 16, 16]
    bitinfo=12;
    % end
    %% 1. Go through every image
    parfor f=Nrestart:Nfiles
        try
            % 1.1 load image
            fileid=filelist{f};
            fluoroimg=imread(fileid,'jp2');
            % 1.2 generate and save the mask
            maskfile=['~/',brainid,'/imgmasks/imgmaskdata_',num2str(f)]; % save the mask
            if exist([maskfile,'.tif'],'file')
                imgmask=imread(maskfile,'tif');
            elseif exist([maskfile,'.mat'],'file')
                imgmask=load(maskfile);
                maskvar=fieldnames(imgmask);
                imgmask=getfield(imgmask,maskvar{1});
            else
                %             if bitinfo==12
                %                 imgmask=brainmaskfun_16bit(fluoroimg); % generate a mask for the brain region
                %             elseif bitinfo==8
                %                 imgmask=brainmaskfun_8bit(fluoroimg);
                %             end
                %             parsave(maskname,imgmask)
                imgmask=brainmaskfun_16bittif(fileid,['~/',brainid,'/',upper(brainid),'F-STIF/'],'./'); % generate a mask for the brain region
            end
            % 1.3 detect cells
            centroids=FBdetection_consolid_v5(fluoroimg,imgmask);
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
            imwrite(zeros(64),['~/',brainid,'/',fileid(1:end-4)],'tif')
            rethrow(ME)
        end
    end
    %% E. Save all detected cells into one variable
    save(['~/',brainid,'/FBdetectdata_consolid'],'FBclear')
end