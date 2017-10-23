fid=fopen('filenames.txt');
filelist=textscan(fid,'%q');
fclose(fid);
filelist=filelist{1};
Nfiles=length(filelist);
%%
FBclear=cell(Nfiles,1);
Nstart=1;
parfor f=Nstart:Nfiles
    cellmaskname=['cellmasks/cellmask_',num2str(f),'.mat'];
    cellmask=load(cellmaskname);
    cc=bwconncomp(cellmask.savedata);
    rprops=regionprops(cc,'centroid');
    centroids=reshape([rprops.Centroid],2,[])';
    if ~isempty(centroids)
        FBclear{f}=centroids;
        
    else
        FBclear{f}=[];
    end
end
%%
save('FBdetectdata_svm','FBclear')