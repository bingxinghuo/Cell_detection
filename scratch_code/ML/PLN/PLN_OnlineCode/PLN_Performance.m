%%  Name:   PLN_Performance
%
%   Generating the performance results of PLN shown in Table III, Table V
%
%   Data:   Simulated data set generated from datasets mentioned in the paper
%
%   Output: Mean and standard deviation of NME and accuracy over multiple
%           trials of PLN for classification and regression datasets, as
%           well as the running time of the PLN        
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   
%   Paper:          Progressive Learning for Systematic Design of Large Neural Network
%   Authors:        Saikat Chatterjee, Alireza M. Javid, Mostafa Sadeghi, Partha P. Mitra, Mikael Skoglund 
%   Organiztion:    KTH Royal Institute of Technology
%   Contact:        Alireza M. Javid, almj@kth.se
%   Website:        www.ee.kth.se/reproducible/
% 
%   ***September 2017***


%% begining of the simulation
% 
% clc; clear variables; clear global; close all;
% 
% addpath(genpath('Datasets'));
% addpath(genpath('Functions'));

a_leaky_RLU=0;      %   set to a small non-zero value if you want to test leaky-RLU
g=@(x) x.*(x >= 0)+a_leaky_RLU*x.*(x < 0);

%%  Choosing a dataset
% Choose one of the following datasets:

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % %         Classification        % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 

Database_name='marmosetcells';            lam=1e4;	mu=1e1;     kmax=100;   alpha=2;    nmax=3000;    eta_n=0.005;   eta_l=0.001;     lmax=100;   Delta=50;
% Database_name='Vowel';            lam=1e2;	mu=1e3;     kmax=100;   alpha=2;    nmax=1000;    eta_n=0.005;   eta_l=0.1;     lmax=100;   Delta=50;
% Database_name='ExtendedYaleB';    lam=1e4;	mu=1e3;     kmax=100;  	alpha=2;	nmax=1000;    eta_n=0.005;	 eta_l=0.1;     lmax=100;	Delta=50;
% Database_name='AR';               lam=1e5;	mu=1e1;     kmax=100;  	alpha=2;	nmax=1000;    eta_n=0.005; 	 eta_l=0.1;     lmax=100;	Delta=50;
% Database_name='Satimage';         lam=1e6;	mu=1e5;     kmax=100;  	alpha=2;	nmax=1000;    eta_n=0.005; 	 eta_l=0.1;     lmax=100;	Delta=50;
% Database_name='Scene15';          lam=1e-3;	mu=1e1;     kmax=100;  	alpha=2;	nmax=1000;    eta_n=0.005; 	 eta_l=0.1;     lmax=100;	Delta=50;
% Database_name='Caltech101';       lam=5;      mu=1e-2;    kmax=100;   alpha=2;	nmax=1000;    eta_n=0.005; 	 eta_l=0.1;     lmax=100;	Delta=50;
% Database_name='Letter';           lam=1e-5;	mu=1e4;     kmax=100;  	alpha=2;	nmax=1000;    eta_n=0.005; 	 eta_l=0.1;     lmax=100;	Delta=50;
% Database_name='NORB';             lam=1e2;	mu=1e2;     kmax=100;  	alpha=2;	nmax=1000;    eta_n=0.005; 	 eta_l=0.1;     lmax=100;	Delta=50;
% Database_name='Shuttle';          lam=1e5;	mu=1e4;     kmax=100;  	alpha=2;	nmax=1000;    eta_n=0.005; 	 eta_l=0.1;     lmax=100;	Delta=50;
% Database_name='MNIST';            lam=1e0;	mu=1e5;     kmax=100;  	alpha=2;	nmax=1000;    eta_n=0.005; 	 eta_l=0.1;     lmax=100;	Delta=50;

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % %           Regression          % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 

