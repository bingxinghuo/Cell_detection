%% Manual selection of FB labeled cells
% Ad hoc solution for Dr. Rosa
% For inquiries please contact Bingxing (bingxing.huo@gmail.com)
% This function allows interactive selection of falsely detected cells or
% manually detect the FB labeled cells
% Input:
%   This function can be run without any input as follows:
%       mancell=manual_select;
%   Alternatively, the section image, when loaded into the workspace, can
%   be used as the input. This saves the time of reading the jp2 image each
%   time from inside the function. The syntax is as follows:
%       fluoroimg=imread(filename,'jp2');
%       mancell=manual_select(fluoroimg);
% Output:
%   mancell is a struture with 3 fields:
%       -- FN: a 2-by-1 cell containing the coordiantes of false negatives.
%       x-coordinates are saved in cell (1,1), and y-coordinates are saved
%       in cell (2,1);
%       -- FP: similarly, a 2-by-1 cell containing the coordinates of false
%       positives.
%       -- new: similarly, a 2-by-1 cell containing the coordinates of manually selected FB labeled cells. 
%   Choice to save mancell to the current directory.
function mancell=manual_select(varargin)
global bitinfo showauto FBautocell H W      % global variables that are used across functions
%% 1. read in file
files=dir('./*.jp2'); % get all the jp2 files in the directory
for f=1:length(files)
    filenames{f}=files(f).name(1:end-4);
    disp(['File ',num2str(f),': ',filenames{f}]) % list all file names
end
fsample=input(['Please select which file you would like to see (1~',num2str(length(files)),'): ']);
if nargin==0
    fluoroimg=imread(filenames{fsample},'jp2'); % load the image
    fileinf=imfinfo(files(fsample).name); % get the image information
    bitinfo=fileinf.BitsPerSample;
    if bitinfo==[8,8,8]
        bitinfo=8; % 8-bit data are stored in uint8 format
    elseif bitinfo==[16, 16, 16]
        bitinfo=12; % 12-bit data are stored in uint16 format
    end
elseif nargin==1
    fluoroimg=varargin{1};
    if isa(fluoroimg,'uint8')==1
        bitinfo=8;
    elseif isa(fluoroimg,'uint16')==1
        bitinfo=12;
    end
end

%% 2. load automatically detected results
showauto=input('Do you want to see the automatically detected cells? (y/n) ','s');
if showauto=='y'
    load([filenames{fsample},'_FB']) % load the detected cells
    
end
H=size(fluoroimg,1);
W=size(fluoroimg,2);
%% 3. select region or all
% initialize three fields in the final output
mancell.FP=cell(2,1);
mancell.FN=cell(2,1);
mancell.new=cell(2,1);
% window size that allows visual inspection of individual cells
win.width=500; % columns
win.height=400; % rows
manualregion=input('Do you want to manually select a region (s) or go through the entire image (e) (s/e)? ','s');
figure('Color',[0 0 0]) % black background for easier visualization of fluorescent images
if manualregion=='e'
    %% 3.1 entire image
    % 1. define a moving window
    win.hori=floor(W/win.width)+1; % steps to move in the horizontal direction
    win.vert=floor(H/win.height)+1; % steps to move in the vertical direction
    for v=1:win.vert % then move down
        for h=1:win.hori % first move horizontally
            yedge=[(v-1)*win.height,v*win.height]; % edges in the vertical direction
            xedge=[(h-1)*win.width,h*win.width]; % edges in the horizontal direction
            imgtemp_rgb=fluoroimg(yedge(1)+1:min(yedge(2),H),xedge(1)+1:min(xedge(2),W),:); % get the part of image inside the window
            mancell=windowselect(imgtemp_rgb,xedge,yedge,mancell); % manual selection
        end
    end
elseif manualregion=='s'
    %% 3.2 select a region
    clf, imagesc(uint8(fluoroimg)) % 12-bit image is not visible in the 16-bit format
    % Use the pre-defined rectangular box as ROI or drag it to define an ROI
    title('Move or drag the box ','fontsize',18, 'color', 'w')
    okarea='n';
    area=[];
    while okarea=='n'
        if ~isempty(area)
            delete(area) % delete the previously drawn box
        end
        area=imrect(gca,[round(H/2),round(W/2),win.width,win.height]); % pre-define a box size, moveable and draggable
        % area=imrect;
        pause % this is a trick just to let the box moveable and draggable in Matlab
        okarea=input(['Region ok? (y/n) '],'s'); % confirm
        
    end
    % get the part of image inside the window
    pos=getPosition(area);
    pos=round(pos);
    xedge=[pos(1),pos(1)+pos(3)];
    yedge=[pos(2),pos(2)+pos(4)];
    imgtemp_rgb=fluoroimg(yedge(1):yedge(2),xedge(1):xedge(2),:);
    mancell=windowselect(imgtemp_rgb,xedge,yedge,mancell); % manual selection
    
end
%% 4. save to the current directory
oksave=input('Save the results? (y/n) ','s');
if oksave=='y'
    save([filenames{fsample},'_manual'],'mancell')
end
end
%% Function windowselect.m to manually select cells within the defined window
% Input: 
%   imgtemp_rgb: RGB image within the ROI
%   xedge: edges in the horizontal direction
%   yedge: edges in the vertical direction
%   mancell: structure to store the results
% Output:
%   mancell: final output (refer to above)

