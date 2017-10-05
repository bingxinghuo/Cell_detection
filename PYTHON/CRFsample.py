import numpy as np
import h5py
import cPickle
#from scipy.io import loadmat
#from sklearn.ensemble import RandomForestClassifier
    # only .mat files in the -7.3 format are accepted

imgdata=h5py.File('testgroup1.mat')
imgdata=np.asarray(imgdata['envector7'])
#mat_contents=loadmat('testgroup1.mat')
#mat_cells=mat_contents['envector']
imgdata=np.nan_to_num(imgdata.T)
#testimg=np.asarray(imgdata['testimg'])
#testimg=np.nan_to_num(testimg.T)
imgdata1=[imgdata]
X_test=[(features_i, np.vstack([np.arange(features_i.shape[0] - 1), np.arange(1, features_i.shape[0])])) for features_i in imgdata1]
#X_test1=[X_test]

n=3
N=2*n+1
CRFname=''.join(['CRFclassfier_',str(N),'.pkl'])
with open(CRFname,'rb') as fid:
    ssvm=cPickle.load(fid)

groupdata=ssvm.predict(X_test)
savefile=''.join(['samplegroup', str(N), '.txt'])
np.savetxt(savefile,groupdata,'%1i')


