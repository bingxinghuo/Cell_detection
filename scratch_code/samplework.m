%% This is a sample script of workflow
%% 1. find and read the image
cd('marmoset/NZ/m920/m920F/JP2')
filelist=jp2lsread;
[fileind,fileid]=jp2ind(filelist,'F120--');
tic;fluoroimg=imread(fileid,'jp2');toc
% display the image
% fluoroimg16=uint16(fluoroimg*2^4); % linearly stretch the dynamic range from 12-bit to 16-bit
% figure, imagesc(fluoroimg16);
fluoroimg8=uint8(fluoroimg); % quench (threshold) the dynamic range from 12-bit to 8-bit
figure, imagesc(fluoroimg8);
%% 2. Image tiling
win.width=512; % columns
win.height=512; % rows
[imgheight,imgwidth,~]=size(fluoroimg);
cellmask=zeros(imgheight,imgwidth);
hori=floor(imgwidth/win.width)+1; % steps to move in the horizontal direction
vert=floor(imgheight/win.height)+1; % steps to move in the vertical direction
thresh.intensity=100;
thresh.count=10;
figure
for v=1:vert % then move vertically
    for h=1:hori % first move horizontally
        % 3.1 get the moving window
        imgtile=fluoroimg((v-1)*win.height+1:min(v*win.height,imgheight),(h-1)*win.width+1:min(h*win.width,imgwidth),:);
        if (sum(sum(imgtile(:,:,3)>thresh.intensity))>thresh.count)
                        imagesc(uint8(imgtile))
                        pause
%             celltile=peakgrow(imgtile,win);
%             cellmask((v-1)*win.height+1:min(v*win.height,imgheight),(h-1)*win.width+1:min(h*win.width,imgwidth))=celltile;
        end
    end
end
%%
v=5;
h=18;
imgtile=fluoroimg((v-1)*win.height+1:min(v*win.height,imgheight),(h-1)*win.width+1:min(h*win.width,imgwidth),:);
