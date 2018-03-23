%%  All the materials available in this document is to reproduce the results published in the following paper:
% 
%   S. Chatterjee, A. M. Javid, M. Sadeghi, P. P. Mitra, M. Skoglund, 
%   "Progressive Learning for Systematic Design of Large Neural Network",
%   2017
% 
%%  The codes is organized as follows:
% 
%   LS_Performance.m is used to acheive the performance results of 
%   least-square shown in Table III and Table V in Section IV
% 
%               LS_Performance.m        ->      Table III and V    
% 
%   ELM_Performance.m is used to acheive the performance results of ELM
%   shown in Table III and Table V in Section IV
% 
%               ELM_Performance.m       ->      Table III and V    
% 
%   PLN_Performance.m is used to acheive the performance results of PLN
%   shown in Table III, Table V, and Table VII in Section IV
% 
%               PLN_Performance.m       ->      Table III, V, and VII    
% 
%   PLN_Behavior.m is used to generate the results shown in Fig. 4 in
%   Section IV
% 
%               PLN_Behavior.m          ->      Fig. 4
%   
%   
%   The files available in the "Functions" folder are as follows:
% 
%   Calculate_accuracy  :   Function for calculating accuracy for a given estimation of target 
%                              
%   Calculate_error     :   Function for calculating NME for a given estimation of target
%                           
%   Load_dataset        :   Function for loading the dataset listed in Table I and Table II
%                           
%   LS_ADMM             :   Function for solving constrained least-square problem 
% 
%   PLN                 :   Function for simulating Progressive Learning Network
% 
%   LS:                 :   Function for simulating Regularized Least-square
% 
%   ELM:                :   Function for simulating Extreme Learning Machine

%%  Notes:
%   
%   In "Datasets" folder, you find the used datasets in our experiments. This
%   folder must be placed in the same directory as the codes.
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%   Author:     Alireza M. Javid, September 2017 
%   Contact:    almj@kth.se
% 
