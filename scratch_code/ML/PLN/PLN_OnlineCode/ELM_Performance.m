%%  Name:   ELM_Performance
%
%   Generating the performance results of ELM shown in Table III, Table V
%
%   Data:   Simulated data set generated from datasets mentioned in the paper
%
%   Output: Mean and standard deviation of NME and accuracy over multiple
%           trials of ELM for classification and regression datasets, as
%           well as the running time of the ELM
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

clc; clear variables; clear global; close all;

addpath(genpath('Datasets'));
addpath(genpath('Functions'));

a_leaky_RLU=0;      %   set to a small non-zero value if you want to test leaky-RLU
g=@(x) x.*(x >= 0)+a_leaky_RLU*x.*(x < 0);

%%  Choosing a dataset
% Choose one of the following datasets:

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % %         Classification        % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

Database_name='Vowel';            lam=1e2;       ELM_Nodes=2000;
% Database_name='ExtendedYaleB';    lam=1e7;       ELM_Nodes=3000;
% Database_name='AR';               lam=1e7;       ELM_Nodes=3000;
% Database_name='Satimage';         lam=1e2;       ELM_Nodes=2500;
% Database_name='Scene15';          lam=1e0;       ELM_Nodes=4000;
% Database_name='Caltech101';       lam=1e2;       ELM_Nodes=4000;
% Database_name='Letter';           lam=1e1;       ELM_Nodes=6000;
% Database_name='NORB';             lam=1e3;       ELM_Nodes=4000;
% Database_name='Shuttle';          lam=1e2;       ELM_Nodes=1000;
% Database_name='MNIST';            lam=1e-1;      ELM_Nodes=4000;

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % %           Regression          % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

% Database_name='Pyrim';            lam=1e1;      ELM_Nodes=100;
% Database_name='Bodyfat';          lam=1e2;      ELM_Nodes=50;
% Database_name='Housing';          lam=1e3;      ELM_Nodes=200;
% Database_name='Strike';           lam=1e3;      ELM_Nodes=300;
% Database_name='Balloon';          lam=1e0;      ELM_Nodes=400;
% Database_name='Space_ga';         lam=1e10;     ELM_Nodes=200;
% Database_name='Abalone';          lam=1e-1;     ELM_Nodes=100;
% Database_name='Parkinsons';       lam=1e-1;     ELM_Nodes=100;

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%   Loading the dataset
[X_train,T_train,X_test,T_test]=Load_dataset(Database_name);

trialNum=50;

% The perfomance measures we are interested in
train_error_ELM=zeros(1,trialNum);
test_error_ELM=zeros(1,trialNum);
accuracy_ELM=zeros(1,trialNum);
time_ELM=zeros(1,trialNum);

% Running the network
for i=1:trialNum

    %   Loading the dataset each time to reduce the effect of random partitioning in some of the datasets
    [X_train,T_train,X_test,T_test]=Load_dataset(Database_name);
    
    tic
    [test_accuracy, ~, train_T_hat, test_T_hat]=ELM(X_train, T_train, X_test, T_test, lam, ELM_Nodes,g);
    ELM_time=toc;
    
    train_error=Calculate_error(T_train,train_T_hat);
    test_error=Calculate_error(T_test,test_T_hat);
    
    train_error_ELM(i)=train_error;
    test_error_ELM(i)=test_error;
    accuracy_ELM(i)=test_accuracy;
    time_ELM(i)=ELM_time;
    
end

% Calculating the average and standard deviation over multiple trials
mean_train_error=mean(train_error_ELM);
mean_test_error=mean(test_error_ELM);
mean_accuracy=mean(accuracy_ELM);
mean_time=mean(time_ELM);

std_train_e=std(train_error_ELM);
std_test_e=std(test_error_ELM);
std_accuracy=std(accuracy_ELM);

% Displaying the results of ELM
disp(['Performance results of "',Database_name,'" dataset:'])

disp(['Train NME = ',num2str(mean_train_error),'+',num2str(std_train_e),...
    ', Test NME = ',num2str(mean_test_error),'+',num2str(std_test_e),...
    ', Test accuracy = ',num2str(100*mean_accuracy),'+',num2str(100*std_accuracy),...
    ', Running Time = ',num2str(mean_time)])
