function [f1,p,r]=fscore(ytrue,yest)
dtrain=ytrue-yest;
TP=sum((dtrain==0).*(ytrue==1));
FP=sum((dtrain==-1).*(ytrue==0));
FN=sum((dtrain==1).*(ytrue==1));
p=TP/(TP+FP);
r=TP/(TP+FN);
f1=2*(p*r/(p+r));