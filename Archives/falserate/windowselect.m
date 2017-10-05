function mancell=windowselect(imgtemp_rgb,xedge,yedge,mancell)
global bitinfo showauto FBautocell H W
%% 1. visualize
imgtemp_mono=imgtemp_rgb(:,:,3);
if (sum(sum(imgtemp_mono>100))>10)
    % show partial image
    clf
    if bitinfo==8
        ax1=subplot(1,2,1);imshow(imgtemp_rgb); hold on
    elseif bitinfo==12
        hsvimg=rgb2hsv(imgtemp_rgb);
        hsvimg(:,:,3)=hsvimg(:,:,3)*100; % adjust intensity map
        newrgb=uint16(hsv2rgb(hsvimg)*2^16);
        ax1=subplot(1,2,1);imshow(newrgb); hold on
        title('Original image','fontsize',18)
    end
    % show background removed image
    ax2=subplot(1,2,2); hold on
    title('Background removed','fontsize',18)
    % remove the background
    sigma=20;
    imgfilt=imgaussfilt(imgtemp_mono,sigma);
    % if the Matlab version is too early, try the following alternative
    % code
    %     imgfilt = imfilter(imgtemp_rgb1,fspecial('gaussian',2*ceil(2*sigma)+1, sigma),'replicate');
    imgtemp_nobak=single(imgtemp_mono-imgfilt);
    % convert to bit and blue channel only
    imgbit=log2(imgtemp_nobak);
    imagesc(imgbit);
    colormap gray
    axis image; axis off; axis ij;
    linkaxes([ax1,ax2])
    % show automatically detected cells
    if showauto=='y'
        % find the x and y coordinates of cell bodies within the current window
        automasky=(FBautocell.y>yedge(1)).*(FBautocell.y<=min(yedge(2),H));
        automaskx=(FBautocell.x>xedge(1)).*(FBautocell.x<=min(xedge(2),W));
        automask=automaskx.*automasky; % both x and y coordinates need to be inside the window
        ind=find(automask==1);
        if ~isempty(ind)
            
            scatter(ax1,FBautocell.x(ind)-xedge(1),FBautocell.y(ind)-yedge(1),'mo')
            scatter(ax2,FBautocell.x(ind)-xedge(1),FBautocell.y(ind)-yedge(1),'mo')
        end
    end
    axes(ax1)
    %% Select false detections
    if showauto=='y'
        checkpt='n';
        while checkpt=='n'
            % False negatives
            selectfinish='n';
            while selectfinish=='n'
                isFN=input('Any FALSE NEGATIVES in this image? (y/n) ','s');
                if isFN=='y'
                    title(ax1,{'PLEASE SELECT WITHIN THIS PANEL'; 'press RETURN to finish'},'fontsize',18)
                    
                    [ptx,pty]=ginput;
                    hold on, scatter(ptx,pty,'wo')
                    selectfinish=input('Do you accept all points? (y/n) ','s');
                    ptx=ptx+xedge(1);
                    pty=pty+yedge(1);
                    mancell.FN{1}=[mancell.FN{1};ptx];
                    mancell.FN{2}=[mancell.FN{2};pty];
                else
                    selectfinish='y';
                end
            end
            % False positives
            if ~isempty(ind)
                selectfinish='n';
                while selectfinish=='n'
                    isFP=input('Any FALSE POSITIVES in this image? (y/n) ','s');
                    title(ax1,{'PLEASE SELECT WITHIN THIS PANEL'; 'Press shift to select multiple points'},'fontsize',18)
                    
                    if isFP=='y'
                        
                        dcm_obj = datacursormode;
                        set(dcm_obj,'DisplayStyle','datatip','SnapToDataVertex','on','Enable','on')
                        selectfinish=input('Finished selection? (y/n) ','s');
                    else
                        selectfinish='y';
                    end
                end
                if ~isempty(dcm_obj)
                    FPinfo=getCursorInfo(dcm_obj);
                    ptx=zeros(length(FPinfo),1);
                    pty=ptx;
                    for c=1:length(FPinfo)
                        ptx(c)=FPinfo(c).Position(1);
                        pty(c)=FPinfo(c).Position(2);
                    end
                    hold on, scatter(ptx,pty,'wo')
                    ptx=ptx+xedge(1);
                    pty=pty+yedge(1);
                    mancell.FP{1}=[mancell.FP{1};ptx];
                    mancell.FP{2}=[mancell.FP{2};pty];
                end
            end
            checkpt=input('Are you done with the current view? (y/n) ','s');
        end
    elseif showauto=='n'
        %% manually select cells
        checkpt='n';
        while checkpt=='n'
            title(ax1,{'PLEASE SELECT WITHIN THIS PANEL'; 'double click to finish'},'fontsize',18)
            [ptx,pty]=getpts(ax1);
            hold on, scatter(ax1,ptx,pty,'wo')
            ptx=ptx+xedge(1);
            pty=pty+yedge(1);
            mancell.new{1}=[mancell.new{1};ptx];
            mancell.new{2}=[mancell.new{2};pty];
            
            checkpt=input('Are you done with the current view? (y/n) ','s');
        end
    end
end
end