function [cellsignal1,cellmask1,boundbox1]=cellcut_tile(cellmask0,cellimg,boundbox,ic)
se=strel('disk',1);
se1=strel('disk',2);
sizepar=50;
%
k=0;
cellsignal1=cell(1);
cellmask1=cell(1);
boundbox1=cell(1);
% 1. Decide whether the image needs to be cut
cellpix=sum(sum(cellmask0));
if cellpix<400 % likely only one cell
    cc0=bwconncomp(cellmask0);
    N=cc0.NumObjects;
    if N==1
        needcut=0;
        cellmask=cellmask0;
    else
        needcut=1;
    end
else % large images are likely to contain more than one cell
    needcut=1;
end
% 2. cut
if needcut==1 % flag cutting process
    disp(ic)
    alldone='n'; % preset job check
    while alldone=='n'
        cellmask=cellmask0;
        ax1=subplot(1,3,1); imagesc(uint8(cellimg)); axis image; hold on
        ax2=subplot(1,3,2:3);imagesc(cellmask0); axis image; hold on
        cellcut=input('Does this need further segmentation? (y/n) ','s');
        % 2.1 cut
        if cellcut=='y'
            % 2.1.1 automatic cut
            h=fspecial('log',3); % parameters not adjusted
            celledge=conv2(cellimg(:,:,3),h,'same');
            cutmask=celledge>0;
            cutmask=imdilate(cutmask,se);
            cutmask=1-cutmask;
            cellmask=cellmask.*cutmask; % new cut cell mask
            cellmask=imdilate(cellmask,se);
            % get individual regions
            cc=bwconncomp(cellmask);
            Lcell=labelmatrix(cc);
            Lcell=imclose(Lcell,se1);
            Lcell=imfill(Lcell,'holes');
            % remove too small regions
            labelareas=regionprops(Lcell,'area');
            for n=1:length(labelareas)
                if labelareas(n).Area<sizepar % threshold cell size
                    Lcell(Lcell==n)=0;
                end
            end
            boundboxcell=regionprops(Lcell,'BoundingBox');
            cellregion=regionprops(Lcell,'Image');
            hold(ax2,'off'); imagesc(ax2,Lcell); axis image
            manadj=input('Accept the automatic cut? (y/n) ','s');
            % 2.1.2 manual cut
            if manadj=='n'
                % manual cut
                disp('Proceed with manual cut...')
                title(ax2,'Cut cells in this panel','fontsize',20,'color','w')
                [h,w,~]=size(cellimg);
                cutmask=zeros(h,w);
                % identify pairs of points to cut the image
                [xi,yi]=getpts(ax2);
                N=length(xi);
                xi=reshape(xi,2,N/2);
                yi=reshape(yi,2,N/2);
                for p=1:N/2
                    h=imline(ax2,[xi(1,p),yi(1,p);xi(2,p),yi(2,p)]);
                    cutmask=cutmask+createMask(h);
                end
                %
                cutmask=imdilate(cutmask,se);
                cutmask=1-cutmask;
                %                     cellmask=cellmask0;
                cellmask=cellmask.*(Lcell>0);
                cellmask=cellmask.*cutmask; % new cut cell mask
                % get individual regions
                cc=bwconncomp(cellmask);
                Lcell=labelmatrix(cc);
                Lcell=imclose(Lcell,se1);
                Lcell=imfill(Lcell,'holes');
                boundboxcell=regionprops(Lcell,'BoundingBox');
                cellregion=regionprops(Lcell,'Image');
                imagesc(ax2,Lcell); axis image
            end
            % 2.2 manually identify cells
            % manually identify cells
            title(ax2,'Click on the cells','fontsize',20,'color','w')
            [xi,yi]=getpts(ax2);
            yi=round(yi);
            xi=round(xi);
            % get the cell labels
            % make sure they are unique
            icells=zeros(length(xi),1);
            for p=1:length(xi)
                icells(p)=Lcell(yi(p),xi(p));
            end
            icells=unique(icells);
            cellfinaldisp=zeros(size(Lcell));
            for p=1:length(icells)
                k=k+1;
                icell=icells(p);
                cellmaski=Lcell==icell;
                cellmaski=imopen(cellmaski,se);
                cellmask1{k,1}=cellmaski;
                boundboxcell(icell).BoundingBox=round(boundboxcell(icell).BoundingBox);
                cellbox=cellimg(boundboxcell(icell).BoundingBox(2):boundboxcell(icell).BoundingBox(2)+boundboxcell(icell).BoundingBox(4)-1,...
                    boundboxcell(icell).BoundingBox(1):boundboxcell(icell).BoundingBox(1)+boundboxcell(icell).BoundingBox(3)-1,:);
                imgk=cast(cellregion(icell).Image,'like',cellbox);
                cellsignal1{k,1}=cellbox.*cat(3,imgk,imgk,imgk);
                boundbox1{k,1}=[boundbox(ic).BoundingBox(1:2)+boundboxcell(icell).BoundingBox(1:2),boundboxcell(icell).BoundingBox(3:4)]; % save the boundbox from rgbimg
                cellfinaldisp=cellfinaldisp+double(cellmask1{k,1})*double(icell);
            end
            % 2.1 don't cut
        else
            needcut=0; % change flag
            cellmask=imopen(cellmask,se);
            cellfinaldisp=cellmask;
        end
        % final check of cutting results
        imagesc(ax2,cellfinaldisp); 
        axis(ax2,'image');
        hold(ax1,'off');
        cellfinalmask=cellfinaldisp>0;
        imagesc(ax1,uint8(cellimg).*uint8(cat(3,cellfinalmask,cellfinalmask,cellfinalmask))); 
        axis(ax1,'image');
        alldone=input('Are you done with this section? (y/n) ','s');
        clf
    end
end
% deal with images that don't need cutting
if needcut==0
    k=k+1;
    cellsignal1{k,1}=cellimg;
    cellmask1{k,1}=cellmask;
    boundbox1{k,1}=boundbox(ic).BoundingBox; % save the boundbox from rgbimg
end