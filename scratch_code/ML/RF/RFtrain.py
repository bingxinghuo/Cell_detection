import numpy as np
#import h5py
import cPickle
from sklearn.ensemble import RandomForestClassifier
for n in range(3,7):
    N=2*n+1
    filename=''.join(['trainensemdata_',str(N), '.csv'])
    train_data=open(filename,'rt')
    train_data=np.loadtxt(train_data,delimiter=",")
    train_data=np.nan_to_num(train_data)
    clf = RandomForestClassifier(n_estimators=20,n_jobs=4,class_weight='balanced',random_state=0)
    clf.fit(train_data[:,:pow(N,2)*4],train_data[:,-1])
    RFname=''.join(['RFclassfier_',str(N),'.pkl'])
    with open(RFname,'w') as fid:
        cPickle.dump(clf,fid)
    #groupdata=clf.predict(imgdata)
    #savefile=''.join(['testgroup', str(N), '.txt'])
#np.savetxt(savefile,groupdata,'%1i')


