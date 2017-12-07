%% svmcellblock.m
% Bingxing Huo @ 2017
% This function utilizes Matlab's built-in blocproc function for processing
% large images to read blocks of JP2 images, perform cell detection, and
% save directly into a new JP2 image containing the cell masks.
% Inputs:
%   - fluoroimg: the RGB image containing the fluorescent image, read from
%   JP2 file
%   - n: size of the neighborhood of each pixel
%   - svmmodel: pre-trained binary SVM classifier
%   - fileout: Optional. A string containing the JP2 or TIFF file name. 
% When there is no output, the function will directly save the results into
% this image file.
% Output:
%   - cellmask: Optional. A binary image containing the classified scores
%   of all pixels in the image. When no output file is specified, this is
%   required. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout=svmcellblock(varargin)
fluoroimg=varargin{1};
n=varargin{2};
svmmodel=varargin{3};
if nargout==0
    fileout=varargin{4};
end
% define block processing
myfun = @(block_struct) svmcell(block_struct,n,svmmodel);
block_size=[512,512];
border_size=[n*5,n*5];
if nargout==0 % directly save the results into an image file
    % blockproc(fluoroimg,block_size,myfun,'BorderSize',border_size,...
    %     'Destination',fileout,'UseParallel',true,'DisplayWaitbar',false);
    blockproc(fluoroimg,block_size,myfun,'BorderSize',border_size,...
        'UseParallel',true,'Destination',fileout);
elseif nargout==1 % save the file in workspace
    newimg=blockproc(fluoroimg,block_size,myfun,'BorderSize',border_size,...
        'UseParallel',true);
    varargout{1}=newimg;
end
end

function cellmask=svmcell(block_struct,n,svmmodel)
% assemble the feature vectors
nhoodimg=nhoodfeature(block_struct.data,n);
[rows,cols,features]=size(nhoodimg);
nhoodfeatures=reshape(nhoodimg,rows*cols,features);
% use the previously trained model to predict cell masks
cellscore=predict(svmmodel,nhoodfeatures);
% reorganize into the 2-D image
cellmask=reshape(cellscore,rows,cols);
cellmask=logical(cellmask);
end