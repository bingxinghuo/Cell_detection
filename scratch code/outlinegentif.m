cd ~/marmosetRIKEN/NZ
dir0=pwd;
dirlist=dir('m*'); % generate a list of all brains to be processed
failcatch=false(zeros(length(dirlist),1));
for d=1:length(dirlist)
    brainid=dirlist(d).name;
    maskdir=[dir0,'/',brainid,'/',brainid,'F/JP2/imgmasks'];
    if ~exist(maskdir)
        failcatch(d)=true;
    else
        masklist=dir('*.mat');
        Nfiles=length(masklist);            
        parfor f=1:Nfiles
            maskname=['imgmaskdata_',num2str(f),'.mat'];
            imgmask=load(maskname);
            maskvar=fieldnames(imgmask);
            imgmask=getfield(imgmask,maskvar{1});
            imgout=bwperim(imgmask); % detect outline
                        % expand the outline for easier visualization
            se=strel('disk',10);
            imgout=imdilate(imgout,se);
            imgoutall(:,:,f)=imgout;
            
        end
        % write
                outfile=[brainid,'_outline.tif'];
        imwrite(imgoutall(:,:,1),outfile)
        for f=2:Nfiles
            imwrite(imgoutall(:,:,f),outfile,'writemode','append')
        end
    end
end