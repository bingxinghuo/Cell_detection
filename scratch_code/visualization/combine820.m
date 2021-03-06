fid=fopen('filenames.txt');
filelist=textscan(fid,'%q');
fclose(fid);
filelist=filelist{1};
Nfiles=length(filelist);
%%
for f=1:Nfiles
    fileid=filelist{f};
    outlinefile=['jpg-outlines/M820_outline_',num2str(f),'-outline.jpg'];
    %     bluefile=['Blue_channel/',fileid(1:end-4),'_fluoroonly-Blue.jpg'];
    greenfile=['Green_channel/',fileid(1:end-4),'_fluoroonly-Green.jpg'];
    outimg=imread(outlinefile);
    outimg=uint8(outimg/10);
    %     blueimg=imread(bluefile);
    greenimg=imread(greenfile);
    %     combimg=cat(3,outimg,outimg+greenimg,outimg+blueimg);
    %     combimg=cat(3,outimg,outimg,outimg+blueimg);
    combimg=cat(3,outimg,outimg+greenimg,outimg);
    %     combfile=['~/Desktop/m820BG/GBimg_',num2str(f),'.tif'];
    %     combfile=['~/Desktop/m820img/Blue/tiffs/Bimg_',num2str(f),'.tif'];
    combfile=['~/Desktop/m820img/Green/tiffs/Gimg_',num2str(f),'.tif'];
    imwrite(combimg,combfile,'tif','compression','lzw','writemode','overwrite')
end
%%