%% 16 bit
% function rgbconvbloc(filein,fileout)
% myFun = @(block_struct) blockgradient(block_struct);
% block_size=[512,512];
% blockproc(filein,block_size,myFun,'Destination',fileout);
% end
% 
% function BG=blockgradient(block_struct)
% [rows,cols]=size(block_struct.data);
% channelpad=uint16(zeros(rows,cols));
% BG=cat(3,channelpad,channelpad,uint16(block_struct.data*(2^8-1)));
% end
%% 8 bit
function rgbconvbloc(filein,fileout)
myFun = @(block_struct) blockgradient(block_struct);
block_size=[512,512];
blockproc(filein,block_size,myFun,'Destination',fileout);
end

function BG=blockgradient(block_struct)
cellmask=uint8(block_struct.data*(2^8-1));
BG=cat(3,cellmask,cellmask,cellmask);
end