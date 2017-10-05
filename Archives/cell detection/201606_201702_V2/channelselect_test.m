% global bandthresh
% bandthresh=[40,40,40];
InObjectsMask=cell(3,1);
maskedRGBImage=cell(293,1);
maskedRGBImage_correct=cell(293,1);
slide{1}=72:144;
slide{2}=180:286;
slide{3}=[146:156,217:293];
Channels=[1:3];
for f=1:293
    rgbimg=stack2dimg{f}(:,:,1:3);
    for ChannelIn=1:3
        InObjectsMask{ChannelIn}=monochrome(rgbimg,ChannelIn,ROIinfo.ROImap);
    end
    %% Use the  object mask to mask out the monochrome portions of the rgb image.
    maskedImage=cell(1,3);
    for Nchannel=1:3
        maskedImage{Nchannel} = InObjectsMask{Nchannel} .* rgbimg(:,:,Nchannel);
    end
    % Concatenate the masked color bands to form the rgb image.
    maskedRGBImage{f} = cat(3, maskedImage{1}, maskedImage{2}, maskedImage{3});
    %%
    maskedRGBImage_correct{f}=maskedRGBImage{f};
    for ChannelIn=1:3
        channelmask=Channels==ChannelIn;
        ChannelOut=Channels((channelmask==0));
        if sum(slide{ChannelIn}==f)>0
            for i=1:2
                if sum(slide{ChannelOut(i)}==f)==0
                    maskedRGBImage_correct{f}(:,:,ChannelOut(i))=zeros(size(maskedRGBImage{1},1),size(maskedRGBImage{1},2));
                end
            end
        end
    end
    if sum(slide{1}==f)+sum(slide{2}==f)+sum(slide{3}==f)==0
        maskedRGBImage_correct{f}=zeros(size(maskedRGBImage{f}));
    end
    %% save images
%         h=imagesc(maskedRGBImage_correct{f});
%     saveas(h,['stack_mono_',num2str(f)],'tif')
end
%%
