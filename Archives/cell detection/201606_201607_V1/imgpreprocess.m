% %% 1. pre-define slides that contains labeled neurons for each channel
% % use these code to find the index of the slides:
% % A=strfind(filelist,'F94');
% % Aind=find(~cellfun(@isempty,A));
% % slide{1}=81:144; %F41-
% % slide{2}=180:290;
% % slide{3}=[150:158,228:300];
% %% 2. pre-define ROI for each channel
% % ROI{1,1}=1001:15000; % x coordinates for red channel
% % ROI{1,1}=1001:14000; % x coordinates for red channel
% % ROI{1,2}=2001:22000; % y coordintates for red channel
% % ROI{2,1}=3000:10000; % x coordinates for green channel
% % ROI{2,2}=3000:8000; % y coordintates for green channel
% % % ROI{3,1}=1101:14763; % x coordinates for blue channel
% % ROI{3,1}=1101:14700; % x coordinates for blue channel
% % ROI{3,2}=2001:14288; % y coordintates for blue channel
% %% 3 read in files
% % cd('/Users/bingxinghuo/marmosetRIKEN/marmosetRIKEN/NZ/m820/m820F/JP2')
% fid=fopen('sorted-M820F.txt');
% filelist=textscan(fid,'%q');
% fclose(fid);
% filelist=filelist{1};
% %%
% rawcrop=cell(300,3);
for f=1:300
    % 1. read in slide of interest
    imgfile=filelist{f};
    fluoroimg=imread(imgfile,'jp2');
    %                     channelimg=fluoroimg(:,:,Nchannel);
    %% 1. split channels
    channelimg=cell(1,3);
    for Nchannel=1:3
        channelimg{Nchannel}=fluoroimg(:,:,Nchannel);
%         % apply a hard threshold to remove the background noise first
%         channelimg{Nchannel}=uint8(channelimg{Nchannel}.*channelimg{Nchannel}>20);
    end
%% 2. for each channel, detect if there is signal based on histogram threshold
% generate histogram for each color channel
%     for Nchannel=1:3
%         [colorcount{Nchannel},colorvalue{Nchannel}]=imhist(channelimg{Nchannel});
%         countmax(Nchannel)=max(colorcount{Nchannel});
%     end
%     figure
n=1;
m=1;
ChannelIn=[];
ChannelOut=[];
bandthresh=zeros(1,3);
for Nchannel=1:3
    %         subplot(1,3,Nchannel), bar(colorvalue{Nchannel},colorcount{Nchannel})
    %         ylim([0 max(countmax)]) % use the same y-axis limits for comparison
    bandthresh(Nchannel)=graythresh(channelimg{Nchannel}(channelimg{Nchannel}>20))*255; % Otsu's threshold to separate
    threshcheck=bandthresh>100;
    if sum(threshcheck)==0
        if bandthresh(Nchannel)>100 % separating the tracer label and the brain
            ChannelIn(n)=Nchannel;
            n=n+1;
        else                % separating the brain and the background
            ChannelOut(m)=Nchannel;
            bandthresh(Nchannel)=255*graythresh(channelimg{Nchannel}(channelimg{Nchannel}>bandthresh(Nchannel)));
            m=m+1;
        end
    end
    if ~isempty(ChannelIn)
        
        %%
        Channels=[1:3];
        for n=1:length(ChannelIn)
            channelmask=Channels==ChannelIn;
            ChannelComp=Channels((channelmask==0));
            % Now apply each color band's particular thresholds to the color band
            MaskIn=(channelimg{ChannelIn}>=bandthresh(ChannelIn))&(channelimg{ChannelIn}<=255);
            MaskOut=cell(1,2);
            for i=1:2
                MaskOut{i}=(channelimg{ChannelComp(i)}>=0)&(channelimg{ChannelComp(i)}<=bandthresh(ChannelComp(i)));
            end
            % Combine the masks to find where all 3 are "true."
            % Then we will have the mask of only the red parts of the image.
            InObjectsMask=uint8(MaskIn & MaskOut{1} & MaskOut{2});
            
            %%
            smallestAcceptableArea = 30; % Keep areas only if they're bigger than this.
            % Get rid of small objects.  Note: bwareaopen returns a logical.
            InObjectsMask = uint8(bwareaopen(InObjectsMask, smallestAcceptableArea));
            % Smooth the border using a morphological closing operation, imclose().
            structuringElement = strel('disk', 4);
            InObjectsMask = imclose(InObjectsMask, structuringElement);
            % Fill in any holes in the regions, since they are most likely red also.
            InObjectsMask = uint8(imfill(InObjectsMask, 'holes'));
            InObjectsMask = cast(InObjectsMask, class(channelimg{ChannelIn}));
            %% Use the  object mask to mask out the monochrome portions of the rgb image.
            ChannelInObject=InObjectsMask.*channelimg{ChannelIn};
            % monoimg=channelimg{ChannelIn}-max(channelimg{Channelother(1)},channelimg{Channelother(2)});
            % monoimg=monoimg-graythresh(monoimg);
            % monoimg=im2bw(monoimg);
            %% adjust ROI accordingly
            [xind,yind]=find(InObjectsMask);
            ChannelInObject=ChannelInObject(min(xind):max(xind),min(yind):max(yind));
            %         ROIinfo{Nchannel,i}=zeros(size(fluoroimg,1),size(fluoroimg,2));
            %         ROIinfo{Nchannel,i}(ROI{Nchannel,1},ROI{Nchannel,2})=1;
            %         InObjectsMask{Nchannel,i}=monochrome(fluoroimg,Nchannel,ROIinfo{Nchannel,i});
            %% denoise
            % ChannelInObject=255./(1+exp(-(double(ChannelInObject)-240)/30));
            ChannelInFilt = imfilter(ChannelInObject,fspecial('gaussian',2*ceil(2*10)+1, 10));
            % ChannelInFilt=imgaussfilt(ChannelInObject,10);
            ChannelInObject = ChannelInObject - ChannelInFilt; % remove the blurred image to get sharp image
            h=imagesc(ChannelInObject);
            rawcrop{f,n}=ChannelInObject;
            saveas(h,['rawcrop',num2str(f),'_',num2str(ChannelIn)],'tif')
        end
    else
        ChannelInObject=zeros(size(fluoroimg,1),size(fluoroimg,2));
        rawcrop{f,1}=ChannelInObject;
    end
end

% end

