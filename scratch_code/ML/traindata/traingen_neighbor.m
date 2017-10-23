n=10;
trainN=[];
groupN=[];
for i=1:5 % go through all the training images
    [rows,cols,~]=size(trainimg{i});
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
end
svmmodel1=fitcsvm(trainN,groupN);