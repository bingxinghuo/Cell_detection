%% pixelhist_figs_v7.m
% This script reads the jp2 images within the directory and generate
% histograms for individual channels. The histogram information for all the
% images is stored in a common file called ****_histinfo.mat.
global bitinfo
% cd ~/marmosetRIKEN/NZ
dir0=pwd;
dirlist=dir('m*'); % generate a list of all brains to be processed
% for d=6:length(dirlist)
for d=9
    cd([dirlist(d).name,'/',dirlist(d).name,'F/JP2']) % go to the directory of JP2
    % IMPORTANT! USE THE CUSTOM GENERATED FILELIST
    if ~exist([pwd,'/','filenames.txt'])
        system('ls -h M*.jp2 | sort -t"_" -k3 > filenames.txt');
    end
    fid=fopen('filenames.txt'); 
    filelist=textscan(fid,'%q');
    fclose(fid);
    filelist=filelist{1};
    Nfiles=length(filelist);
    % Generate the masks for brain section
    if ~exist([pwd,'/imgmasks/'])
        mkdir('imgmasks')
    end
    histname=[filelist{1}(1:4),'_histinfo.mat'];
    if ~exist([pwd,'/',histname])
        fileinfo=imfinfo(filelist{1});
        if fileinfo.BitDepth==24 % 8-bit
            system('mv filenames.txt filenames_8bit.txt'); % mark and skip
        elseif fileinfo.BitDepth==48 % 16-bit
            bitinfo=12;
            failcatch=zeros(Nfiles,1); % allocate a vector to catch failures
            histN=cell(Nfiles,1);
            histX=cell(Nfiles,1);
            parfor f=1:Nfiles
                if f==146
                    histN{f}.tot=[];
                    histN{f}.brain=[];
                    histX{f}.tot=[];
                    histX{f}.brain=[];
                else    
                try
                    % load image
                    fileid=filelist{f};
                    fluoroimg=imread(fileid,'jp2');
                    maskname=['imgmasks/imgmaskdata_',num2str(f),'.mat'];
                    % load/generate brain section mask (note: there are errors in some images)
                    if exist([pwd,'/',maskname],'file')==2 % mask file already exists
                        imgmask=load(maskname); % get the mask
                        maskvar=fieldnames(imgmask); 
                        imgmask=getfield(imgmask,maskvar{1});
                    else % no mask file yet
                        imgmask=brainmaskfun_reg(fluoroimg)
                        parsave(maskname,imgmask)
                    end
                    [histN{f},histX{f}]=pixelhistview(fluoroimg,imgmask);

                catch ME
                    f
                    failcatch(f)=1;
                    rethrow(ME)
                end
                end
            end
            
            save(histname,'histN','histX')
            save('failmasks.mat','failcatch')
        end
    end
    cd(dir0) % go back to the original directory
end