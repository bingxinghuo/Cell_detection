%% svmcellblock.m
% This function utilizes Matlab's built-in blocproc function for processing
% large images to read blocks of JP2 images, perform cell detection, and
% save directly into a new JP2 image containing the cell masks.

% function svmcellblock(fluoroimg,n,svmmodel,fileout)
% function newimg=svmcellblock(fluoroimg,n,svmmodel)
function varargout=svmcellblock(varargin)
fluoroimg=varargin{1};
n=varargin{2};
svmmodel=varargin{3};
if nargout==0
    fileout=varargin{4};
end

myfun = @(block_struct) svmcell(block_struct,n,svmmodel);
block_size=[512,512];
border_size=[n*5,n*5];
if nargout==0
    % blockproc(fluoroimg,block_size,myfun,'BorderSize',border_size,...
    %     'Destination',fileout,'UseParallel',true,'DisplayWaitbar',false);
    blockproc(fluoroimg,block_size,myfun,'BorderSize',border_size,...
        'Destination',fileout,'UseParallel',true);
elseif nargout==1
    newimg=blockproc(fluoroimg,block_size,myfun,'BorderSize',border_size);
    varargout{1}=newimg;
end
end

function cellmask=svmcell(block_struct,n,svmmodel)
% to speed up the process, use a hard threshold as criteria
if sum(sum(block_struct.data(:,:,3)>50))>100
    % assemble the feature vectors
    nhoodimg=nhoodfeature(block_struct.data,n);
    [rows,cols,features]=size(nhoodimg);
    nhoodfeatures=reshape(nhoodimg,rows*cols,features);
    % use the previously trained model to predict cell masks
    cellscore=predict(svmmodel,nhoodfeatures);
    cellmask=reshape(cellscore,rows,cols);
    %     cellmask=uint16(cellmask*2^16);
    cellmask=logical(cellmask);
else
    [rows,cols,~]=size(block_struct.data);
    %     cellmask=uint16(zeros(rows,cols));
    cellmask=false(rows,cols);
end
% channelpad=uint16(zeros(rows,cols));
% cellmask=cat(3,channelpad,channelpad,cellmask);
end