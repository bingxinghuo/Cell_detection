% create the monochrome image for saturated area
function satumask=satmask(imgtemp,sigma)
global bitinfo
%% general background
% for newer version of Matlab
%                 imgfilt=imgaussfilt(imgtemp_rgb,20);
% for older version of Matlab
% sigma=20;
imgfilt = imfilter(imgtemp,fspecial('gaussian',2*ceil(2*sigma)+1, sigma),'same');
%% saturation mask
satumask=imgfilt>2^bitinfo*.95; % more than 95% of the max intensity
% if sum(sum(satumask))>thresh_count % if there are at least 10 pixels in the saturated mask
%     %% 1. saturated area
%     imgtemp_sat=imgtemp_nobak.*cat(3,satumask,satumask,satumask);
%     % there should not be useful information in the interest channel. Ignore.
%     imgsat=imgtemp_sat(:,:,1)+imgtemp_sat(:,:,2);
% end