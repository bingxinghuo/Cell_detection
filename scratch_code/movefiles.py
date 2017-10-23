import os
from os import listdir
from os.path import isfile
filepath=os.getcwd()+'/'
newpath=filepath+'tempfolder/'
# os.makedirs(newpath)
newlist=[]
matlist=[]
filelist=listdir(filepath)
for names in filelist:
    if names.endswith(".mat"):
        matlist.append(names)

for i in range(len(matlist)):
    if isfile(matlist[i].split('.')[0]+'-blue.jpg'):
        newlist.append(str(matlist[i]))

for names in newlist:
    os.rename(filepath+names.split('.')[0]+'-blue.jpg',newpath+names.split('.')[0]+'-blue.jpg')
    os.rename(filepath+names,newpath+names)