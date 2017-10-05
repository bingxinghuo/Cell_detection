% create the monochrome image for saturated area
function [imgsat,satumask]=satmask(imgtemp_rgb,thresh_count)
global bitinfo
%% general background
sigma=20;
% for newer version of Matlab
%                 imgfilt=imgaussfilt(imgtemp_rgb,sigma);
% for older version of Matlab
imgfilt = imfilter(imgtemp_rgb,fspecial('gaussian',2*ceil(2*sigma)+1, sigma),'replicate');
%% saturation mask
satumask=imgfilt(:,:,3)>2^bitinfo*.95; % more than 95% of the max intensity
if sum(sum(satumask))>thresh_count % if there are at least 10 pixels in the saturated mask
    %% 1. saturated area
    imgtemp_sat=imgtemp_nobak.*cat(3,satumask,satumask,satumask);
    % there should not be useful information in the interest channel. Ignore.
    imgsat=imgtemp_sat(:,:,1)+imgtemp_sat(:,:,2);
end