import numpy as np    

def histogram_matching(img, target):
    '''
    Input: img, and target are one channel of a image, size M*N, target size does not matter
    Output: one channel of matched image, same size with img
    '''
    imgx = img.shape[0]
    imgy = img.shape[1]
    img = img.flatten()
    target = target.flatten()
    
    img_value, img_bin, img_count = np.unique(img, return_inverse = True, return_counts = True)
    target_value, target_bin, target_count = np.unique(target, return_index = True, return_counts = True)
    #get cdf
    img_q = np.cumsum(img_count)
    img_q = np.asarray(img_q, 'float64') / img_q[-1]
    target_q = np.cumsum(target_count)
    target_q = np.asarray(target_q, 'float64') / target_q[-1]
    ret = np.interp(img_q, target_q, target_value)
    ret = ret[img_bin]
    return ret.reshape((imgx,imgy))