% Database_name='Pyrim';            lam=1e0;	mu=1e-1;    kmax=100;   alpha=1;    nmax=100;     eta_n=0.001;   eta_l=0.01;     lmax=100;  Delta=10;
% Database_name='Bodyfat';          lam=1e-1;	mu=1e0;     kmax=100;   alpha=1;    nmax=100;     eta_n=0.001;   eta_l=0.01;     lmax=100;  Delta=10;
% Database_name='Housing';          lam=1e2;	mu=1e0;     kmax=100;   alpha=1;    nmax=100;     eta_n=0.001;   eta_l=0.01;     lmax=100;  Delta=10;
% Database_name='Strike';           lam=1e1;	mu=1e3;     kmax=100;   alpha=1;    nmax=100;     eta_n=0.001;   eta_l=0.01;     lmax=100;  Delta=10;
% Database_name='Balloon';          lam=1e-2;	mu=1e2;     kmax=100;   alpha=1;    nmax=100;     eta_n=0.001;   eta_l=0.01;     lmax=100;  Delta=10;
% Database_name='Space_ga';         lam=1e9;	mu=1e4;     kmax=100;   alpha=1;    nmax=100;     eta_n=0.001;   eta_l=0.01;     lmax=100;  Delta=10;
% Database_name='Abalone';          lam=1e-1;	mu=1e5;     kmax=100;   alpha=1;    nmax=100;     eta_n=0.001;   eta_l=0.01;     lmax=100;  Delta=10;
% Database_name='Parkinsons';       lam=1e-8;	mu=1e7;     kmax=100;   alpha=1;    nmax=100;     eta_n=0.001;   eta_l=0.01;     lmax=100;  Delta=10;

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%

%   Loading the dataset
[X_train,T_train,X_test,T_test]=Load_dataset(Database_name);

Q=size(T_train,1);  %   Target Dimension

trialNum=1;

% The perfomance measures we are interested in
train_error_PLN=zeros(1,trialNum);
test_error_PLN=zeros(1,trialNum);
accuracy_PLN=zeros(1,trialNum);
time_PLN=zeros(1,trialNum);

%   Generating the set of nodes in each layer
NumNodes_min=2*Q;
NumNodes_max=2*Q+nmax;
temp=NumNodes_min:Delta:NumNodes_max;
ind=ones(lmax,1);
NumNodes=temp(ind,:);

eps_o=alpha*sqrt(2*Q);  %   the regularization constant
First_Block='LS';

% Finding the optimum number of random nodes in each layer
[train_error, test_error, train_accuracy, test_accuracy, Total_NN_size, NumNodes_opt,~]=PLN(X_train, T_train,...
    X_test, T_test, g, NumNodes, eps_o, mu, kmax, lam, eta_n, eta_l, First_Block);

% Running the network with the optimum number nodes in each layer derived above
for i=1:trialNum
    
    %   Loading the dataset each time to reduce the effect of random partitioning in some of the datasets
    [X_train,T_train,X_test,T_test]=Load_dataset(Database_name);
    
    tic;
    [train_error,test_error,train_accuracy,test_accuracy,Total_NN_size,~,T_hat_test]=PLN(X_train, T_train,...
        X_test,T_test, g, NumNodes_opt', eps_o, mu, kmax, lam, eta_n, eta_l, First_Block);
    PLN_time=toc;
    
    train_error_PLN(i)=train_error(end);
    test_error_PLN(i)=test_error(end);
    accuracy_PLN(i)=test_accuracy(end);
    time_PLN(i)=PLN_time;
    
end

% Calculating the average and standard deviation over multiple trials
mean_train_error=mean(train_error_PLN);
mean_test_error=mean(test_error_PLN);
mean_accuracy=mean(accuracy_PLN);
mean_time=mean(time_PLN);

std_train_e=std(train_error_PLN);
std_test_e=std(test_error_PLN);
std_accuracy=std(accuracy_PLN);

% Displaying the results of PLN
disp(['Performance results of "',Database_name,'" dataset:'])

disp(['Train NME = ',num2str(mean_train_error),'+',num2str(std_train_e),...
    ', Test NME = ',num2str(mean_test_error),'+',num2str(std_test_e),...
    ', Test accuracy = ',num2str(100*mean_accuracy),'+',num2str(100*std_accuracy),...
    ', Running Time = ',num2str(mean_time)])
%%
[~,group_est]=max(T_hat_test);
group_est=group_est==1;
[f1,p,r]=fscore(labelMat(1,3301:end),group_est(1,:))