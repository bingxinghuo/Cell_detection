function InObjectsMask=monochrome(rgbimg,ChannelIn,ROImap)
% global bandthresh
Channels=[1:3];
channelmask=Channels==ChannelIn;
ChannelOut=Channels((channelmask==0));
if nargin>2
    if length(size(ROImap))==3
        ChannelInImg=rgbimg(:,:,ChannelIn).*uint8(ROImap(:,:,1));
    else
        ChannelInImg=rgbimg(:,:,ChannelIn).*uint8(ROImap);
    end
    for i=1:2
        if length(size(ROImap))==3
            ChannelOutImg{i}=rgbimg(:,:,ChannelOut(i)).*uint8(ROImap(:,:,i));
        else
            ChannelOutImg{i}=rgbimg(:,:,ChannelOut(i)).*uint8(ROImap);
        end
    end
else
    ChannelInImg=rgbimg(:,:,ChannelIn);
    for i=1:2
        ChannelOutImg{i}=rgbimg(:,:,ChannelOut(i));
    end
end
for Nchannel=1:3
    [n,x]=imhist(nonzeros(rgbimg(:,:,Nchannel)));
    N=cumsum(n);
    xind=find(N/N(end)>.996==1);
    xind=xind(1);
    bandthresh(Nchannel)=x(xind);
end
% Now apply each color band's particular thresholds to the color band
MaskIn=(ChannelInImg>=bandthresh(ChannelIn))&(ChannelInImg<=255);
for i=1:2
    MaskOut{i}=(ChannelOutImg{i}>=0)&(ChannelOutImg{i}<=bandthresh(ChannelOut(i)));
end
% Combine the masks to find where all 3 are "true."
% Then we will have the mask of only the red parts of the image.
InObjectsMask=uint8(MaskIn & MaskOut{1} & MaskOut{2});
smallestAcceptableArea = 30; % Keep areas only if they're bigger than this.
% Get rid of small objects.  Note: bwareaopen returns a logical.
InObjectsMask = uint8(bwareaopen(InObjectsMask, smallestAcceptableArea));
% Smooth the border using a morphological closing operation, imclose().
structuringElement = strel('disk', 4);
InObjectsMask = imclose(InObjectsMask, structuringElement);
% Fill in any holes in the regions, since they are most likely red also.
InObjectsMask = uint8(imfill(InObjectsMask, 'holes'));
InObjectsMask = cast(InObjectsMask, class(ChannelInImg));
