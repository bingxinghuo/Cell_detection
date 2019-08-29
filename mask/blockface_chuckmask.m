outputdir='./chuckmasked/';
if ~exist(outputdir)
    mkdir(outputdir)
end
% filelist=filelsread('*.PNG');
fid=fopen('filenames.txt');
filelist=textscan(fid,'%q');
fclose(fid);
filelist=filelist{1};
W=300;
H=200;
figure
for f=1:length(filelist)
    pngimg=imread(filelist{f});
    clf;
    imagesc(pngimg)
    disp([filelist{f},'... Please double click on the tissue'])
    [x,y]=getpts();
    rectpos=[round(x)-W/2,round(y)-H/2,W,H];
    pngmasked=(pngimg(rectpos(2):rectpos(2)+H,rectpos(1):rectpos(1)+W,:));
    imwrite(pngmasked,[outputdir,'/',filelist{f}])
end
    