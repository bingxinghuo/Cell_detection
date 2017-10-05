%% FB_detection.m
% This script detects the FB labeled cell bodies in 8-bit RGB images using
% color segmentation and watershed method
%% 1. read in files
fid=fopen('filenames.txt');
filelist=textscan(fid,'%q');
fclose(fid);
filelist=filelist{1};
%%
% A=strfind(filelist,'F106');
% Aind=find(~cellfun(@isempty,A));
% f=Aind;
FBdetected=cell(length(filelist),1);
FBclear=cell(length(filelist),1);
% load FBdetectdata
for f=1:length(filelist)
    fileid=filelist{f};
    fluoroimg=imread(fileid,'jp2');
    %%
    fileinf=imfinfo(filelist{f});
    bitinfo=fileinf.BitsPerSample;
    if bitinfo==[8,8,8]
        bitinfo=8;
    elseif bitinfo==[16, 16, 16]
        bitinfo=12;
    end
    %% 1. define a moving window
    win.width=500; % columns
    win.height=400; % rows
    win.hori=floor(size(fluoroimg,2)/win.width)+1; % steps to move in the horizontal direction
    win.vert=floor(size(fluoroimg,1)/win.height)+1; % steps to move in the vertical direction
    FBdetected{f}.x=[];
    FBdetected{f}.y=[];
    centroids=[];
    %
    for v=1:win.vert % then move down
        for h=1:win.hori % first move horizontally
            %             tic
            %%
            imgtemp_rgb=fluoroimg((v-1)*win.height+1:min(v*win.height,size(fluoroimg,1)),(h-1)*win.width+1:min(h*win.width,size(fluoroimg,2)),:);
            % if there are interesting cells in the image
            if (sum(sum(imgtemp_rgb(:,:,3)>100))>10) % if there are at least 10 pixels exceed the threshold of 100
                %% visualize 16-bit data
                clf
                if bitinfo==8
                    ax1=subplot(1,2,1);imshow(imgtemp_rgb); hold on
                elseif bitinfo==12
                    hsvimg=rgb2hsv(imgtemp_rgb);
                    hsvimg(:,:,3)=hsvimg(:,:,3)*100; % adjust intensity map
                    newrgb=uint16(hsv2rgb(hsvimg)*2^16);
                    ax1=subplot(1,2,1);imshow(newrgb); hold on
                end
                %             ax2=subplot(1,2,2);imshow(imgtemp_mono); hold on
                ax2=subplot(1,2,2); hold on
                
                %% color segmentation
                %                 hsvimg=rgb2hsv(imgtemp_rgb);
                %                 bluemask=hsvimg(:,:,1)>.5 & hsvimg(:,:,1)<.8;
                %                 imgtemp_rgb1=single(imgtemp_rgb).*cat(3,bluemask,bluemask,bluemask);
                imgtemp_rgb1=imgtemp_rgb;
                %% generate the background
                %                 imgfilt=imgaussfilt(imgtemp_rgb,10);
                sigma=20;
                imgfilt = imfilter(imgtemp_rgb1,fspecial('gaussian',2*ceil(2*sigma)+1, sigma),'replicate');
                % remove background/saturation
                imgtemp_nobak=single(imgtemp_rgb1-imgfilt);
                %% if there is saturation in the image
                if (sum(sum(imgtemp_rgb(:,:,3)==2^bitinfo))>100)
                    
                    % create the mask for saturated area
                    satumask=imgfilt(:,:,3)>bitinfo*.95;
                    if sum(sum(satumask))>10 % if there are at least 10 pixels in the saturated mask
                        %% 1. saturated area
                        imgtemp_sat=imgtemp_nobak.*cat(3,satumask,satumask,satumask);
                        % there should not be useful information in the interest channel. Ignore.
                        imgsat=imgtemp_sat(:,:,1)+imgtemp_sat(:,:,2);
                        %                     centroids=celldetect_vis(imgsat,imgtemp_rgb);
                        centroids=celldetect_v4(imgsat,1);
                        
                        if ~isempty(centroids)
                            ptx=centroids(:,1)+(h-1)*win.width;
                            pty=centroids(:,2)+(v-1)*win.height;
                            % visualize
                            scatter(ax1,centroids(:,1),centroids(:,2),'m*')
                            scatter(ax2,centroids(:,1),centroids(:,2),'m*')
                            % save data
                            FBdetected{f}.x=[FBdetected{f}.x;ptx];
                            FBdetected{f}.y=[FBdetected{f}.y;pty];
                        end
                    end
                    %                 pause
                    %% 2. unsaturated area
                    imgtemp_unsat=imgtemp_nobak(:,:,3).*(1-satumask);
                    %                 imgtemp_rgb_unsat=double(imgtemp_rgb).*cat(3,1-satumask,1-satumask,1-satumask);
                    %                     centroids=celldetect_vis(imgtemp_unsat,imgtemp_rgb);
                    %                     centroids=celldetect_vis(imgtemp_unsat,imgtemp_rgb);
                    centroids=celldetect_v4(imgtemp_unsat,1);
                    
                    if ~isempty(centroids)
                        ptx=centroids(:,1)+(h-1)*win.width;
                        pty=centroids(:,2)+(v-1)*win.height;
                        % visualize
                        scatter(ax1,centroids(:,1),centroids(:,2),'m*')
                        scatter(ax2,centroids(:,1),centroids(:,2),'m*')
                        % save data
                        FBdetected{f}.x=[FBdetected{f}.x;ptx];
                        FBdetected{f}.y=[FBdetected{f}.y;pty];
                    end
                else % no saturation in the image
                    %
                    %                     imgtemp_mono=imgtemp_nobak(:,:,3)-max(imgtemp_nobak(:,:,1),imgtemp_nobak(:,:,2));
                    imgtemp_mono=imgtemp_nobak(:,:,3);
                    %                     centroids=celldetect_vis(imgtemp_mono,imgtemp_rgb);
                    centroids=celldetect_v4(imgtemp_mono,1);
                    
                    if ~isempty(centroids)
                        ptx=centroids(:,1)+(h-1)*win.width;
                        pty=centroids(:,2)+(v-1)*win.height;
                        %% visualize
                        scatter(ax1,centroids(:,1),centroids(:,2),'m*')
                        scatter(ax2,centroids(:,1),centroids(:,2),'m*')
                        %% save data
                        FBdetected{f}.x=[FBdetected{f}.x;ptx];
                        FBdetected{f}.y=[FBdetected{f}.y;pty];
                    end
                end
                
                linkaxes([ax1,ax2]);
                %                 toc
                pause
            end
        end
    end
    %%
    tic
    maskname=['imgmaskdata_',num2str(f)];
    load(['imgmasks/',maskname])
    %     load(maskname)
    FBclear{f}.x=[];
    FBclear{f}.y=[];
    for j=1:length(FBdetected{f}.x)
        if imgmask(round(FBdetected{f}.y(j)),round(FBdetected{f}.x(j)))==1
            FBclear{f}.x=[FBclear{f}.x;FBdetected{f}.x(j)];
            FBclear{f}.y=[FBclear{f}.y;FBdetected{f}.y(j)];
        end
    end
    toc
    %%
    tic
    save('FBdetectdata_test','FBdetected','FBclear')
    toc
end
%%
