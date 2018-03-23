tiflist=dir('*.tif');
for f=1:length(tiflist)
    DLGimg=imread(tiflist(f).name);
    DLGimg=uint8(DLGimg/15);
    DLGrgb=label2rgb(DLGimg,'jet','k');
    imwrite(DLGrgb,['../LGNregrgb/',tiflist(f).name],'tif')
end