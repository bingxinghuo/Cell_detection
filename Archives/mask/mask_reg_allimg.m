%% 0. Preparation
global bitinfo
% 0.1 read in file list
fid=fopen('filenames.txt');
filelist=textscan(fid,'%q');
fclose(fid);
filelist=filelist{1};
Nfiles=length(filelist);
Nstart=1;
% bitinfo=8;
bitinfo=12;
parfor f=Nstart:Nfiles
    try
        % 1.1 load image
        fileid=filelist{f};
        fluoroimg=imread(fileid,'jp2');
        % 1.2 generate and save the mask
        maskname=['imgmasks/imgmaskdata_',num2str(f),'.mat']; % save the mask
        if exist([pwd,'/',maskname],'file')~=2
            imgmask=brainmaskfun_reg(fluoroimg);
            parsave(maskname,imgmask)
        end
    catch ME
        f
        rethrow(ME)
    end
end
