function parsavejpg(path,savedata)
    imwrite(savedata,path,'mode','lossless')
%     save(path,'savedata','-v7.3')
end