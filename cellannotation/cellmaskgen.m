%% cellmaskgen.m
% This script converts cell coordinates into masks of cells into 8-bit gray
% image
function cellmask=cellmaskgen(cellind,jp2file,cellmaskfile,dsrate)
inputimg=imfinfo(jp2file);
cellmask=uint8(false(inputimg.Height,inputimg.Width));
if ~isempty(cellind)
    cellind=round(cellind);
    for c=1:size(cellind,1)
        cellmask(cellind(c,2),cellind(c,1))=255;
    end
end
cellmask=downsample_max(cellmask,dsrate);
imwrite(cellmask,cellmaskfile,'tif');