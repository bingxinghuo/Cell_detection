%% This script works with downloaded annotation from the web portal
% Version 3. Updated 3/23/2018
filelist=jp2lsread;
regionlist={'DLG';'ExPC';'InPC';'InMC';'ExMC';'K1';'K2';'K3';'K4';...
    'IPul';'IPulCL';'IPulCM';'IPulM';'IPulP';'APul';'MPul';'LPul'};
STIFdir='STIF/';
M=64; % downsample rate
R=length(regionlist); % total number of regions
labelind=[1:R];
LGNind=[1,10,15:17]; % all LGN and pulvinar regions
DLGind=[2:9]; % subregions of DLG
IPulind=[11:14]; % subregions of IPul
F=length(filelist);
for f=1:F
    fileid=filelist{f};
        regionoutlinetxt=['Marking-',fileid,'.txt'];
    if exist(regionoutlinetxt,'file')
        % read out individual region's polygon in full resolution
        regiondata=readanno3(fileid); 
        % save subregion data in full resolution
        save([fileid(1:end-4),'_LGNpul.mat'],regiondata)
        % generate individual region's mask in downsampled resolution
        nisslstif=imread([STIFdir,fileid(1:end-4)],'tif');
        [tifheight,tifwidth,~]=size(nisslstif);
        regionlabel=uint8(zeros(tifheight,tifwidth));
        regionmask=cell(R,1);
        LGNmask=[];
        DLGmask=[];
        IPulmask=[];
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
        % DLG subregions
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
            subregfile=['../LGNmask_64down/IPul/',fileid(1:end-4),'.tif'];
            imwrite(uint8(DLGmask*15),subregfile,'tif')
        end
        % IPul subregions
        for l=1:length(IPulind)
            IPuli=IPulind(l);
            if ~isempty(regionmask{IPuli})
                if isempty(IPulmask)
                    IPulmask=regionmask{IPuli};
                else
                    IPulmask=IPulmask+regionmask{IPuli};
                end
            end
        end
        % save
        if ~isempty(IPulmask)
            subregfile=['../LGNmask_64down/DLG/',fileid(1:end-4),'.tif'];
            imwrite(uint8(IPulmask*15),subregfile,'tif')
        end
    end
    
end
