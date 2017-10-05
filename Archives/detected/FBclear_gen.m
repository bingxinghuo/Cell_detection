%% 1. read in files
fid=fopen('filenames.txt');
filelist=textscan(fid,'%q');
fclose(fid);
filelist=filelist{1};
%%
load('FBdetectdata.mat')
FBclear=cell(length(filelist),1);
%%
for f=1:length(filelist)
        %%
%     tic
    maskname=['imgmaskdata_',num2str(f)];
    load(['imgmasks/',maskname])
    %     load(maskname)
    FBclear{f}.x=[];
    FBclear{f}.y=[];
    for j=1:length(FBdetected{f}.x)
        if imgmask(round(FBdetected{f}.y(j)),round(FBdetected{f}.x(j)))==1
            FBclear{f}.x=[FBclear{f}.x;FBdetected{f}.x(j)];
            FBclear{f}.y=[FBclear{f}.y;FBdetected{f}.y(j)];
        end
    end
%     toc
end
    %%
%     tic
    save('FBdetectdata','FBclear','-append')
%     toc