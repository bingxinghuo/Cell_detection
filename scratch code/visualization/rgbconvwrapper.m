brainids={'m920';'m919'};
for d=1:2
    brainid=brainids{d};
    cd(['~/marmosetRIKEN/NZ/',brainid,'/',brainid,'F/JP2-REG/cellmasks/binaryimg'])
    filelist=jp2lsread;
    Nf=length(filelist);
    parfor f=1:Nf
        filein=filelist{f};
        %         fileout=[fileid(1:end-4),'16rgb.jp2'];
        fileout=['../8bitRGB/',filein(1:end-4),'_8rgb.jp2'];
        if exist(fileout,'file')~=2 % avoid re-processing detections
            rgbconvbloc(filein,fileout)
        end
    end
end