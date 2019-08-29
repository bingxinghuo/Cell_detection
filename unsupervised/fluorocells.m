%% fluorocells.m
% Bingxing Huo, July 2019
% 
% sizepar=[2,100]; % radius in microns
% sigma=[200 1]; % s.d. in microns
% resolution=.25;
%% 0. image loading and parameters
img=imread(imgfile);
sigma=sigma*resolution; % convert into pixels
% sigma1=sigma(1)*resolution;
% sigma2=sigma(2)*resolution;
sizepar=round(sizepar.^2*pi/resolution^2);
sizepar1=sizepar(1);
%% 1. Preprocess
% 1.1 mask
