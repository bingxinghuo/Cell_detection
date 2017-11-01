function imgdown=jp22tif_downsample(img,M)
[rows,cols]=size(img);
if mod(rows,M)==0
    padrow=0;
else
    padrow=M-mod(rows,M);
end
imgpad=[img;uint8(zeros(padrow,cols))];
if mode(cols,M)==0
    padcol=0;
else
    padcol=M-mod(cols,M);
end
imgpad=[imgpad,uint8(zeros(rows+padrow,padcol))];
[rows,cols]=size(imgpad);
imgdown=uint8(zeros(rows/M,cols/M));
for rs=1:rows/M
    for cs=1:cols/M
        imgblk=imgpad((rs-1)*M+1:rs*M,(cs-1)*M+1:cs*M);
        imgdown(rs,cs)=max(reshape(imgblk,M^2,1));
    end
end