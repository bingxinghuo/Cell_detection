function mat2tifstack(filelist,outputtif)
%% 1. read file list
Nfiles=length(filelist);
%% 2. write
% maskstack=['brainmask.tif'];
for f=1:Nfiles
    stackimg=load(filelist{f});
    % get the image field
    if isstruct(stackimg)
        maskvar=fieldnames(stackimg);
        stackimg=getfield(stackimg,maskvar{1});
    end
    if f==1
        imwrite(stackimg,outputtif,'tif','compression','lzw','writemode','overwrite')
    else
        imwrite(stackimg,outputtif,'tif','compression','lzw','writemode','append')
    end
end