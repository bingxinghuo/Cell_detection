function [cellsignal1,cellmask1,boundbox1]=cellcut_tile_v2(cellmask0,cellimg,boundbox)
global sigma sizepar eccpar
se=strel('disk',1);
se1=strel('disk',2);
%
k=0;
cellsignal1=cell(1);
cellmask1=cell(1);
boundbox1=cell(1);
cellmask=cellmask0;
% 1. Decide whether the image needs to be cut
% cellpix=sum(sum(cellmask0));
regionpix=boundbox.BoundingBox(3)*boundbox.BoundingBox(4);
if regionpix<sizepar(2) % likely only one cell
    cc0=bwconncomp(cellmask0);
    N=cc0.NumObjects;
    if N==1
        needcut=0;
        % deal with images that don't need cutting
        k=k+1;
        cellsignal1{k,1}=cellimg;
        cellmask1{k,1}=cellmask;
        boundbox1{k,1}=boundbox.BoundingBox; % save the boundbox from rgbimg
    else
        needcut=1;
    end
else % large images are likely to contain more than one cell
    needcut=1;
end
% 2. cut
cellmasks={cellmask};
t=0;
while needcut==1 % flag cutting process
    t=t+1; % work on large images in sequence
    cellmask=cellmasks{t}; % first one is just cellmask0
    %     disp(ic)
    %     rectangle('Position',boundbox.BoundingBox,'EdgeColor','r')
    %     alldone='n'; % preset manual job check
    %     while alldone=='n'
    %     cellmask=cellmask0;
    %         ax1=subplot(1,3,1); imagesc(uint8(cellimg)); axis image; hold on
    %         ax2=subplot(1,3,2:3);imagesc(cellmask0); axis image; hold on
    % 2.1 cut
    %% 2.1.1 Solution 1: Use LoG
    %         Lcell=logcut(cellimg,cellmask,se,se1);
    %         %         boundboxcell=regionprops(Lcell,'BoundingBox');
    %         %         cellregion=regionprops(Lcell,'Image');
    %         hold(ax2,'off'); imagesc(ax2,Lcell); axis image
    %% 2.1.2 Solution 2: Use Das method
    Lcell=gradcut(cellmask,sigma,se1);
    
    %         hold(ax2,'off'); imagesc(ax2,Lcell); axis image
    %% Extract individual cell
    icells=unique(Lcell);
    icells=icells(icells>0);
    boundboxcell=regionprops(Lcell,'BoundingBox');
    cellregion=regionprops(Lcell,'Image');
    %     cellfinaldisp=zeros(size(Lcell));
    needcut=0; % initialize cut criteria
    for p=1:length(icells)
        icell=icells(p);
        cellmaski=Lcell==icell;
        boundboxcell(icell).BoundingBox=round(boundboxcell(icell).BoundingBox);
        regionpix=boundboxcell(icell).BoundingBox(3)*boundboxcell(icell).BoundingBox(4);
        if regionpix<sizepar(2) % likely only one cell
            needcut=needcut||0; % must be all 0 to stop
            k=k+1;
            cellbox=cellimg(boundboxcell(icell).BoundingBox(2):boundboxcell(icell).BoundingBox(2)+boundboxcell(icell).BoundingBox(4)-1,...
                boundboxcell(icell).BoundingBox(1):boundboxcell(icell).BoundingBox(1)+boundboxcell(icell).BoundingBox(3)-1,:);
            imgk=cast(cellregion(icell).Image,'like',cellbox);
            cellsignal1{k,1}=cellbox.*cat(3,imgk,imgk,imgk);
            boundbox1{k,1}=[boundbox.BoundingBox(1:2)+boundboxcell(icell).BoundingBox(1:2),boundboxcell(icell).BoundingBox(3:4)]; % save the boundbox from rgbimg
            cellmask1{k,1}=imopen(cellmaski,se);
        else % large images are likely to contain more than one cell
            needcut=needcut||1; % any 1 will throw back to loop
            cellmasks=[cellmasks;{cellmaski}]; % append big images to the end of the queue
        end
        %             cellfinaldisp=cellfinaldisp+double(cellmask1{k,1})*double(icell);
        needcut=needcut||(t~=length(cellmasks)); % check if at the end of the list
        
    end
    % final check of cutting results
    %         imagesc(ax2,cellfinaldisp);
    %         axis(ax2,'image');
    %         hold(ax1,'off');
    %         cellfinalmask=cellfinaldisp>0;
    %         imagesc(ax1,uint8(cellimg).*uint8(cat(3,cellfinalmask,cellfinalmask,cellfinalmask)));
    %         axis(ax1,'image');
    %         alldone=input('Are you done with this section? (y/n) ','s');
    %         clf
    %     alldone='y';
end
end
%%
function Lcell=logcut(cellimg,cellmask,se,se1)
global sigma sizepar eccpar
h=fspecial('log',3); % parameters not adjusted
celledge=conv2(cellimg(:,:,2),h,'same');
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
    if labelareas(n).Area<sizepar(1) % threshold cell size
        Lcell(Lcell==n)=0;
    end
end
end
%%
function Lcell=gradcut(cellmask0,sigma,se1)
bwimg_smooth=imfilter(double(cellmask0),sigma);
bwimg1=bwimg_smooth>0; % convert to binary
edg = bwperim(bwimg1); % generate edges of cells
% 1.2. Generate distance matrix
dist_tr = bwdist(edg); % generate the distance intensity map
% 1.3. Combine the mask and distance matrix
and = bwimg1.*dist_tr; % reconstruct
and(isnan(and))=0;
ind=imgaussfilt(and,sigma(2)); % denoise
bwimg_c=max(max(ind))-(cellmask0.*and);
bwimg_c1=bwimg_c.*single((cellmask0));
[rows,cols]=size(bwimg_c1);
bwimg_c1=cat(1,zeros(1,cols),bwimg_c1,zeros(1,cols));
bwimg_c1=cat(2,zeros(rows+2,1),bwimg_c1,zeros(rows+2,1));
W=watershed(bwimg_c1);
W1=W(2:end-1,2:end-1);
W1=W1.*uint8(W1>1);  % 1 is background
% get individual regions

Lcell=imclose(W1,se1);
Lcell=imfill(Lcell,'holes');
end