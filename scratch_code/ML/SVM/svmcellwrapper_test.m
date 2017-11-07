%% svmcellwrapper.m
% this is a wrapper function for cell detection across the whole brain
load('~/scripts/denoiseSVM.mat','svmmodel')
sigma=[20,1];
brainN={'m919';'m920'};
% for i=1:length(brainN)
for i=2
    brainid=brainN{i};
    fluorodir=['~/marmosetRIKEN/NZ/',brainid,'/',brainid,'F/'];
    savedir=['~/marmosetdata/',brainid,'/'];
    if ~exist(savedir,'dir')
        mkdir(savedir)
    end
    cd([fluorodir,'JP2-REG/'])
    filelist=jp2lsread;
    Nf=length(filelist);
    %     parfor f=1:Nf
    for f=218
        try
            % load image
            fileid=filelist{f};
            fileout=[savedir,fileid(1:end-4),'_cells.jp2'];
            if exist([pwd,'/',fileout],'file')~=2 % avoid re-processing detections
                fluoroimg=imread(fileid,'jp2');
                % 1. mask
                % 1.1 load mask
                maskname=[fluorodir,'JP2-REG/imgmasks/imgmaskdata_',num2str(f),'.mat']; % save the mask
                if exist([pwd,'/',maskname],'file')==2
                    imgmask=load(maskname);
                    maskvar=fieldnames(imgmask);
                    imgmask=getfield(imgmask,maskvar{1});
                end
                % further erode the mask
                se=strel('disk',10);
                imgmask=imerode(imgmask,se);
                % 1.2 crop image and apply the mask
                [rgbimg,imgorigin,~]=maskadj_reg(fluoroimg,imgmask);
                imgorigin=round(imgorigin);
                % 2. preprocess
                % 2.1 apply denoise filter
                rgbdenoise=rmbg(rgbimg,sigma);
                % 3. use SVM to predict cells
                cellmask=svmcellblock(rgbdenoise,5,svmmodel);
                % 4. post-process
                % TBD
                % 5. project back to the original image size
        [rows,cols,~]=size(fluoroimg);
        cellmask_origin=false(rows,cols);
        cellmask_origin(imgorigin(1):imgorigin(3),imgorigin(2):imgorigin(4))=cellmask;
            end
        catch ME
            f
            rethrow(ME)
        end
    end
end