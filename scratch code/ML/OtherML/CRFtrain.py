import numpy as np
#import h5py
import cPickle
from pystruct.models import GraphCRF
from pystruct.learners import FrankWolfeSSVM
import cvxopt

for n in range(3,6):
    #for n in range(3,4):
    N=2*n+1
    filename=''.join(['trainensemdata_',str(N), '.csv'])
    train_data=open(filename,'rt')
    train_data=np.loadtxt(train_data,delimiter=",")
    train_data=np.nan_to_num(train_data)
    train_data1=[train_data[:,:-1]]
    X_train=[(features_i, np.vstack([np.arange(features_i.shape[0] - 1), np.arange(1, features_i.shape[0])])) for features_i in train_data1]
    y_train=train_data[:,-1].astype(int)
    y_train=[y_train]
    model=GraphCRF(directed=False, inference_method="max-product")
    ssvm=FrankWolfeSSVM(model=model)
    ssvm.fit(X_train,y_train)
    CRFname=''.join(['CRFclassfier_',str(N),'.pkl'])
    with open(CRFname,'wb') as fid:
        cPickle.dump(ssvm,fid)
    #groupdata=clf.predict(imgdata)
    #savefile=''.join(['testgroup', str(N), '.txt'])
#np.savetxt(savefile,groupdata,'%1i')