function mancell=windowselect(imgtemp_rgb,xedge,yedge,mancell)
global bitinfo showauto FBautocell H W      % global variables that are used across functions
%% 1. visualize
imgtemp_mono=imgtemp_rgb(:,:,3); %  blue channel only
if (sum(sum(imgtemp_mono>100))>10) % if there are at least 10 pixels with values higher than 100
    % 1.1 show partial image
    clf
    if bitinfo==8
        ax1=subplot(1,2,1);imshow(imgtemp_rgb); hold on % display 8-bit image directly
    elseif bitinfo==12 % 12-bit data needs a bit more work...
        hsvimg=rgb2hsv(imgtemp_rgb); % convert to hsv image
        hsvimg(:,:,3)=hsvimg(:,:,3)*100; % adjust intensity map
        newrgb=uint16(hsv2rgb(hsvimg)*2^16); % rescale so that the image is bright enough to be shown in 16-bit image
        ax1=subplot(1,2,1);imshow(newrgb); hold on
        title('Original image','fontsize',18, 'color', 'w')
    end
    % 1.2 show background removed image
    ax2=subplot(1,2,2); hold on
    title('Background removed','fontsize',18, 'color', 'w')
    % remove the background
    sigma=20;
    imgfilt=imgaussfilt(imgtemp_mono,sigma); % Use a Gaussian blurred image as the background, sigma should be large
    % if the Matlab version is too early, try the following alternative code
    %     imgfilt = imfilter(imgtemp_rgb1,fspecial('gaussian',2*ceil(2*sigma)+1, sigma),'replicate');
    imgtemp_nobak=single(imgtemp_mono-imgfilt); % Remove the background
    imgbit=log2(imgtemp_nobak); % convert to bit
    imagesc(imgbit);
    colormap gray
    axis image; axis off; axis ij;
    linkaxes([ax1,ax2])
    % 1.3 show automatically detected cells
    if showauto=='y'
        % find the x and y coordinates of cell bodies within the current window
        automasky=(FBautocell.y>yedge(1)).*(FBautocell.y<=min(yedge(2),H));
        automaskx=(FBautocell.x>xedge(1)).*(FBautocell.x<=min(xedge(2),W));
        automask=automaskx.*automasky; % both x and y coordinates need to be inside the window
        ind=find(automask==1); % identify the indices of cells
        if ~isempty(ind)
            scatter(ax1,FBautocell.x(ind)-xedge(1),FBautocell.y(ind)-yedge(1),'mo')
            scatter(ax2,FBautocell.x(ind)-xedge(1),FBautocell.y(ind)-yedge(1),'mo')
        end
    end
    axes(ax1) % use the first panel for all subsequent manipulations
    %% 2. Select false detections
    if showauto=='y'
        checkpt='n';
        while checkpt=='n'
            % 2.1 False negatives
            selectfinish='n';
            while selectfinish=='n'
                isFN=input('Any FALSE NEGATIVES in this image? (y/n) ','s');
                if isFN=='y'
                    title(ax1,{'PLEASE SELECT WITHIN THIS PANEL'; 'double click to finish'},'fontsize',18, 'color', 'w')
                    
                    [ptx,pty]=getpts(ax1); % select points
                    hold on, scatter(ptx,pty,'wo')
                    selectfinish=input('Do you accept all points? (y/n) ','s');
                    % adjust to the entire image coordinates
                    ptx=ptx+xedge(1);
                    pty=pty+yedge(1);
                    % save as a single variable for each dimension
                    mancell.FN{1}=[mancell.FN{1};ptx];
                    mancell.FN{2}=[mancell.FN{2};pty];
                else
                    selectfinish='y'; % skp if there is no FN
                end
            end
            % 2.2 False positives
            if ~isempty(ind) % if there are cells automatically detected within the window
                selectfinish='n';
                while selectfinish=='n'
                    isFP=input('Any FALSE POSITIVES in this image? (y/n) ','s');
                    title(ax1,{'PLEASE SELECT WITHIN THIS PANEL'; 'Press shift to select multiple points'; ...
                        'When finish, press any key '},'fontsize',18, 'color', 'w')
                    if isFP=='y'
                        dcm_obj = datacursormode; % use cursor to select data points
                        set(dcm_obj,'DisplayStyle','datatip','SnapToDataVertex','on','Enable','on')
                        pause % this is a trick just to let matlab display the datatips
                        selectfinish=input('Finished selection? (y/n) ','s');
                    else
                        selectfinish='y'; % skp if there is no FP
                    end
                end
                % get the coordinates of the selected points
                if ~isempty(dcm_obj)
                    FPinfo=getCursorInfo(dcm_obj);
                    ptx=zeros(length(FPinfo),1);
                    pty=ptx;
                    for c=1:length(FPinfo)
                        ptx(c)=FPinfo(c).Position(1);
                        pty(c)=FPinfo(c).Position(2);
                    end
                    % hold on, scatter(ax1,ptx,pty,'wo')
                    % adjust to the entire image coordinates
                    ptx=ptx+xedge(1);
                    pty=pty+yedge(1);
                    % save as a single variable for each dimension
                    mancell.FP{1}=[mancell.FP{1};ptx];
                    mancell.FP{2}=[mancell.FP{2};pty];
                end
            end
            checkpt=input('Are you done with the current view? (y/n) ','s');
        end
    elseif showauto=='n'
        %% 3. manually select cells
        checkpt='n';
        while checkpt=='n'
            title(ax1,{'PLEASE SELECT WITHIN THIS PANEL'; 'double click to finish'},'fontsize',18, 'color', 'w')
            [ptx,pty]=getpts(ax1); % select points
            hold on, scatter(ax1,ptx,pty,'wo') % show them in white afterwards
            % adjust to the entire image coordinates
            ptx=ptx+xedge(1);
            pty=pty+yedge(1);
            % save as a single variable for each dimension
            mancell.new{1}=[mancell.new{1};ptx];
            mancell.new{2}=[mancell.new{2};pty];
            checkpt=input('Are you done with the current view? (y/n) ','s');
        end
    end
end
end