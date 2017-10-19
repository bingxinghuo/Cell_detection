function tiffconvbloc(fluoroimg,fileout)
myFun = @(block_struct) blockgradient(block_struct);
block_size=[512,512];
% fileout=[fileid(1:end-4),'16rgb.jp2'];
% fileout=[fileid(1:end-4),'.tiff'];
blockproc(fluoroimg,block_size,myFun,'Destination',fileout);
end
% 
function BG=blockgradient(block_struct)
% [rows,cols]=size(block_struct.data);
% channelpad=uint16(zeros(rows,cols));
% BG=cat(3,channelpad,channelpad,uint16(block_struct.data*2^16));
BG=block_struct.data;
end