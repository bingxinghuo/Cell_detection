%% downsample_maxL1.m
% This function performs downsampling of the 2-D image by M times using
% maximum within the M-by-M block
% Input:
%   - img: 2-D matrix containing the image
%   - M: integer specifying the downsampling scale
% Output:
%   - imgdown: 2-D matrix in the same type as img containing the downsampled image
function imgdown=downsample_maxL1(rgbimg,M,bgadj)
[rows,cols,~]=size(rgbimg);
% % pad rows with zeros
% if mod(rows,M)==0
%     padrow=0;
% else
%     padrow=M-mod(rows,M);
% end
% padrowmat=zeros(padrow,cols,3);
% padrowmat=cast(padrowmat,'like',rgbimg);
% imgpad=[rgbimg;padrowmat];
% % pad columns with zeros
% if mod(cols,M)==0
%     padcol=0;
% else
%     padcol=M-mod(cols,M);
% end
% padcolmat=zeros(rows+padrow,padcol,3);
% padcolmat=cast(padcolmat,'like',rgbimg);
% imgpad=[imgpad,padcolmat];
% % downsample
% [rows,cols,~]=size(imgpad);
imgdown=zeros(rows/M,cols/M);
imgdown=cast(imgdown,'like',rgbimg); % downsampled image is the same type as the original image
for rs=1:rows/M
    tic
    for cs=1:cols/M
        % extract block
        imgblk=rgbimg((rs-1)*M+1:rs*M,(cs-1)*M+1:cs*M,:);
        % adjust global intensity
        for c=1:3
            imgblk(:,:,c)=imgblk(:,:,c)-bgadj(c);
        end
        % convert
        imgblkhsv=rgb2hsv(double(imgblk));
        imgblkhsv(:,:,1)=(imgblkhsv(:,:,1)>=.5).*(imgblkhsv(:,:,1)<=.75).*imgblkhsv(:,:,1); %
%         imgblkhsv(:,:,2)=1;
        % downsample
        imgdown(rs,cs,1)=nanmean(nonzeros(imgblkhsv(:,:,1)));
%         imgdown(rs,cs,2)=nanmean(reshape(imgblkhsv(:,:,2),M^2,1));
        imgdown(rs,cs,3)=nanmax(reshape(imgblkhsv(:,:,3),M^2,1));
        %         imgdown(rs,cs)=nanmean(reshape(imgblk,M^2,1));
    end
    toc
end