function FBclear=layer2fun(fluoroimg,imgmask,win,f)
%% 1. define a moving window
hori=floor(size(fluoroimg,2)/win.width)+1; % steps to move in the horizontal direction
vert=floor(size(fluoroimg,1)/win.height)+1; % steps to move in the vertical direction
FBdetected{f}.x=[];
FBdetected{f}.y=[];
centroids=[];
%
for v=1:vert % then move down
    for h=1:hori % first move horizontally
        %             tic
        %%
        imgtemp_rgb=fluoroimg((v-1)*win.height+1:min(v*win.height,size(fluoroimg,1)),(h-1)*win.width+1:min(h*win.width,size(fluoroimg,2)),:);
        % if there are interesting cells in the image
        if (sum(sum(imgtemp_rgb(:,:,3)>100))>10) % if there are at least 10 pixels exceed the threshold of 100
            %% visualize 16-bit data
            %                 clf
            %                 if bitinfo==8
            %                     ax1=subplot(1,2,1);imshow(imgtemp_rgb); hold on
            %                 elseif bitinfo==12
            %                     hsvimg=rgb2hsv(imgtemp_rgb);
            %                     hsvimg(:,:,3)=hsvimg(:,:,3)*100; % adjust intensity map
            %                     newrgb=uint16(hsv2rgb(hsvimg)*2^16);
            %                     ax1=subplot(1,2,1);imshow(newrgb); hold on
            %                 end
            %                 %             ax2=subplot(1,2,2);imshow(imgtemp_mono); hold on
            %                 ax2=subplot(1,2,2); hold on
            %
            %%
            pars2.v=v;
            pars2.h=h;
            pars2.f=f;
            pars2.win=win;
            centroids=layer3fun(imgtemp_rgb,pars2);
            
            
            if ~isempty(centroids)
                ptx=centroids(:,1)+(h-1)*win.width;
                pty=centroids(:,2)+(v-1)*win.height;
                %% visualize
                %                         scatter(ax1,centroids(:,1),centroids(:,2),'m*')
                %                         scatter(ax2,centroids(:,1),centroids(:,2),'m*')
                %% save data
                FBdetected{f}.x=[FBdetected{f}.x;ptx];
                FBdetected{f}.y=[FBdetected{f}.y;pty];
            end
        end
        
        %                 linkaxes([ax1,ax2]);
        %                 toc
        %                 pause
    end
end
end
%% mask
if bitinfo==8
    maskfiles=ls('imgmasks/');
    maskname=['imgmasks/imgmaskdata_',num2str(f)];
    if isempty(maskfiles) % if there is no mask files
        imgmask=cellmaskfun(fluoroimg); % generate one
        
        parsave(maskname,imgmask)
    else % if there is
        maskname=['imgmaskdata_',num2str(f)];
        maskfile=load(['imgmasks/',maskname]); % load the image
        if ~islogical(maskfile.imgmask); % check mask data type
            imgmask=logical(maskfile.imgmask); % convert
            parsave(maskname,imgmask)
        else
            imgmask=maskfile.imgmask;
        end
    end
    % clean up the image
    FBclear{f}.x=[];
    FBclear{f}.y=[];
    for j=1:length(FBdetected{f}.x)
        if imgmask(round(FBdetected{f}.y(j)),round(FBdetected{f}.x(j)))==1
            FBclear{f}.x=[FBclear{f}.x;FBdetected{f}.x(j)];
            FBclear{f}.y=[FBclear{f}.y;FBdetected{f}.y(j)];
        end
    end
    
end