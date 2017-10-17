%% Incorporate neighborhood pixels into the feature space
nhoodimg=nhoodfeature(cellimg2.full,2);
[rows,cols,features]=size(nhoodimg);
trainN=reshape(nhoodimg,rows*cols,features);
groupN=reshape(cellimg2.bwcell,rows*cols,1);
%%
% svmmodel=fitclinear(trainN,groupN); % use linear classifier for high dimension feature space
svmmodel=fitclinear(trainN,groupN,'Solver','sparsa');
%% lost estimates
% 1. Using in-sample error estimate
L=loss(svmmodel,trainN,groupN)
% 2. Using cross validation
% https://www.mathworks.com/help/stats/classificationpartitionedlinear-class.html
CVmodel=fitclinear(trainN,groupN,'Solver','sparsa','CrossVal','on')
oofLabels = kfoldPredict(CVmodel);
ge = kfoldLoss(CVmodel)