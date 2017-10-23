brainids={'m920';'m919'};
for d=1:2
    brainid=brainids{d};
    %     cd(['~/marmosetRIKEN/NZ/',brainid,'/',brainid,'F/JP2-REG/cellmasks/binaryimg'])
    cd(['~/marmosetRIKEN/NZ/',brainid,'/',brainid,'F/JP2-REG/cellmasks/16bitRGBnew/'])
    filelist=jp2lsread;
    Nf=length(filelist);
    parfor f=1:Nf
        filein=filelist{f};
        %         fileout=[fileid(1:end-4),'16rgb.jp2'];
        fileout=['../8bitRGBnew/',filein];
        if exist(fileout,'file')~=2 % avoid re-processing detections
            bit16to8_bloc(filein,fileout)
        end
    end
end