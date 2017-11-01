%% downsample_max.m
% This function performs downsampling of the 2-D image by M times using
% maximum within the M-by-M block
% Input: 
%   - img: 2-D matrix containing the image
%   - M: integer specifying the downsampling scale
% Output:
%   - imgdown: 2-D matrix in the same type as img containing the downsampled image
function imgdown=downsample_max(img,M)
[rows,cols]=size(img);
% pad rows with zeros
if mod(rows,M)==0
    padrow=0;
else
    padrow=M-mod(rows,M);
end
padrowmat=zeros(padrow,cols);
padrowmat=cast(padrowmat,'like',img);
imgpad=[img;padrowmat];
% pad columns with zeros
if mode(cols,M)==0
    padcol=0;
else
    padcol=M-mod(cols,M);
end
padcolmat=zeros(rows+padrow,padcol);
padcolmat=cast(padcolmat,'like',img);
imgpad=[imgpad,padcolmat];
% downsample
[rows,cols]=size(imgpad);
imgdown=zeros(rows/M,cols/M);
imgdown=cast(imgdown,'like',img); % downsampled image is the same type as the original image
for rs=1:rows/M
    for cs=1:cols/M
        imgblk=imgpad((rs-1)*M+1:rs*M,(cs-1)*M+1:cs*M);
        imgdown(rs,cs)=max(reshape(imgblk,M^2,1));
    end
end