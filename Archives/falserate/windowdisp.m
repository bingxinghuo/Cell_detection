function windowdisp(imgtemp_rgb,xedge,yedge,showauto)
global bitinfo FBautocell H W ax1 ind
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
    %     truesize
    linkaxes([ax1,ax2])
    if showauto=='y'
        % find the x and y edgeinates of cell bodies within the current window
        automasky=(FBautocell.y>yedge(1)).*(FBautocell.y<=min(yedge(2),H));
        automaskx=(FBautocell.x>xedge(1)).*(FBautocell.x<=min(xedge(2),W));
        automask=automaskx.*automasky; % both x and y edgeinates need to be inside the window
        ind=find(automask==1);
        if ~isempty(ind)
            
            scatter(ax1,FBautocell.x(ind)-xedge(1),FBautocell.y(ind)-yedge(1),'mo')
            scatter(ax2,FBautocell.x(ind)-xedge(1),FBautocell.y(ind)-yedge(1),'mo')
        end
    end
end
end