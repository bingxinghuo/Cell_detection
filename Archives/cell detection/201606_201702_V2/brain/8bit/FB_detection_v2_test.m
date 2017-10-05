%% 1. read in files
fid=fopen('filenames.txt');
filelist=textscan(fid,'%q');
fclose(fid);
filelist=filelist{1};
%% 1. define a moving window
win.width=500; % columns
win.height=400; % rows
win.hori=floor(size(fluoroimg,2)/win.width)+1; % steps to move in the horizontal direction
win.vert=floor(size(fluoroimg,1)/win.height)+1; % steps to move in the vertical direction
FBdetected.x=[];
FBdetected.y=[];
for v=1:win.vert % then move down
    for h=1:win.hori % first move horizontally
        imgtemp_rgb=fluoroimg((v-1)*win.height+1:min(v*win.height,size(fluoroimg,1)),(h-1)*win.width+1:min(h*win.width,size(fluoroimg,2)),:);
        imgtemp_mono=imgtemp_rgb(:,:,3);
        if (sum(sum(imgtemp_mono>100))>10) % if there are at least 10 pixels exceed the threshold of 100
            clf
            ax1=subplot(1,2,1);imshow(imgtemp_rgb); hold on
            ax2=subplot(1,2,2);imshow(imgtemp_mono); hold on
            linkaxes([ax1,ax2]);
            %             colormap gray
            imgfilt = imfilter(imgtemp_rgb,fspecial('gaussian',2*ceil(2*2)+1, 2));
            fluoroimg1=imgtemp_rgb-imgfilt;
%             Bimg=255./(1+exp(-(double(fluoroimg1(:,:,3))-240)/30));
            %% 2. convert to HSV
            hsvimg=rgb2hsv(fluoroimg1);
            hsvimg1=hsvimg;
            hsvimg1(:,:,3)=hsvimg1(:,:,3).*(hsvimg1(:,:,3)>.1);
            %             hsvimg1(:,:,1)=hsvimg1(:,:,1).*(hsvimg1(:,:,1)>.5 & hsvimg1(:,:,1)<.8);
            hsvimg1(:,:,1)=double(fluoroimg1(:,:,3)).*(fluoroimg1(:,:,3)>50);
            cellimg=hsvimg1(:,:,1).*hsvimg1(:,:,3);
            if sum(sum(cellimg))>0
                se=strel('disk',2);
                bwimg=cellimg>0;
                bwimg=imdilate(cellimg,se);
                bwimg=imfill(bwimg,'holes');
                bwimg=bwareaopen(bwimg,14);
                Bstat=regionprops(bwimg,'Centroid');
                centroids=cat(1,Bstat.Centroid);
                ptx=centroids(:,1)+(h-1)*win.width;
                pty=centroids(:,2)+(v-1)*win.height;
                scatter(ax1,centroids(:,1),centroids(:,2),'m*')
                scatter(ax2,centroids(:,1),centroids(:,2),'m*')
                FBdetected.x=[FBdetected.x;ptx];
                FBdetected.y=[FBdetected.y;pty];
                pause
            end
        end
    end
end

%%
