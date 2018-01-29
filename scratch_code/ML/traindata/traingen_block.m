% [rgbimg,imgorigin,~]=maskadj_reg(fluoroimg,savedata);
% imgorigin=round(imgorigin);
% rgbimg=fluoroimg(imgorigin(1):imgorigin(3),imgorigin(2):imgorigin(4),:);
function traingen_block(rgbimg,blk)
[rows,cols,~]=size(rgbimg);
% blk=30;
H=floor(rows/blk);
W=floor(cols/blk);
figure('Color',[0 0 0])
% imgvector=[];
% imgscore=[];
dlmwrite('imgblkvector.txt','','delimiter',' ');
dlmwrite('imgblkgroup.txt','','delimiter',' ');
for h=2:H
    for w=2:W
        % 1. upper left corner
        blkimg=rgbimg((h-1)*blk+1-blk/2:h*blk-blk/2,(w-1)*blk-blk/2+1:w*blk-blk/2,:);
        manualtrain(blkimg,blk)
        % 2. upper right corner
        blkimg=rgbimg((h-1)*blk+1-blk/2:h*blk-blk/2,(w-1)*blk+1:w*blk,:);
        manualtrain(blkimg,blk)
        % 3. lower left corner
        blkimg=rgbimg((h-1)*blk+1:h*blk,(w-1)*blk-blk/2+1:w*blk-blk/2,:);
        manualtrain(blkimg,blk)
        % 4. lower right corner
        blkimg=rgbimg((h-1)*blk+1:h*blk,(w-1)*blk+1:w*blk,:);
        manualtrain(blkimg,blk)
    end
end
end
%%%%
function manualtrain(blkimg,blk)
blkvector=reshape(blkimg,1,blk*blk*3);
dlmwrite('imgblkvector.txt',blkvector,'-append','delimiter',' ');
%         imgvector=[imgvector;blkvector];
if sum(sum(blkimg(:,:,3)))<=5000
    blkscore=0;
else
    imagesc(uint8(blkimg))
    axis image
    blkscore=input('Is this a cell? (1-yes; []-no)');
    if isempty(blkscore)
        blkscore=0;
    end
end
dlmwrite('imgblkgroup.txt',blkscore,'-append','delimiter',' ');
end