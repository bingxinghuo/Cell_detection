[rows,cols,~]=size(rgbimg);
blk=30;
H=floor(rows/blk);
W=floor(cols/blk);
M=ones(blk);
blkimg=zeros(rows,cols);
k=1;
n=1;
for h=2:H
    for w=2:W
        if n<3301
            n=n+4;
        else    
        % 1. upper left corner
        blkimg((h-1)*blk+1-blk/2:h*blk-blk/2,(w-1)*blk-blk/2+1:w*blk-blk/2,:)=...
            blkimg((h-1)*blk+1-blk/2:h*blk-blk/2,(w-1)*blk-blk/2+1:w*blk-blk/2,:)+group_est(k)*M;
        k=k+1;
        % 2. upper right corner
        blkimg((h-1)*blk+1-blk/2:h*blk-blk/2,(w-1)*blk+1:w*blk,:)=...
            blkimg((h-1)*blk+1-blk/2:h*blk-blk/2,(w-1)*blk+1:w*blk,:)+group_est(k)*M;
        k=k+1;
         % 3. lower left corner
        blkimg((h-1)*blk+1:h*blk,(w-1)*blk-blk/2+1:w*blk-blk/2,:)=...
            blkimg((h-1)*blk+1:h*blk,(w-1)*blk-blk/2+1:w*blk-blk/2,:)+group_est(k)*M;
        k=k+1;
        % 4. lower right corner
        blkimg((h-1)*blk+1:h*blk,(w-1)*blk+1:w*blk,:)=...
            blkimg((h-1)*blk+1:h*blk,(w-1)*blk+1:w*blk,:)+group_est(k)*M;
        k=k+1;
        end
    end
end