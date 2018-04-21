%% FBdetection_consolid_v5.m
% Bingxing Huo
% consolidating Keerthi's and Bingxing's code
% This script was written to match Matlab 2014 version functions
% This script calls the following functions:
%   - preprocess.m
%   - cellpatch.m to detect connected cells
%   - eccentricity.m one of the cell features
%   - cellsize.m one of the cell features
%   - cellsep.m to separate the connected cells
%   - cellcolor.m one of the cell features
% Inputs:
%   - fluoroimg: original JP2 image read into Matlab
%   - imagemask: binary mask of brain region, output of brainmaskfun_16bit.m or brainmaskfun_8bit.m
% Output:
%   - centroids: an N-by-2 matrix, recording the coordinates of the
%   centroids of the detected cells
%%
function centroids=FBdetection_consolid_v5(fluoroimg,imgmask)
% tic
global bitinfo sigma sizepar eccpar
%% 0. parameters
bitinfo=12;
sizepar=[20,5000];
eccpar=[.99,.95];
sigma=[20,1];
v=version('-release'); % check matlab version
v=str2double(v(1:4));
%% 1. Pre-processing
bwimg=preprocess(fluoroimg,imgmask);
if ~isempty(bwimg)
    %% 2. cell segmentation
    % 2.1 separate connected cells and single cells
    [bwimg_patch,gradimg,localmax]=cellpatch(bwimg);
    % 2.2 Separate individual cells in the connected patches
    if ~isempty(bwimg_patch{2}) % there exist connected cells
        bwimg_new=eccentricity(bwimg_patch{2},eccpar(1)); % filter shape
        bwimg_new=cellsize(bwimg_new); % filter size
        bwimg_new=cellsep(bwimg_new,gradimg,localmax);
    end
    % 2.3 combine all individual cells
    bwimg_new=bwimg_new+bwimg_patch{1}; % all individual cells now
    clear bwimg_patch
    %% 3. feature filters
    bwimg_filt=cellcolor(bwimg_new,fluoroimg); % check the color of cells
    bwimg_filt=cellsize(bwimg_filt); % filter for cell sizes
    bwimg_filt=eccentricity(bwimg_filt,eccpar(2)); % the cell need to be more round than linear
    % L=cellSNR(L,imgbit,bitinfo); % filter for SNR
    clear bwimg_new
    %% 4. detect centroids
    cc=bwconncomp(bwimg_filt);
    rprops = regionprops(cc,'centroid');
    centroids=reshape([rprops.Centroid],2,[])';
else
    centroids=[];
end