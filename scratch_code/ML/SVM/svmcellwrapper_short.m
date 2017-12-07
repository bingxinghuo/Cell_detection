function []=svmcellwrapper_short()
myCluster = parcluster('local'); % cores on compute node to be "local"
addpath(genpath('~/'))
brainids={'m919';'m920'};
poolobj=parpool(myCluster, 12);
    % read trained svm model
    load('~/scripts/denoiseSVM.mat','svmmodel')
for d=2
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
    parfor f=200
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
            failcatch(f)=1;
	    rethrow(ME)
        end
    end
end
delete(poolobj)
