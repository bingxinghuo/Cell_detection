fid=fopen('filenames.txt');
filelist=textscan(fid,'%q');
fclose(fid);
filelist=filelist{1};
Nfiles=length(filelist);
%%
outstack=['outline_stack.tif'];
bluestack=['blue_stack.tif'];
greenstack=['green_stack.tif'];

for f=1:Nfiles
    fileid=filelist{f};
        outlinefile=['jpg-outlines/outline_',num2str(f),'-outline.jpg']; % m820 convention
%     outlinefile=['outlines/jpg-outline/outline_',num2str(f),'.jpg']; % m919 convention
    outimg=imread(outlinefile);
    %
        bluefile=['Blue_channel/',fileid(1:end-4),'_fluoroonly-Blue.jpg'];
%     bluefile=['cellmasks/jpg-blue/cellmask_',num2str(f),'-blue.jpg']; % m919 convention
    blueimg=imread(bluefile);
    %
        greenfile=['Green_channel/',fileid(1:end-4),'_fluoroonly-Green.jpg'];
        greenimg=imread(greenfile);
    %
    if f==1
        imwrite(outimg,outstack,'tif','compression','lzw','writemode','overwrite')
        imwrite(blueimg,bluestack,'tif','compression','lzw','writemode','overwrite')
                imwrite(greenimg,greenstack,'tif','compression','lzw','writemode','overwrite')
    else
        imwrite(outimg,outstack,'tif','compression','lzw','writemode','append')
        imwrite(blueimg,bluestack,'tif','compression','lzw','writemode','append')
                imwrite(greenimg,greenstack,'tif','compression','lzw','writemode','append')
    end
end