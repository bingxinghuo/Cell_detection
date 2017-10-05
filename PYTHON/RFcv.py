import numpy as np
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split


def Jerr(ytrue,yest):
    m=len(ytrue)
    return sum(pow(yest-ytrue,2))/(2*m)

def fscore(ytrue,yest):
    dtrain=ytrue-yest
    TP=float(sum((dtrain==0)*(ytrue==1)))
    FP=float(sum((dtrain==-1)*(ytrue==0)))
    FN=float(sum((dtrain==1)*(ytrue==1)))
    p=TP/(TP+FP)
    r=TP/(TP+FN)
    f1=2*(p*r/(p+r))
    return f1, p, r


#for n in range(3,7):
n=3
N=2*n+1
filename=''.join(['trainensemdata_',str(N), '.csv'])
cv_data=open(filename,'rt')
cv_data=np.loadtxt(cv_data,delimiter=",")
cv_data=np.nan_to_num(cv_data)
cv_X=cv_data[:,:pow(N,2)*4]
cv_y=cv_data[:,-1]

X_train0, X_test, y_train0, y_test = train_test_split(cv_X,cv_y,test_size=.2,random_state=0)
#Jtrain=np.zeros(50)
#Jcv=np.zeros(50)
Ftrain=np.zeros((50,3))
Fcv=np.zeros((50,3))
i=0

for trainperc in np.linspace(.2,.6,50):
    X_train, X_test0, y_train, y_test0 = train_test_split(cv_X,cv_y,test_size=trainperc,random_state=0)
    clf = RandomForestClassifier(n_estimators=20,n_jobs=4,class_weight='balanced')
    clf.fit(X_train,y_train)
#CVscore[n]=clf.score(X_test,y_test)
    trainest=clf.predict(X_train)
    cvpredict=clf.predict(X_test)
#Jtrain[i]=Jerr(y_train,trainest)
#Jcv[i]=Jerr(y_test,cvpredict)
    Ftrain[i,0], Ftrain[i,1], Ftrain[i,2] = fscore(y_train, trainest)
    Fcv[i,0], Fcv[i,1], Fcv[i,2] = fscore(y_test,cvpredict)
    i+=1

#savefile='Jtrain.txt'
#np.savetxt(savefile,Jtrain)
#savefile='Jcv.txt'
#np.savetxt(savefile,Jcv)

savefile=''.join(['Ftrain_',str(N),'.txt'])
np.savetxt(savefile,Ftrain)
savefile=''.join(['Fcv_',str(N),'.txt'])
np.savetxt(savefile,Fcv)






