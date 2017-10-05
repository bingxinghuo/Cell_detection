n=2; 
N=2*2+1; % length of one side of the neighborhood
% trainN=[];
% groupN=[];
% for i=1:5 % go through all the training images
i=1;
% 1. pad the image with zeros
    [rows,cols,~]=size(trainimg{i});
    imgpad=[zeros(n,cols,3);trainimg{i};zeros(n,cols,3)]; % pad rows of zeros outside the image
    groupimg{i}=reshape(groupvectors{i},rows,cols);
    grouppad=[zeros(n,cols);groupimg{i};zeros(n,cols)];
    [rows1,cols1,~]=size(imgpad);
    imgpad=[zeros(rows1,n,3),imgpad,zeros(rows1,n,3)]; % pad columns of zeros outside the image
    grouppad=[zeros(rows1,n),grouppad,zeros(rows1,n)]; 
    % 2. associate a neighborhood of pixels with each pixel in the image
    trainensemimg=zeros(rows,cols,N^2,5);
    for i=n+1:n+rows
        for j=n+1:n+cols
            pixensemimg=imgpad(i-n:i+n,j-n:j+n,:);
            groupensemimg=grouppad(i-n:i+n,j-n:j+n);
            %
            pixensemv=reshape(pixensemimg,N^2,3); % rearrange into a 2-dimensional matrix
            pixensemangles=acos(pixensemv./(sqrt(sum(pixensemv.^2,2))*ones(1,3))); % 3 angles
            pixensemrad=sqrt(sum(pixensemv.^2,2)); % radius
            pixensemv=[pixensemangles,pixensemrad]; % transformed into N^2-by-4 matrix
            %
            groupensemv=reshape(groupensemimg,N^2,1);
            %
            trainensemimg(i-n,j-n,:,:)=[pixensemv,groupensemv]; % attach the group vector at the end of the feature vector
            trainensemv=reshape(trainensemimg,rows*cols,N^2,5);
        end
    end
    %%
    groupimg=reshape(groupvectors{i},rows,cols);
    N=min(rows,cols);
    for ni=1:N-n
        % calculate one neighborhood feature variables
        trainv=reshape(trainimg{i}(ni:ni+n-1,ni:ni+n-1,:),n^2,3);
        trainangles=acos(trainv./(sqrt(sum(trainv.^2,2))*ones(1,3)));
        trainint=sqrt(sum(trainv.^2,2));
        trainv=[trainangles,trainint];
        % find group vectors
        groupv=reshape(groupimg(ni:ni+n-1,ni:ni+n-1,:),n^2,1);
        % assemble training data
        trainN=[trainN;trainv];
        groupN=[groupN;groupv];
    end
% end
svmmodel1=fitcsvm(trainN,groupN);