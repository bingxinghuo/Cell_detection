% load the jp2 image into matlab
% imgfile='M819-N102--_3_0306';
fluoroimg=imread(imgfile,'jp2');
%% 1. Preprocessing
% for sample coding, manually reduce the ROI to make the image manageable
ROIx=[7500:10000]; % region of interested allocated to the retrograde labeled neuron area
ROIy=[4000:6000];
retroimg=fluoroimg(ROIx,ROIy,:); % maintain three channels of RGB
% FB is mainly in the blue channel; some in green channel as well. Will
% discuss later ********
retroB=double(squeeze(retroimg(:,:,3)));
% denoise using singular value decomposition
[retroB_SVD.U,retroB_SVD.S,retroB_SVD.V]=svd(retroB,0);
% remove the first two modes for denoise
retroB_denoise=retroB_SVD.U(:,3:end)*retroB_SVD.S(3:end,3:end)*retroB_SVD.V(:,3:end)';
%% 2. Cell seperation
% convert to HSV
% reconstruct a RGB map
retroB_denoiseM=zeros(size(retroB_denoise,1),size(retroB_denoise,2),3);
retroB_denoiseM(:,:,3)=retroB_denoise;
% retroB_hsv=rgb2hsv(retroB_denoiseM);
retroB_mask=retroB_denoise>100;
retroB_neuron.img=retroB_denoise.*retroB_mask;
y1 = 2*retroB_neuron.img - imdilate(retroB_neuron.img, strel('square',7));
y1(y1<0) = 0;
y1(y1>1) = 1;
y2 = imdilate(y1, strel('square',7)) - y1;
th = multithresh(y2);
%%
hblob = vision.BlobAnalysis('AreaOutputPort', false, 'BoundingBoxOutputPort', false, 'OutputDataType', 'single', ...
'MinimumBlobArea', 15, 'MaximumBlobArea', 1000, 'MaximumCount', 1500);
y3 = (y2 <= th*0.7);       % Binarize the image.
Centroid = step(hblob, y3);   % Calculate the centroid
numBlobs = size(Centroid,1);
% image_out = insertMarker(retroB_neuron.img, Centroid, '*', 'Color', 'red');