%% svmcellmain.m
% Bingxing Huo @ 2017
% this is the main function for cell detection
% Inputs:
%   - filein: a string containing the fluorescent JP2 file name
%   - svmmodel: a pre-trained SVM binary classifier
%   - maskfile: a string containing the brain region mask mat file name
% Output:
%   - cellmask_origin: a binary image containing the detected cells (1) and
%   non-cells (0).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cellmask_origin=svmcellmain(filein,svmmodel,maskfile)
fluoroimg=imread(filein,'jp2');
sigma=[20,1];
% 1. mask
if exist(maskfile,'file')==2
    imgmask=load(maskfile);
    maskvar=fieldnames(imgmask);
    imgmask=getfield(imgmask,maskvar{1});
end
% 1.1 further erode the mask
se=strel('disk',10);
imgmask=imerode(imgmask,se);
% 1.2 crop image and apply the mask
[rgbimg,imgorigin,~]=maskadj_reg(fluoroimg,imgmask);
imgorigin=round(imgorigin);
% 2. preprocess
% 2.1 apply denoise filter
rgbdenoise=rmbg(rgbimg,sigma);
% 3. use SVM to predict cells
cellmask=svmcellblock(rgbdenoise,5,svmmodel);
% 4. post-process
% TBD
% 5. project back to the original image size
[rows,cols,~]=size(fluoroimg);
cellmask_origin=false(rows,cols);
cellmask_origin(imgorigin(1):imgorigin(3),imgorigin(2):imgorigin(4))=cellmask;
end
