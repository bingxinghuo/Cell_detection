%% This script describes the workflow of applying some classifier to image with contextual information of different sizes
%% 1. generate training data
% Variables:
%       trainimg: contains the individual images. This can be customized.
%       groupimg: contains the groundtruth information of the trainimg
%       classifications. It does not change.
%       imginfo: contains the 'source' of individual training images, and
%       their coordinates in the original source image. 
traingen_img.m
% Save the training data in a .mat file, e.g. 'traindata.mat'
save('traindata.mat','trainimg','groupimg','imginfo')
%% 2. generate feature vectors for each training dataset
traingen_neighborRF.m
%% 3. evaluate the quality of the classifier
status=system('python ../../python_code/plot_roc_cv_RF.py');
% there will be a figure output comparing the classifier quality between
% different sizes of neighborhood. The evaluation method is ROC AUC.
% Based on this result, we may choose only one classifier to train. 
%% 4. train classifiers using all the training data
status=system('python ../../python_code/RFtrain.py');
%% 5. apply the classifiers to the sample images and save the results
FBdetection_RFsample.m
% optionally, there can be figure output for visualization in this code.