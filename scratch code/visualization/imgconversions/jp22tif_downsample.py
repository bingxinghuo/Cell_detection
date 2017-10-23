from skimage.util import view_as_blocks
import numpy as np
def Down_Sample(image, block_size, func=np.sum, cval=0):
    
    if len(block_size) != image.ndim:
        raise ValueError("`block_size` must have the same length "
                         "as `image.shape`.")
    
    pad_width = []
    for i in range(len(block_size)):
        if block_size[i] < 1:
            raise ValueError("Down-sampling factors must be >= 1. Use "
                             "`skimage.transform.resize` to up-sample an "
                             "image.")
        if image.shape[i] % block_size[i] != 0:
            after_width = block_size[i] - (image.shape[i] % block_size[i])
        else:
            after_width = 0
        pad_width.append((0, after_width))
    
    image = np.pad(image, pad_width=pad_width, mode='constant',
                   constant_values=cval)

    out = view_as_blocks(image, block_size)
    
    for i in range(len(out.shape) // 2):
        out = func(out, axis=-1)
    
    return out

def FileProcess(filename):
    
    print('processing '+filename)
    img=cv2.imread(filename)
    img=img[:,:,1] #take only blue channel

    for i in range(0,5):
        img = scipy.signal.medfilt(img,kernel_size=5)
        img=Down_Sample(img,block_size=(2,2),func=np.sum)
    
    img=img*255 #make sure the graph is binary(0 or 255)
    img=img.npastype(np.uint8)
    binimg=cv2.merge(img,img,img)
    cv2.imwrite(filename.split('.')[0]+'.tif',img)
    
    print('finish '+filename)


if __name__ == "__main__":
    filepath='cellmasks/8bitRGB'
    filelist = [filepath + f for f in listdir(filepath) if isfile(join(filepath, f))]
    
    p=Pool(8)
    p.map(FileProcess,tuple(filelist))