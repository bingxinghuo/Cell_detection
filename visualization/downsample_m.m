%% downsample_m.m
% This function performs downsampling of the 2-D image by M times using
% custom method (max, min or mean) within the M-by-M block
% Input:
%   - img: 2-D matrix containing the image
%   - M: integer specifying the downsampling scale
%   - type: 'mean'(default)|'min'|'max'
% Output:
%   - imgdown: 2-D matrix in the same type as img containing the downsampled image
%   - indx: optional. row indices of the  pixels selected to form the
%   downsmapled image
%   - indy: optional. column indices.
function [imgdown,indx,indy]=downsample_m(img,M,type)
%% 1. logical judgement
if nargin<2
    error('Not enough input variables!')
elseif nargin==2
    type='mean'; % default is mean
    if nargout>1
        error('Too many output! Index output is unavailable for mean downsample.')
    end
elseif nargin>2
    options='maxminmean';
    if contains(options,type)
        if strcmp(type,'mean')
            if nargout>1
                error('Too many output! Index output is unavailable for mean downsample.')
            end
        else
            if nargout==2
                error('Note enough output variables! Consider add another variable or remove it.')
            end
        end
    else
        error('Invalid type argument!')
    end
end
%% 2. adjust image
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
if mod(cols,M)==0
    padcol=0;
else
    padcol=M-mod(cols,M);
end
padcolmat=zeros(rows+padrow,padcol);
padcolmat=cast(padcolmat,'like',img);
imgpad=[imgpad,padcolmat];
%% 3. downsample
[rows,cols]=size(imgpad);
imgdown=zeros(rows/M,cols/M);
if nargout>1
    indx=zeros(rows/M,cols/M);
    indy=zeros(rows/M,cols/M);
end
imgdown=cast(imgdown,'like',img); % downsampled image is the same type as the original image
for rs=1:rows/M
    for cs=1:cols/M
        imgblk=imgpad((rs-1)*M+1:rs*M,(cs-1)*M+1:cs*M);
        if nargin>2
            if strcmp(type,'min')
                [imgdown(rs,cs),ind]=nanmin(reshape(imgblk,M^2,1));
            elseif strcmp(type,'max')
                [imgdown(rs,cs),ind]=nanmax(reshape(imgblk,M^2,1));
            elseif strcmp(type,'mean') % Note: no ind output
                imgdown(rs,cs)=nanmean(reshape(imgblk,M^2,1));
            end
            if nargout>1 % record the indices
                indy(rs,cs)=floor((ind-1)/M)+1+(cs-1)*M;
                indx(rs,cs)=mod((ind-1),M)+1+(rs-1)*M;
            end
        else
            imgdown(rs,cs)=nanmean(reshape(imgblk,M^2,1));
        end
    end
end