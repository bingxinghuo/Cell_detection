function jp22pngtile(fluoroimg1,FBclear,fileind,fileid)
global blk
[rows,cols,~]=size(fluoroimg1);
FBcells=round(FBclear{fileind});
blk=512;
H=floor(rows/blk);
W=floor(cols/blk);
k=1;
figure
for h=1:H
    for w=1:W
        blkimg=fluoroimg1((h-1)*blk+1:h*blk,(w-1)*blk+1:w*blk,:);
        blkcellind=(FBcells(:,2)>=(h-1)*blk+1).*(FBcells(:,2)<=h*blk).*...
            (FBcells(:,1)>=(w-1)*blk+1).*(FBcells(:,1)<=w*blk);
        blkcell=FBcells(find(blkcellind),:);
        blkcellwhite=celloverlay(blkcell,h,w);
        blkimgcombine=blkcellwhite+blkimg;
        pngtilefile=[fileid(1:end-4),'_t',num2str(k),'.png'];
        imwrite(blkimgcombine,pngtilefile,'png');
        k=k+1;
    end
    blkimg=fluoroimg1((h-1)*blk+1:h*blk,W*blk+1:end,:);
    blkcellind=(FBcells(:,2)>=(h-1)*blk+1).*(FBcells(:,2)<=h*blk).*...
        (FBcells(:,1)>=W*blk+1);
    blkcell=FBcells(find(blkcellind),:);
    blkcellwhite=celloverlay(blkcell,h,W+1);
    blkimgcombine=blkcellwhite+blkimg;
    pngtilefile=[fileid(1:end-4),'_t',num2str(k),'.png'];
    imwrite(blkimgcombine,pngtilefile,'png');
    k=k+1;
end
for w=1:W
    blkimg=fluoroimg1(H*blk+1:end,(w-1)*blk+1:w*blk,:);
    blkcellind=(FBcells(:,2)>=H*blk+1).*...
        (FBcells(:,1)>=(w-1)*blk+1).*(FBcells(:,1)<=w*blk);
    blkcell=FBcells(find(blkcellind),:);
    blkcellwhite=celloverlay(blkcell,H+1,w);
    blkimgcombine=blkcellwhite+blkimg;
    pngtilefile=[fileid(1:end-4),'_t',num2str(k),'.png'];
    imwrite(blkimgcombine,pngtilefile,'png');
    k=k+1;
end
blkimg=fluoroimg1(H*blk+1:end,W*blk+1:end,:);
blkcellind=(FBcells(:,2)>=H*blk+1).*(FBcells(:,1)>=W*blk+1);
blkcell=FBcells(find(blkcellind),:);
blkcellwhite=celloverlay(blkcell,H+1,W+1);
blkimgcombine=blkcellwhite+blkimg;
pngtilefile=[fileid(1:end-4),'_t',num2str(k),'.png'];
imwrite(blkimgcombine,pngtilefile,'png');
end
%%%%%%%%%
function blkcellwhite=celloverlay(blkcell,h,w)
global blk
se=strel('diamond',3);
blkcell=blkcell-ones(size(blkcell,1),1)*[(w-1)*blk,(h-1)*blk];
blkcellwhite=logical(zeros(blk,blk));
for i=1:size(blkcell,1)
    blkcellwhite(blkcell(i,2),blkcell(i,1))=true;
end
blkcellwhite=imdilate(blkcellwhite,se);
blkcellwhite=bwperim(blkcellwhite);
blkcellwhite=uint8(single(blkcellwhite)*255);
blkcellwhite=cat(3,blkcellwhite,blkcellwhite,blkcellwhite);
end