%% FBdetection_consolid_allimg.m
% Bingxing Huo
% This script detects the FB labeled cell bodies in all fluorescent images
%% 0. Preparation
global bitinfo
% 0.1 read in file list
filelist=jp2lsread;
Nfiles=length(filelist);
% 0.2 initialize
% FBclear=cell(Nfiles,1);
% % FBclear=load('FBdetectdata_consolid.mat');
% % dataname=fieldnames(FBclear);
% % FBclear=getfield(FBclear,dataname{1});
% % Nrestart=zeros(size(FBclear,1),1);
% % for i=1:size(FBclear,1)
% %     Nrestart(i)=~isempty(FBclear{i});
% % end
% % Nrestart=sum(Nrestart)+1;
Nstart=1;
% info on bits
fileinf=imfinfo(filelist{1});
bitinfo=fileinf.BitsPerSample;
rows=fileinf.Height;
cols=fileinf.Width;
if bitinfo==[8,8,8]
    bitinfo=8;
    load('~/mfiles/Bingxing/SVM/traindata8bit','svmmodel')
elseif bitinfo==[16, 16, 16]
    bitinfo=12;
    load('~/mfiles/Bingxing/SVM/traindata','svmmodel')
end
%% 1. Go through every image
parfor f=1:Nfiles
    % for f=21
    try
        % 1.1 load image
        fileid=filelist{f};
        fileout=[fileid(1:end-4),'_cells.jp2'];
        if exist([pwd,'/',fileout],'file')~=2 % avoid re-processing detections
            fluoroimg=imread(fileid,'jp2');
            % 1.2 generate and save the mask
            %         maskname=['imgmasks/imgmaskdata_',num2str(f),'.mat']; % save the mask
            %         if exist([pwd,'/',maskname],'file')==2
            %             imgmask=load(maskname);
            %             maskvar=fieldnames(imgmask);
            %             imgmask=getfield(imgmask,maskvar{1});
            %         else
            %             imgmask=brainmaskfun_reg(fluoroimg);
            %             parsave(maskname,imgmask)
            %         end
            %
            %         % 1.3 crop image and detect cells
            %         %         [rgbimg,imgorigin,~]=maskadj_reg(fluoroimg,imgmask);
            %         %         imgorigin=round(imgorigin);
            %         rgbimg=fluoroimg.*uint16(cat(3,imgmask,imgmask,imgmask));
            FBdetect_svmbloc(fluoroimg,2,svmmodel,fileid)
        end
        
    catch ME
        f
        rethrow(ME)
    end
end
%% E. Save all detected cells into one variable
% save('FBdetectdata_svm','FBclear')