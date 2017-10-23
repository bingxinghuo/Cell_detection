function svmcellblock_tester(fileid,n,svmmodel)
profile on
myfun = @(block_struct) svmcell(block_struct,n,svmmodel);
block_size=[512,512];
border_size=[n,n];
fileout='F120_cells.jp2';
blockproc(fileid,block_size,myfun,'BorderSize',border_size,...
    'PadMethod','replicate','Destination',fileout,'UseParallel',true);
profile off
end

function cellmask=svmcell(block_struct,n,svmmodel)
% assemble the feature vectors
nhoodimg=nhoodfeature(block_struct.data,n);
[rows,cols,features]=size(nhoodimg);
nhoodfeatures=reshape(nhoodimg,rows*cols,features);
cellscore=predict(svmmodel,nhoodfeatures);
cellmask=reshape(cellscore,rows,cols);
cellmask=uint8(cellmask);
end