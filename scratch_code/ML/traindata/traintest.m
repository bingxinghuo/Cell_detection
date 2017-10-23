load('traindata.mat')
%
Ntot=length(groupvector); % total number of training data available
rng=1;
restind=randperm(Ntot,ceil(Ntot*.4)); % leave 40% of the training data for cross validation and testing
cvind_sub=randperm(length(restind),ceil(Ntot*.2)); % leave a half of the test data for CV
cvind=restind(cvind_sub); % get the index of CV data in the training dataset
testind=restind(~ismember(restind,cvind)); % get the index of test data in the training set
trainsetind=find(~ismember(1:Ntot,restind)); % get the index of training data pool
% get the CV data and test data
traindata=cell(3,1);
traindata{2}=trainvector(cvind,:);
traindata{3}=trainvector(testind,:);
groupdata=cell(3,1);
groupdata{2}=groupvector(cvind);
groupdata{3}=groupvector(testind);
%
dNn=50;
dN=linspace(ceil(Ntot*.2),length(trainsetind),dNn);
dN=round(dN);
% Jtrain=zeros(dNn,1);
% Jcv=zeros(dNn,1);
Ftrain=zeros(dNn,3);
Fcv=zeros(dNn,3);
%%
for i=1:dNn
    % take only a portion of the training dataset
    trainind=randperm(length(trainsetind),dN(i));
    trainind=trainsetind(trainind);
    traindata{1}{i}=trainvector(trainind,:);
    groupdata{1}{i}=groupvector(trainind);
%     svmmodel=fitcsvm(traindata{1}{i},groupdata{1}{i});
    svmmodel=fitcsvm(traindata{1}{i},groupdata{1}{i},'Standardize',true,'KernelFunction','RBF','KernelScale','auto');
    trainest=predict(svmmodel,traindata{1}{i});
%     Jtrain(i)=1/(2*length(trainest))*sum((groupdata{1}{i}-trainest).^2);
    [Ftrain(i,1),Ftrain(i,2),Ftrain(i,3)]=fscore(groupdata{1}{i},trainest);
    cvpredict=predict(svmmodel,traindata{2});
%     Jcv(i)=1/(2*length(cvpredict))*sum((groupdata{2}-cvpredict).^2);
    [Fcv(i,1),Fcv(i,2),Fcv(i,3)]=fscore(groupdata{2},cvpredict);
end
% save('traintestdata','dN','Jtrain','Jcv','Ftrain','Fcv','traindata','groupdata')
save('traintestdata_RBF','dN','Ftrain','Fcv','traindata','groupdata')