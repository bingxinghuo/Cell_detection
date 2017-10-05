%% 1. read in files
fid=fopen('filenames.txt');
filelist=textscan(fid,'%q');
fclose(fid);
filelist=filelist{1};
%% 2. decide the image resolution
fileinf=imfinfo(filelist{1});
bitinfo=fileinf.BitsPerSample;
if bitinfo==[8,8,8]
    bitinfo=8;
elseif bitinfo==[16, 16, 16]
    bitinfo=12;
end
%% 3. Set threshold
if bitinfo==8
    satmax=2^bitinfo-1;
    satthresh=2^bitinfo*.95;
elseif  bitinfo==12
    satmax=2^(bitinfo-2)-1;
    satthresh=2^(bitinfo-2)*.95;
end
%% 4. Find saturation map
injarea=cell(length(filelist),1);
% window size
win.width=500; % columns
win.height=400; % rows
parfor f=1:length(filelist)
    fileid=filelist{f};
    fluoroimg=imread(fileid,'jp2');
    if (sum(sum(fluoroimg(:,:,3)>=satmax))>100) % at least 100 points are "saturated"
        H=size(fluoroimg,1);
        W=size(fluoroimg,2);
        hori=floor(W/win.width)+1; % steps to move in the horizontal direction
        vert=floor(H/win.height)+1; % steps to move in the vertical direction
        injbw=logical(zeros(H,W));
        %     imgfilt=imgaussfilt(fluoroimg(:,:,3),20);
        sigma=20;
        
        % 1. define a moving window
        for v=1:vert % then move down
            for h=1:hori % first move horizontally
                yedge=[(v-1)*win.height,v*win.height]; % edges in the vertical direction
                xedge=[(h-1)*win.width,h*win.width]; % edges in the horizontal direction
                imgtemp_mono=fluoroimg(yedge(1)+1:min(yedge(2),H),xedge(1)+1:min(xedge(2),W),3); % get the part of image inside the window
                imgfilt=imfilter(imgtemp_mono,fspecial('gaussian',2*ceil(2*sigma)+1, sigma),'replicate');
                satumask=imgfilt>satthresh;
                injbw=imgstitch(injbw,satumask,xedge,yedge);
            end
        end
        injarea{f}=injbw;
    end
end
save('injareadata','injarea','-v7.3')