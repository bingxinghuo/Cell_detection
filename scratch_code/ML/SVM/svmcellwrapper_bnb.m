%% svmcellwrapper_bnb.m
% Bingxing Huo @ 2017
% This code processes all the registered brains for cell detection using
% BNB.
% This code calls svmcellmain.m
% This code feeds into celldetectqsub.sh
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function []=svmcellwrapper_bnb()
% set up the cluster
myCluster = parcluster('local'); % cores on compute node to be "local"
addpath(genpath('~/'))
poolobj=parpool(myCluster, 12);
% all brains
brainids={'m919';'m920'};
% read trained svm model
load('~/scripts/denoiseSVM.mat','svmmodel')
% pass on to all workers
addAttachedFiles(poolobj,
for d=1:2
    % go the the directory
    brainid=brainids{d};
    fluorodir=['~/marmosetRIKEN/NZ/',brainid,'/',brainid,'F/'];
    savedir=['~/marmosetdata/',brainid,'/'];
    if ~exist(savedir,'dir')
        mkdir(savedir)
    end
    cd([fluorodir,'JP2-REG/'])
    % read file list
    filelist=jp2lsread;
    Nf=length(filelist);
    failmsg=cell(Nf,1); % allocate a vector to catch failures
    parfor f=1:Nf
        try
            %  image info
            filein=filelist{f};
            fileout=[savedir,filein(1:end-4),'_cells.jp2'];
            if ~exist(fileout,'file') % avoid re-processing detections
                %  mask info
                maskname=[fluorodir,'JP2-REG/imgmasks/imgmaskdata_',num2str(f),'.mat']; % save the mask
                % run cell detection
                cellmask=svmcellmain(filein,svmmodel,maskname);
                % Save in 8-bit RGB (black/white)
                cellmaskrgb=uint8(cellmask*255);
                cellmaskrgb=cat(3,cellmaskrgb,cellmaskrgb,cellmaskrgb);
                imwrite(cellmaskrgb,fileout)
            end
        catch ME
            f
            failmsg{f}=ME;
        end
    end
    save([savedir,'failmsgs.mat'],'failmsg')
end
delete(poolobj)
