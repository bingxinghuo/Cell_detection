function Gmag=gradienttest(Bcontrast)
myFun = @(block_struct) blockgradient(block_struct);
block_size=[512,512];
border_size=[2,2];
Gmag=blockproc(Bcontrast,block_size,myFun,'BorderSize',border_size);
end

function BG=blockgradient(block_struct)
[Gmag,~]=imgradient(block_struct.data);
BG=Gmag;
end