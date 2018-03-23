% reorganize the masks
filelist=jp2lsread;
F=length(filelist);
% labelind=[10,2:9,20,11:17];
labelind=[1:17];
R=length(labelind);
regmask=cell(F,R);
for f=1:F
    fileid=filelist{f};
    regmaskfile{1}=['../LGNmask_64down/DLG/',fileid(1:end-4),'.tif'];
    if exist(regmaskfile{1},'file')
        regimg=imread(regmaskfile{1});
        regmask{f,1}=regimg;
    end
    regmaskfile{2}=['../LGNmask_64down/IPul/',fileid(1:end-4),'.tif'];
    if exist(regmaskfile{2},'file')
        regimg=imread(regmaskfile{2});
        regmask{f,10}=regimg;
    end
    regmaskfile{3}=['../LGNmask_64down/LGNdetails/',fileid(1:end-4),'.tif'];
    if exist(regmaskfile{3},'file')
        regimg=imread(regmaskfile{3});
        regind=unique(regimg);
        for i=2:length(regind)
            r=find(labelind==(regind(i)/15));
            regmask{f,r}=(regimg==regind(i));
        end
    end
end
%%
LGNmask=cell(F,1);
LGNind=[1,10,15:17];
for f=1:F
    for l=1:length(LGNind)
        LGNi=LGNind(l);
        if ~isempty(regmask{f,LGNi})
            if isempty(LGNmask{f})
                LGNmask{f}=regmask{f,LGNi}*labelind(LGNi);
            else
                LGNmask{f}=LGNmask{f}+regmask{f,LGNi}*labelind(LGNi);
            end
        end
    end
    % save
        fileid=filelist{f};
    subregfile=['../LGNmask_64down/LGN/',fileid(1:end-4),'.tif'];
    imwrite(uint8(LGNmask{f}*15),subregfile,'tif','WriteMode','overwrite')
end
%% DLG
DLGmask=cell(F,1);
DLGind=[2:9];
for f=1:F
    for l=1:length(DLGind)
        DLGi=DLGind(l);
        if ~isempty(regmask{f,DLGi})
            if isempty(DLGmask{f})
                DLGmask{f}=regmask{f,DLGi}*DLGi;
            else
                DLGmask{f}=DLGmask{f}+regmask{f,DLGi}*DLGi;
            end
        end
    end
    % save
    if ~isempty(DLGmask{f})
        fileid=filelist{f};
    subregfile=['../LGNmask_64down/DLG1/',fileid(1:end-4),'.tif'];
    imwrite(uint8(DLGmask{f}*15),subregfile,'tif')
    end
end
%% IPul
IPulmask=cell(F,1);
IPulind=[11:14];
for f=1:F
    for l=1:length(IPulind)
        IPuli=IPulind(l);
        if ~isempty(regmask{f,IPuli})
            if isempty(IPulmask{f})
                IPulmask{f}=regmask{f,IPuli}*IPuli;
            else
                IPulmask{f}=IPulmask{f}+regmask{f,IPuli}*IPuli;
            end
        end
    end
    % save
    if ~isempty(IPulmask{f})
        fileid=filelist{f};
    subregfile=['../LGNmask_64down/IPul1/',fileid(1:end-4),'.tif'];
    imwrite(uint8(IPulmask{f}*15),subregfile,'tif')
    end
end