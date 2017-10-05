%% 1. read files
% fid=fopen('tiflist.txt');

filelist=textscan(fid,'%q');
fclose(fid);
filelist=filelist{1};
% initialization
stack3dimg=zeros(505,512,3,293); % initialize the matrix
stack2dimg=cell(293,1);
stack2dnorm=cell(293,1);
% store images in a cell array
for f=1:293
    fileid=filelist{f};
    stack2dimg{f}=imread(fileid,'tif');
    %     stack2dimg{f}=double(stack2dimg{f});
end
% crop ROI and store in a 3D stack
load ROIinfo820
for f=1:293
    stack3dimg(:,:,:,f)=double(stack2dimg{f}(:,:,1:3)).*ROIinfo.ROImap;
end
%% 2. create a brain mask - as the mean of all brains
for Nchannel=1:3
    meanmask.z(:,:,Nchannel)=mean(stack3dimg(:,:,Nchannel,:),4);
    meanmask.y(:,:,Nchannel)=mean(stack3dimg(:,:,Nchannel,:),2);
    meanmask.x(:,:,Nchannel)=mean(stack3dimg(:,:,Nchannel,:),1);
end
%% 3. single out the tracers
channelselect
% save('monochromemask','maskedRGBImage');
% maskedRGBImage_correct=maskedRGBImage;
%% correct for each channel

% slide{1}=72:144;
% slide{2}=180:286;
% slide{3}=[146:156,217:293];
% Channels=[1:3];
% for f=1:293
%     for ChannelIn=1:3
%         channelmask=Channels==ChannelIn;
%         ChannelOut=Channels((channelmask==0));
%         if sum(slide{ChannelIn}==f)>0
%             for i=1:2
%                 if sum(slide{ChannelOut(i)}==f)==0
%                     maskedRGBImage_correct{f}(:,:,ChannelOut(i))=zeros(size(maskedRGBImage{1},1),size(maskedRGBImage{1},2));
%                 end
%             end
%         end
%     end
%     if sum(slide{1}==f)+sum(slide{2}==f)+sum(slide{3}==f)==0
%         maskedRGBImage_correct{f}=zeros(size(maskedRGBImage{f}));
%     end
% end
%% Maximum intensity across each cardinal plane
    for f=1:293
        stack3dmono(:,:,:,f)=maskedRGBImage_correct{f};
    end
    
    
    % z-axis
    channelimg=zeros(505,512,3);
    channelind=zeros(505,512,3);
    for Nchannel=1:3
        [channelimg(:,:,Nchannel),channelind(:,:,Nchannel)]=max(stack3dmono(:,:,Nchannel,:),[],4);
        %     [channelimg(:,:,Nchannel)]=mean(stack3dimg(:,:,Nchannel,:),4);
    end
    maxint.zmax=channelimg;
    maxint.zind=channelind;
    %
    % x-axis
    channelimg=zeros(512,293,3);
    channelind=zeros(512,293,3);
    for Nchannel=1:3
        [channelimg(:,:,Nchannel),channelind(:,:,Nchannel)]=max(stack3dmono(:,:,Nchannel,:),[],1);
        %     [channelimg(:,:,Nchannel)]=mean(stack3dimg(:,:,Nchannel,:),1);
    end
    maxint.xmax=channelimg;
    maxint.xind=channelind;
    %y-axis
    channelimg=zeros(505,293,3);
    channelind=zeros(505,293,3);
    for Nchannel=1:3
        [channelimg(:,:,Nchannel),channelind(:,:,Nchannel)]=max(stack3dmono(:,:,Nchannel,:),[],2);
        %     [channelimg(:,:,Nchannel)]=mean(stack3dimg(:,:,Nchannel,:),2);
        
    end
    maxint.ymax=channelimg;
    % maxint.yind=channelind;
    %%
    save('maxintensity_v1','maxint','-v7.3')

    %%
    figure
for f=1:293
    clf
%     imagesc(maskedRGBImage{f},[0 255])
    imagesc(maskedRGBImage_correct{f},[0 255])
    title(num2str(f),'fontsize',20)
    axis image
    drawnow
    pause
end
%%
composeimg=cell(293,1);
for f=1:293
    composeimg{f}=double(maskedRGBImage_correct{f}*10)+squeeze(double(stack3dimg(:,:,1:3,f)));
        h=imagesc(composeimg{f});
    saveas(h,['stack_compose_',num2str(f)],'tif')
end