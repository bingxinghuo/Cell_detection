%% This script is for when you have to use matlab interface
filelist=jp2lsread;
M=64;
regionlist={'DLG';'ExPC';'InPC';'InMC';'ExMC';'K1';'K2';'K3';'K4';...
    'IPul';'IPulCL';'IPulCM';'IPulM';'IPulP';'APul';'MPul';'LPul'};
R=length(regionlist);
% labelind=[10,2:9,20,11:17];
labelind=[1:17];
LGNind=[1,10,15:17];
DLGind=[2:9];
[fileind,fileid]=jp2ind(filelist,'281');
% for f=1:length(filelist)
%     nissljp2=filelist{f};
% clear nisslimg
%% 1. downsample Nissl JP2
nissltif=['STIF/',fileid(1:end-4),'.tif'];
if ~exist(nissltif,'file')
    % load
    nisslimg=imread(['~/CSHLservers/mitragpu3/marmosetRIKEN/NZ/m920/m920N/JP2/',fileid],'jp2');
    % downsample
    for i=1:3
        nisslsmall(:,:,i)=downsample_mean(nisslimg(:,:,i),M);
    end
    % save
    imwrite(nisslsmall,nissltif,'tif','compression','lzw')
else
    nisslsmall=imread(nissltif,'tif');
end
% combine to grayscale
nisslsmallgray=uint8(mean(nisslsmall,3));
% imgsize=imfinfo(fileid);
% imgwidth=imgsize.Width;
% imgheight=imgsize.Height;
%% 2. Use superpixel to manually select LGN and pulvinar regions
[L,~] = superpixels(nisslsmallgray,250,'method','SLIC','compactness',10);
BW=boundarymask(L);
h=imoverlay(nisslsmallgray,BW);
figure, imagesc(h)
isrois=input('Is there any ROI? (y/n) ','s');
if isrois=='y'
    [x,y]=getpts(gca);
    x=round(x);
    y=round(y);
    roiind=[];
    for i=1:length(x)
        roiind(i)=L(y(i),x(i));
    end
    [roiimg,roiimgind]=ismember(L,roiind);
    
else
    if ~exist('nisslimg','var')
        nisslimg=imread(['~/CSHLservers/mitragpu3/marmosetRIKEN/NZ/m920/m920N/JP2/',fileid],'jp2');
    end
    ROIinfo=brainROI(nisslimg);
    NROI=size(ROIinfo.ROIboundary,1); % number of regions selected
    ROIdown=cell(R,1);
    % downsample
    for r=1:NROI
        ROIdown{r}=downsample_mean(ROIinfo.ROIboundary{r,1},M);
    end
    %% identify regions
    figure, imagesc(nisslsmall)
    [tifheight,tifwidth,~]=size(ROIdown{1});
    regionmask=cell(R,1);
    LGNmask=[];
    DLGmask=[];
    cell2table(regionlist')
    for r=1:NROI
        hold on, contour(ROIdown{r})
        
        rind=input('Please identify the index of the region: ');
        regionmask{rind}=uint8(ROIdown{r})*labelind(rind);
    end
    %% 3. upsample the ROI mask to the original image
    %         roimask=repelem(roiimg,M,M);
    %         roimask=roimask(1:imgheight,1:imgwidth);
    %% 4. save the mask
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

close
% end