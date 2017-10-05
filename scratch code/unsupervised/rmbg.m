function imgtemp_nobak=rmbg(imgtemp_rgb)
% for newer version of Matlab
%                 imgfilt=imgaussfilt(imgtemp_rgb,10);
% for older version of Matlab
sigma=20;
imgfilt = imfilter(imgtemp_rgb,fspecial('gaussian',2*ceil(2*sigma)+1, sigma),'replicate');
% remove background/saturation
imgtemp_nobak=single(imgtemp_rgb-imgfilt);