% use watershed method to detect cells
function L=cellsep(L,imgbit)
idx=max(max(L));
img_mod=zeros(size(L));
L=imfill(L,'holes');
for i=1:idx
    imobj=L==i;
    imobj=imobj.*imgbit;
    imobj(isnan(imobj))=0;
    coreimg=imextendedmax(imobj,1); % 1 bit difference
    %
    imobj_c=imcomplement(imobj);
    objmask=imobj_c<0;
    se_dia=2;
    se=strel('disk',se_dia);
    objmask=imdilate(objmask,se);
    %
    obj_mod=objmask-coreimg;
img_mod=img_mod+obj_mod;
end
L=watershed(img_mod);