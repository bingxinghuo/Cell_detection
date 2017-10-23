brainids={'m920';'m919'};
for d=1:2
    brainid=brainids{d};
    %     cd(['~/marmosetRIKEN/NZ/',brainid,'/',brainid,'F/JP2-REG/cellmasks/binaryimg'])
    cd(['~/marmosetRIKEN/NZ/',brainid,'/',brainid,'F/JP2-REG/cellmasks/8bitRGB/'])
    filelist=jp2lsread;
    Nf=length(filelist);
    parfor f=1:Nf
        filein=[pwd,'/tif64down/',filelist{f}(1:end-4),'.tif'];
        fileinfo=imfinfo(filein);
        if fileinfo.Width==751
            maskimg=imread(filein,'tif');
            maskimg=maskimg(:,1:750,:);
            imwrite(maskdown,filein,'tif','compression','none','writemode','overwrite')
        end
    end
end