%% nhoodfeature.m
% This function takes the image with all its features in the third
% dimension, and extract all features within a N-neighborhood to form a new
% feature spacing containing all the neighborhood features
%%
function nhoodimg=nhoodfeature(featureimg,n)
% n=2;
N=n*2+1; % length of one side of the neighborhood
[rows,cols,features]=size(featureimg);
imgpad=[zeros(n,cols,features);featureimg;zeros(n,cols,features)]; % pad rows of zeros outside the image
[rows1,cols1,~]=size(imgpad);
imgpad=[zeros(rows1,n,3),imgpad,zeros(rows1,n,3)]; % pad columns of zeros outside the image
% 2. associate a neighborhood of pixels with each pixel in the image
nhoodimg=zeros(rows,cols,N^2*features);
for i=n+1:n+rows
    for j=n+1:n+cols
        pixensemimg=imgpad(i-n:i+n,j-n:j+n,:);
        %
        pixensemv=reshape(pixensemimg,1,N^2*features); % rearrange into a 2-dimensional matrix
        nhoodimg(i-n,j-n,:)=pixensemv; % attach the group vector at the end of the feature vector
    end
end