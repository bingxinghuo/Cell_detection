import numpy as np
import h5py
import cPickle
#from scipy.io import loadmat
from sklearn.ensemble import RandomForestClassifier

imgdata=h5py.File('testgroup1.mat')
imgdata=np.asarray(imgdata['envector11'])
#mat_contents=loadmat('testgroup1.mat')
#mat_cells=mat_contents['envector']
imgdata=np.nan_to_num(imgdata.T)
#testimg=np.asarray(imgdata['testimg'])
#testimg=np.nan_to_num(testimg.T)

n=5
N=2*n+1
RFname=''.join(['RFclassfier_',str(N),'.pkl'])
with open(RFname,'rb') as fid:
    clf=cPickle.load(fid)

groupdata=clf.predict(imgdata)
savefile=''.join(['groupdata', str(N), '.txt'])
np.savetxt(savefile,groupdata,'%1i')


