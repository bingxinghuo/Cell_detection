import numpy as np
import h5py
import cPickle
#from scipy.io import loadmat
from sklearn.ensemble import RandomForestClassifier
    # only .mat files in the -7.3 format are accepted
import sys

n=int(sys.argv[1])
N=2*n+1
imgdata=h5py.File(''.join(['imgen',str(N),'.mat']))
imgdata=np.asarray(imgdata['ensemv'])
#mat_contents=loadmat('testgroup1.mat')
#mat_cells=mat_contents['envector']
imgdata=np.nan_to_num(imgdata.T)
#testimg=np.asarray(imgdata['testimg'])
#testimg=np.nan_to_num(testimg.T)

RFname=''.join(['RFclassfier_',str(N),'.pkl'])
with open(RFname,'r') as fid:
    clf=cPickle.load(fid)

groupdata=clf.predict(imgdata)
savefile=''.join(['samplegroup', str(N), '.txt'])
np.savetxt(savefile,groupdata,'%1i')


