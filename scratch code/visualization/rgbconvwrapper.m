brainids={'m920';'m919'};
for d=1:2
    brainid=brainids{d};
    cd(['~/marmosetRIKEN/NZ/',brainid,'/',brainid,'F/JP2-REG/cellmasks'])
    filelist=jp2lsread;
    Nf=length(filelist);
    parfor f=1:Nf
        fileid=filelist{f};
        %         fileout=[fileid(1:end-4),'16rgb.jp2'];
        fileout=[fileid(1:end-4),'8rgb.jp2'];
        if exist([pwd,'/',fileout],'file')~=2 % avoid re-processing detections
            rgbconvbloc(fileid)
        end
    end
end