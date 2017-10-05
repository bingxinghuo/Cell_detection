%% cellmask.m
% Bingxing Huo, August 2016
% Version 3
% This code automatically detects the brain slice in the fluorescent image
% and saves the mask as a .mat file.
%% 1. read in files
fid=fopen('filenames.txt');
filelist=textscan(fid,'%q');
fclose(fid);
filelist=filelist{1};
%% 2. Find mask for every slice
imgmask=cell(length(filelist),1);
for f=1:length(filelist)
    fileid=filelist{f};
    fluoroimg=imread(fileid,'jp2');
    %% 1. define a moving window
    hsvimg_full=zeros(size(fluoroimg),'single');
    win.width=500; % columns
    win.height=400; % rows
    win.hori=floor(size(fluoroimg,2)/win.width)+1; % steps to move in the horizontal direction
    win.vert=floor(size(fluoroimg,1)/win.height)+1; % steps to move in the vertical direction
    %
    for v=1:win.vert % then move down
        for h=1:win.hori % first move horizontally
            imgtemp_rgb=fluoroimg((v-1)*win.height+1:min(v*win.height,size(fluoroimg,1)),(h-1)*win.width+1:min(h*win.width,size(fluoroimg,2)),:);
            hsvimg=rgb2hsv(imgtemp_rgb);
            hsvimg_full((v-1)*win.height+1:min(v*win.height,size(fluoroimg,1)),(h-1)*win.width+1:min(h*win.width,size(fluoroimg,2)),:)=hsvimg;
        end
    end
    %%
    % collect all the info in 3 channels
    fluoroimg1=sum(fluoroimg,3);
    % take first derivative
    dimg=diff(diff(fluoroimg1,1,1),1,2);
    % Find the threshold using Otsu's method
    level=graythresh(dimg);
    % Apply threshold to remove noise
    dimg=im2bw(dimg,level);
    % Connect adjacent bojects
    dimg=imfill(dimg,'holes');
    % Clear up scattered noise
    dimg=bwareaopen(dimg,50);
    % Detect objects
    L=bwlabel(dimg);
    rows=size(fluoroimg,1);
    columns=size(fluoroimg,2);
    % Obtain the connectivity information
    CC=bwconncomp(dimg);
    % Obtain the area of each object
    num=zeros(CC.NumObjects,1);
    for i=1:CC.NumObjects
        num(i)=length(CC.PixelIdxList{i});
    end
    % Threshold the area of each object
    totpix=rows*columns;
    [num1,numind]=find(num>totpix*.001);
    bw2=zeros(rows-1, columns-1);
    for i=1:length(num1)
        bw2=bw2+(L==num1(i));
    end
    % Pad with zeros to obtain a mask for the original image
    imgmask=zeros(rows, columns);
    imgmask(1:end-1,1:end-1)=bw2;
    % Save
    maskname=['imgmaskdata_',num2str(f)];
    save(maskname,'imgmask','-v7.3')
end