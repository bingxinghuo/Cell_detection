fid=fopen('filenames.txt');
filelist=textscan(fid,'%q');
fclose(fid);
filelist=filelist{1};
Nfiles=length(filelist);
%%
% A=strfind(filelist,'F137');
% Aind=find(~cellfun(@isempty,A));
%%
% tic
f=100;
fileid=filelist{f};
fluoroimg=imread(fileid,'jp2');
%%
maskname=['imgmasks/imgmaskdata_',num2str(f),'.mat']; % save the mask
%         if exist([pwd,'/',maskname],'file')==2
imgmask=load(maskname);
maskvar=fieldnames(imgmask);
imgmask=getfield(imgmask,maskvar{1});
% toc