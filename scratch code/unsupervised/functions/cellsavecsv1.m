% load('FBdetectdata.mat')
% load('FBdetectdata_consolid')
%% file 1: cell locations
celloc=[];
% for i=1:length(FBdetected);
for i=1:size(FBclear,1)
    if ~isempty(FBclear{i})
        celloc=[celloc;[i*ones(size(FBclear{i},1),1),FBclear{i}(:,1),FBclear{i}(:,2)]];
    end
end
celloc=round(celloc);
csvwrite('celloc.csv',celloc)
%% file 2: all info
% read in file names
fid=fopen('filenames.txt');
filelist=textscan(fid,'%q');
fclose(fid);
filelist=filelist{1};
% create a file to save
fid=fopen('cellallinfo.csv','w');
formatspec='%d,%s,%d,%d,%d,%d\n';
%
L=length(celloc);
celloc_info=cell(L,6);
seqnum1=0;
for l=1:L
    seqnum=celloc(l,1);
    celloc_info{l,1}=seqnum; % column 1: sequance number
    celloc_info{l,2}=filelist{seqnum}; % column 2: file name
    while seqnum~=seqnum1
        fileinf=imfinfo(filelist{seqnum});
        seqnum1=seqnum;
    end
    celloc_info{l,3}=fileinf.Width;
    celloc_info{l,4}=fileinf.Height;
    celloc_info{l,5}=celloc(l,2);
    celloc_info{l,6}=celloc(l,3);
    fprintf(fid,formatspec,celloc_info{l,:});
end
fclose(fid);
%% file 3: file lookup table; file 4: image sizes
fid1=fopen('sectionfiles.txt','w');
fid2=fopen('sectionsize.txt','w');
formatspec1='%d,%s\n';
formatspec2='%s,%d,%d\n';
% fs=length(FBdetected);
fs=length(FBclear);
for f=1:fs
    fprintf(fid1,formatspec1,f,filelist{f});
    fileinf=imfinfo(filelist{f});
    fprintf(fid2,formatspec2,filelist{f},fileinf.Width,fileinf.Height);
end
fclose('all');

