%% rmbg.m
% Bingxing Huo @ 2017
% This function applies a mexican hat-like Difference of Gaussian composite filter to
% remove the background and sharp foreground noise
% Inputs:
%   - rgbimg: an RGB image to be processed
%   - sigma: a [s1,s2] vector containing 2 integers. s1>s2. s1 is for background removal and s2 is
%   for sharp noise removal.
% Output:
%   - img_denoise: a single type RGB image.
function img_denoise=rmbg(rgbimg,sigma)
h1=fspecial('gaussian',[1,2*ceil(3*sigma(1))+1], sigma(1));
h2=fspecial('gaussian',[1,2*ceil(3*sigma(2))+1], sigma(2));
h2_1=zeros(size(h1));
h2_1((ceil(3*sigma(1))-ceil(3*sigma(2))):(ceil(3*sigma(1))+ceil(3*sigma(2))))=h2;
h=h2_1-h1;
rgbimg=single(rgbimg);
[rows,cols,colors]=size(rgbimg);
img_denoise=single(zeros(rows,cols,colors));
for c=1:colors
    img_denoise(:,:,c)=conv2(h,h,squeeze(rgbimg(:,:,c)),'same');
end
img_denoise=img_denoise.*(img_denoise>0);