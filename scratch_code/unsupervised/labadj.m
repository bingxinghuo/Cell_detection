function Stile2=labadj(Stile)
% srgb2lab = makecform('srgb2lab');
% lab2srgb = makecform('lab2srgb');
%
% Slab=applycform(double(Stile/(2^12)),srgb2lab);
Slab=rgb2lab(double(Stile));
Slab(:,:,1)=imadjust((Slab(:,:,1)-mean(mean(Slab(:,:,1))))/100)*50;
Stile2=lab2rgb(Slab);
% Stile2=applycform(Slab,lab2srgb);