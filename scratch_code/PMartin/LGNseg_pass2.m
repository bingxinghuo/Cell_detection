%% This script works with downloaded annotation from the web portal
filelist=jp2lsread;
regionlist={'DLG';'ExPC';'InPC';'InMC';'ExMC';'K1';'K2';'K3';'K4';...
    'IPul';'IPulCL';'IPulCM';'IPulM';'IPulP';'APul';'MPul';'LPul'};
M=64;
R=length(regionlist);
labelind=[1:17];
LGNind=[1,10,15:17];
DLGind=[2:9];
F=length(filelist);
for f=162:F
    fileid=filelist{f};
    %     regionoutlinetxt=['Marking-',fileid,'.txt']; % 919
    regionoutlinetxt=['M920-Nissl_',fileid(end-7:end-4),'_LGN.jp2.txt']; % 920
    if exist(regionoutlinetxt,'file')
        nisslstif=imread(['STIF/',fileid(1:end-4)],'tif');
        [tifheight,tifwidth,~]=size(nisslstif);
        %         regiondata=readanno(regionoutlinetxt);
        regiondata=readanno2(fileid,regionoutlinetxt,'STIF',M);
        regionlabel=uint8(zeros(tifheight,tifwidth));
        %         regiondatadown=cell(R,1);
        regionmask=cell(R,1);
        LGNmask=[];
        DLGmask=[];
        for r=1:R
            if ~isempty(regiondata{r})
                regiondatadown=round(regiondata{r}/M);
                regionmask{r}=poly2mask(regiondatadown(:,1),regiondatadown(:,2),tifheight,tifwidth);
                regionmask{r}=regionmask{r}*labelind(r);
            end
        end
        % all LGN
        for l=1:length(LGNind)
            LGNi=LGNind(l);
            if ~isempty(regionmask{LGNi})
                if isempty(LGNmask)
                    LGNmask=regionmask{LGNi};
                else
                    LGNmask=LGNmask+regionmask{LGNi};
                end
            end
        end
        % save
        if ~isempty(LGNmask)
            subregfile=['../LGNmask_64down/LGN/',fileid(1:end-4),'.tif'];
            imwrite(uint8(LGNmask*15),subregfile,'tif','WriteMode','overwrite')
        end
        % DLG details
        for l=1:length(DLGind)
            DLGi=DLGind(l);
            if ~isempty(regionmask{DLGi})
                if isempty(DLGmask)
                    DLGmask=regionmask{DLGi};
                else
                    DLGmask=DLGmask+regionmask{DLGi};
                end
            end
        end
        % save
        if ~isempty(DLGmask)
            subregfile=['../LGNmask_64down/DLG/',fileid(1:end-4),'.tif'];
            imwrite(uint8(DLGmask*15),subregfile,'tif')
        end
    end
    
end
