function [bundleidx,bwimg_patch]=cellpatch(bwimg)
% initialize
bundleidx=[];
bwimg_patch=cell(2,1);
% parameter
sizthresh=500;
% generate index
CC=bwconncomp(bwimg);
num=zeros(CC.NumObjects,1);
% find really large patches
for i=1:CC.NumObjects
    num(i)=length(CC.PixelIdxList{i});
    if num(i)>sizthresh % this is a 
        bundleidx=[bundleidx;i];
    end
end
if ~isempty(bundleidx) % if there are really large patches
    % small parts
    bwimg1=bwimg;
    for b=1:length(bundleidx)
        bwimg1(CC.PixelIdxList{bundleidx(b)})=0;
    end
    % large parts
    bwimg2=bwimg-bwimg1;
    bwimg_patch{1}=bwimg1;
    bwimg_patch{2}=bwimg2;
end