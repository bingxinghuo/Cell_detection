import numpy as np, h5py
#read the list of file names
with open('filenames.txt') as f:
    filelist=f.readlines()
#adjust the file names
filelist=[x.rstrip('.jp2\n') for x in filelist]
filelist=[x + '_fluoroonly.mat' for x in filelist]
savelist=[x + '_fluoroonly.jp2' for x in filelist]
#run through each file
#for x in range(1,len(filelist)):
for x in [1,2]
data=h5py.File(filelist[x])
imgdata=np.asarray(data['savedata'])
imgdata=imgdata.T
imgdata[:,:,[0,1,2]]=imgdata[:,:,[2,1,0]]
cv2.imwrite(savelist[x],imgdata)