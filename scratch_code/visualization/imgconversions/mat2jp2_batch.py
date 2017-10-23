import numpy as np, h5py, cv2
from multiprocessing import Pool

def filenamegen(n):
    
    #read the list of file names
    with open('../../filenames.txt') as f:
        filelist=f.readlines()
        
    #adjust the file names
    filelist=[x.rstrip('.jp2\n') for x in filelist]
    filename=filelist[n-1]

    return filename


def Convertjp2(maskname):
    
    f=int(maskname[9:-4])
    filename=filenamegen(f)
#run through each file
    print('processing '+filename)
#for x in range(1,len(filelist)):
#for x in [263]:
    data=h5py.File(maskname)
    imgdata=np.asarray(data['savedata'],dtype=np.uint16)
    imgdata=imgdata.T*(pow(2,16)-1)
    imgdim=np.shape(imgdata)
    channelpad=np.zeros(imgdim,dtype=np.uint16)
    #    imgdata[:,:,[0,1,2]]=imgdata[:,:,[2,1,0]]
    imgrgb=cv2.merge([imgdata,channelpad,channelpad])
    savename=''.join([filename, '_cells16rgbnew.jp2'])
    cv2.imwrite(savename,imgrgb)

    print('finish '+filename)

if __name__ == "__main__":
    #read the list of file names
    #with open('../../filenames.txt') as f:
    #    filelist=f.readlines()
    #masklist=['cellmask_' + str(x) + '.mat' for x in range(1,len(filelist))]
    masklist=['cellmask_264.mat']

    p=Pool(8)
    p.map(Convertjp2,tuple(masklist))