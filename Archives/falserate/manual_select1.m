%% Manual selection of FB labeled cells
% Ad hoc solution for Dr. Rosa
% For inquiries please contact Bingxing (bingxing.huo@gmail.com)
% function mancell=manual_select(fluoroimg)
global bitinfo showauto FBautocell H W
%% 1. read in file
files=dir('./*.jp2');
for f=1:length(files)
    filenames{f}=files(f).name(1:end-4);
    disp(['File ',num2str(f),': ',filenames{f}])
end
fsample=input(['Please select which file you would like to see (1~',num2str(length(files)),'): ']);
% fluoroimg=imread(filenames{fsample},'jp2'); % load the image
fileinf=imfinfo(files(fsample).name);
bitinfo=fileinf.BitsPerSample;
if bitinfo==[8,8,8]
    bitinfo=8;
elseif bitinfo==[16, 16, 16]
    bitinfo=12;
end
%% 2. load automatically detected results
showauto=input('Do you want to see the automatically detected cells? (y/n) ','s');
if showauto=='y'
    load([filenames{fsample},'_FB']) % load the detected cells
    
end
H=size(fluoroimg,1);
W=size(fluoroimg,2);
%% 3. select region or all
mancell.FP=cell(2,1);
mancell.FN=cell(2,1);
mancell.new=cell(2,1);
win.width=500; % columns
win.height=400; % rows
manualregion=input('Do you want to manually select a region (s) or go through the entire image (e) (s/e)? ','s');
if manualregion=='e' % entire image
    % 1. define a moving window
    win.hori=floor(W/win.width)+1; % steps to move in the horizontal direction
    win.vert=floor(H/win.height)+1; % steps to move in the vertical direction
    for v=1:win.vert % then move down
        for h=1:win.hori % first move horizontally
            yedge=[(v-1)*win.height,v*win.height];
            xedge=[(h-1)*win.width,h*win.width];
            imgtemp_rgb=fluoroimg(yedge(1)+1:min(yedge(2),H),xedge(1)+1:min(xedge(2),W),:);
            mancell=windowselect(imgtemp_rgb,xedge,yedge,mancell);
        end
    end
elseif manualregion=='s' % select a region
    figure, imagesc(uint8(fluoroimg)) % 12-bit image is not visible in the 16-bit format
    title('Move or drag the box ','fontsize',18)
    okarea='n';
    area=[];
    while okarea=='n'
        if ~isempty(area)
            delete(area)
        end
        area=imrect(gca,[round(H/2),round(W/2),win.width,win.height]);
        okarea=input(['Region ok? (y/n) '],'s');
        
    end
    pos=getPosition(area);
    pos=round(pos);
    xedge=[pos(1),pos(1)+pos(3)];
    yedge=[pos(2),pos(2)+pos(4)];
    imgtemp_rgb=fluoroimg(yedge(1):yedge(2),xedge(1):xedge(2),:);
    mancell=windowselect(imgtemp_rgb,xedge,yedge,mancell);
    
end