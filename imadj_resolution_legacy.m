function imgout=imadj_resolution(imgin,currentres,targetres,method,topres)
if nargin<4
    method='mean';
end
if nargin<5
    topres=.46;
end
if mod(targetres,currentres)==0
    imgout=downsample_m(imgin,(targetres/currentres),method);
else
    imgup=imresize(imgin,currentres/topres,'nearest');% upsample to the original resolution
    % imgup=upsampleimg(imgin,ceil(K/currentres));
    imgout=downsample_m(imgup,ceil(targetres/topres),method); % downsample to the target resolution
end