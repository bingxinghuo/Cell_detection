%% Generate training data
function [trainvector,groupvector,svmstruct]=traingen(img_nobak,xrange,yrange)
% 1. specify a small range
% xrange=[1030,1050];
% yrange=[1000,1020];
% 2. extract the image
trainimg=img_nobak(xrange(1):xrange(2),yrange(1):yrange(2),:);
[rows,cols,~]=size(trainimg);
% 3. manually classify the image by selecting the pixels
% Use a polygon contour tool
cellmask=trainROI(trainimg);
% 4. Assemble the training data
trainimgv=reshape(trainimg,rows*cols,3,1);
trainimgv=trainimgv.*(trainimgv>=0); % remove negative values
% calculate the angles in each direction in the 3D space
trainangles=acos(trainimgv./(sqrt(sum(trainimgv.^2,2))*ones(1,3)));
% intensity values
trainint=sqrt(sum(trainimgv.^2,2));
% training data
trainvector=[trainangles,trainint];
% 5. Group data
groupvector=reshape(cellmask.ROImap,rows*cols,1);
% 6 (optional). train the linear SVM classifier
svmstruct=svmtrain(trainvector,groupvector);
% svmstruct=fitcsvm(trainvector,groupvector);