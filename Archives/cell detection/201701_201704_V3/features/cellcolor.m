%% color segmentation
function imgtemp_rgb1=cellcolor(imgtemp_rgb)
hsvimg=rgb2hsv(imgtemp_rgb);
bluemask=hsvimg(:,:,1)>.5 & hsvimg(:,:,1)<.75; % from cyan to violet, all consider to be blue
imgtemp_rgb1=single(imgtemp_rgb).*cat(3,bluemask,bluemask,bluemask);