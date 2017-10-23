%% 16 bit
% function bit16to8_bloc(filein,fileout)
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
% This part of the code aims at converting either binary or 16-bit black/blue JP2
% into 8-bit black/white JP2
function bit16to8_bloc(filein,fileout)
bitinfo=imfinfo(filein);
bitinfo=bitinfo.BitDepth;
if bitinfo==1
    myFun = @(block_struct) blockbin2rgb(block_struct);
elseif bitinfo==48
    myFun = @(block_struct) block16to8bit(block_struct);
else
    disp([filein,' format is incorrect!'])
end
block_size=[512,512];
blockproc(filein,block_size,myFun,'Destination',fileout);
end

function cellrgbmask=blockbin2rgb(block_struct)
cellmask=uint8(block_struct.data*(2^8-1));
cellrgbmask=cat(3,cellmask,cellmask,cellmask);
end


function cellrgbmask=block16to8bit(block_struct)
cellmask=uint8(block_struct.data(:,:,3));
cellrgbmask=cat(3,cellmask,cellmask,cellmask);
end