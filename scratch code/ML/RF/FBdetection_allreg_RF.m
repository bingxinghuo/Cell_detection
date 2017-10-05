%% FBdetection_allreg_RF.m
% Bingxing Huo
% This script detects the FB labeled cell bodies in all fluorescent images
%% 0. Preparation
% global bitinfo
% 0.1 read in file list
fid=fopen('filenames.txt');
filelist=textscan(fid,'%q');
fclose(fid);
filelist=filelist{1};
Nfiles=length(filelist);
% 0.2 initialize
% FBclear=cell(Nfiles,1);
% info on bits
fileinf=imfinfo(filelist{1});
bitinfo=fileinf.BitsPerSample;
rows=fileinf.Height;
cols=fileinf.Width;
% if bitinfo==[8,8,8]
%     bitinfo=8;
%     load('../traindata8bit','svmmodel')
% elseif bitinfo==[16, 16, 16]
bitinfo=12;
load('../traindata','svmmodel')
% end
failcatch=zeros(Nfiles,1);
%% 1. Go through every image
parfor f=1:Nfiles
    try
        cellmaskname=['cellmasks/cellmask_',num2str(f),'.mat'];
        if exist([pwd,'/',cellmaskname],'file')~=2
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
                imgmask=brainmaskfun_reg(fluoroimg);
                masktot=sum(sum(imgmask));
                if masktot<rows*cols*.8 % if the mask area fills morethan 80% of the whole image
                    parsave(maskname,imgmask)
                else
                    warnmsg=['Mask generation failed for Image ',num2str(f),'!'];
                    warning(warnmsg)
                    failcatch(f)=1;
                    continue
                end
            end
            
            % 1.3 crop image and detect cells
            [rgbimg,imgorigin,~]=maskadj_reg(fluoroimg,imgmask);
            imgorigin=round(imgorigin);
            [FBcellmask,centroids]=FBdetect_RFfun(rgbimg,svmmodel);
            % 1.4 project back to the original image size
            FBcellmask_origin=false(rows,cols);
            FBcellmask_origin(imgorigin(1):imgorigin(3),imgorigin(2):imgorigin(4))=FBcellmask;
            %             centroids_origin=centroids+ones(size(centroids,1),1)*[imgorigin(2),imgorigin(1)];
            
            parsave(cellmaskname,FBcellmask_origin)
            %             if ~isempty(centroids)
            %                 FBclear{f}=centroids_origin;
            %
            %             else
            %                 FBclear{f}=[];
            %
            %             end
            %         save([pwd,'/FBdetectdata_consolid.mat'],'FBclear')
            %         parsave([pwd,'/FBdetectdata_consolid.mat'],FBclear)
        end
    catch ME
        f
        disp(ME.message)
        failcatch(f)=2;
        continue
    end
end
%% E. Save all detected cells into one variable
% save('FBdetectdata_svm','FBclear')