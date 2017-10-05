function L=cellSNR(L,bitimg,bitinfo)
idx=1:max(max(L));
idx1=zeros(length(idx),1);
boundbox=regionprops(L,'BoundingBox');
imgregion=regionprops(L,'Image');
bufferpix=ceil(2/.46); % move half a cell in each direction
[h,w]=size(bitimg);
broadimg=zeros(h+bufferpix*2,w+bufferpix*2);
broadimg(bufferpix+1:bufferpix+h,bufferpix+1:bufferpix+w)=bitimg; % outside of the image is 0
%%
for k=1:length(boundbox)
    %%
    if boundbox(k).BoundingBox(3)==w
        idx(k)=0;
    else
        boundbox(k).BoundingBox=round(boundbox(k).BoundingBox);
        cellbox=bitimg(boundbox(k).BoundingBox(2):boundbox(k).BoundingBox(2)+boundbox(k).BoundingBox(4)-1,...
            boundbox(k).BoundingBox(1):boundbox(k).BoundingBox(1)+boundbox(k).BoundingBox(3)-1);
        cellsignal=cellbox.*imgregion(k).Image;
        %%
        broadbox=broadimg(bufferpix+boundbox(k).BoundingBox(2)-bufferpix:boundbox(k).BoundingBox(2)+boundbox(k).BoundingBox(4)-1+bufferpix*2,...
            bufferpix+boundbox(k).BoundingBox(1)-bufferpix:boundbox(k).BoundingBox(1)+boundbox(k).BoundingBox(3)-1+bufferpix*2);
        broadbox_cellmask=single(broadbox>0);
        broadbox_cellmask(bufferpix+1:bufferpix+boundbox(k).BoundingBox(4),bufferpix+1:bufferpix+boundbox(k).BoundingBox(3))=single(imgregion(k).Image)*2;
        broadbox_cellmask( ~any(broadbox,2), : ) = []; % remove zero rows
        broadbox_cellmask( :, ~any(broadbox,1) ) = []; % remove zero columns
        broadbox_cellmask=(broadbox_cellmask==2);
        broadbox( ~any(broadbox,2), : ) = []; % remove zero rows
        broadbox( :,~any(broadbox,1) ) = [];  % remove zero columns
        
        %%
        bgsignal=broadbox.*(1-broadbox_cellmask);
        bgsignal(bgsignal==0)=nan;
        bgsignal(isinf(bgsignal))=0;
        %         cellsnr=nanmean(cellsignal(~isinf(cellsignal)))-nanmean(bgsignal(~isinf(bgsignal)));
        cellsnr=nanmean(nonzeros(cellsignal))-nanmean(nanmean(bgsignal));
        if bitinfo==12
%             snrthresh=3;
            snrthresh=2;
        else
            snrthresh=2;
        end
        if cellsnr>=snrthresh % at least 3 bit difference
            idx1(k)=idx(k); % keep the index
        end
    end
end
idx=nonzeros(idx1); % remove the index
[~,L] = ismember(L,idx); % pick out only cells with large enough SNR