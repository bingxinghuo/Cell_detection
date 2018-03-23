cx=M919NXForm(:,1);
cy=M919NXForm(:,2);
r=M919NXForm(:,3);
tx=M919NXForm(:,4);
ty=M919NXForm(:,5);
M=64;
for f=fileind1:fileind2
    nissljp2=filelist{f};
%     LGNmaskfile=[nissljp2(1:end-4),'_LGN.tif'];
%     LGNmask=imread(LGNmaskfile);
%     LGNmaskdown=downsample_max(LGNmask,M);
%     LGNsmallfile=[LGNmaskfile(1:end-5),'down.tif'];
%     imwrite(LGNmaskdown,LGNsmallfile)
LGNsmallfile=[nissljp2(1:end-4),'_LGdown.tif'];    
    LGNtifdir=pwd;
    transformation_cross_alignment(LGNtifdir, LGNsmallfile, r(f), tx(f), ty(f), cx(f), cy(f))
end
%%
tifstack=zeros(351,421,19);
cr=(351-1)/2+1;
cc=(421-1)/2+1;
afilelist=cell(19,1);
for i=1:19
nissljp2=filelist{fileind1-1+i};
afilelist{i}=['aligned_',nissljp2(1:end-4),'_LGdown.tif'];
end
for i=1:length(afilelist)
    tifimg=imread(afilelist{i});
    [rows,cols]=size(tifimg);
    tifstack(cr-(rows-1)/2:cr+(rows-1)/2,cc-(cols-1)/2:cc+(cols-1)/2,i)=tifimg;
end
imwrite(tifstack(:,:,1),'alignedtif.tif','tif','Compression','none','WriteMode','overwrite');
for i=2:19
imwrite(tifstack(:,:,i),'alignedtif.tif','tif','WriteMode','append');
end