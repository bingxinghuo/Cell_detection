%% 1. read in files
fid=fopen('filenames.txt');
filelist=textscan(fid,'%q');
fclose(fid);
filelist=filelist{1};
%%
A=strfind(filelist,'F106');
Aind=find(~cellfun(@isempty,A));
% for f=1:length(filelist)
f=Aind;
fileid=filelist{f};
fluoroimg=imread(fileid,'jp2');
%% 1. define a moving window
win.width=500; % columns
win.height=400; % rows
win.hori=floor(size(fluoroimg,2)/win.width)+1; % steps to move in the horizontal direction
win.vert=floor(size(fluoroimg,1)/win.height)+1; % steps to move in the vertical direction
FBdetected.x=[];
FBdetected.y=[];
%%
for v=1:win.vert % then move down
    for h=1:win.hori % first move horizontally
        imgtemp_rgb=fluoroimg((v-1)*win.height+1:min(v*win.height,size(fluoroimg,1)),(h-1)*win.width+1:min(h*win.width,size(fluoroimg,2)),:);
        if (sum(sum(imgtemp_rgb(:,:,3)>100))>10) % if there are at least 10 pixels exceed the threshold of 100
            imgtemp_mono=imgtemp_rgb(:,:,3)-max(imgtemp_rgb(:,:,1),imgtemp_rgb(:,:,2));
            %  median filter
            imgtemp_mono=medfilt2(imgtemp_mono);
            % Color selection
            hsvimg=rgb2hsv(imgtemp_rgb);
            bluemask=hsvimg(:,:,1)>.5 & hsvimg(:,:,1)<.8;
            imgtemp_mono=double(imgtemp_mono).*bluemask;
            % take logarithm
            imgtemp_log=log(double(imgtemp_mono));
            %% visualize
            clf
            ax1=subplot(1,2,1);imshow(imgtemp_rgb); hold on
            %             ax2=subplot(1,2,2);imshow(imgtemp_mono); hold on
            ax2=subplot(1,2,2);imagesc(imgtemp_log); hold on
            axis image; axis off; caxis([3 5])
            linkaxes([ax1,ax2]);
            %% Morphological operations
            % 1. threshold
            bwimg=imgtemp_log>max(max(max(imgtemp_log))*.7,3);
%                                     bwimg=imgtemp_log>3.5;
            % 2. clear up
            initial_clear=5;
            bwimg=bwareaopen(bwimg,initial_clear);
            % 3. dilate
            se_dia=1;
            se=strel('disk',se_dia);
            bwimg=imdilate(bwimg,se);
            % 4. close
            bwimg=imfill(bwimg,'holes');
            % 5. clear up again
            final_clear=initial_clear*se_dia;
            bwimg=bwareaopen(bwimg,final_clear);
            % 6. find the centroids
            Bstat=regionprops(bwimg,'Centroid');
            centroids=cat(1,Bstat.Centroid);
            if ~isempty(centroids)
                ptx=centroids(:,1)+(h-1)*win.width;
                pty=centroids(:,2)+(v-1)*win.height;
                scatter(ax1,centroids(:,1),centroids(:,2),'m*')
                scatter(ax2,centroids(:,1),centroids(:,2),'m*')
                FBdetected.x=[FBdetected.x;ptx];
                FBdetected.y=[FBdetected.y;pty];
            end
            pause
        end
    end
end

%%
