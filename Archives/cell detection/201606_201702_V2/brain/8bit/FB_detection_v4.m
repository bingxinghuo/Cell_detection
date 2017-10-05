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
for f=1:length(filelist)
    fileid=filelist{f};
    fluoroimg=imread(fileid,'jp2');
    %% 1. define a moving window
    win.width=500; % columns
    win.height=400; % rows
    win.hori=floor(size(fluoroimg,2)/win.width)+1; % steps to move in the horizontal direction
    win.vert=floor(size(fluoroimg,1)/win.height)+1; % steps to move in the vertical direction
    FBdetected{f}.x=[];
    FBdetected{f}.y=[];
    %
    for v=1:win.vert % then move down
        for h=1:win.hori % first move horizontally
            imgtemp_rgb=fluoroimg((v-1)*win.height+1:min(v*win.height,size(fluoroimg,1)),(h-1)*win.width+1:min(h*win.width,size(fluoroimg,2)),:);
            % if there are interesting cells in the image
            if (sum(sum(imgtemp_rgb(:,:,3)>100))>10) % if there are at least 10 pixels exceed the threshold of 100
                % generate the background
                imgfilt=imgaussfilt(imgtemp_rgb,10);
%                 imgfilt = imfilter(imgtemp_rgb,fspecial('gaussian',2*ceil(2*10)+1, 10));
                % remove background/saturation
                imgtemp_nobak=imgtemp_rgb-imgfilt;
                % if there is saturation in the image
                if (sum(sum(imgtemp_rgb(:,:,3)==255))>100)
                    
                    % create the mask for saturated area
                    satumask=imgfilt(:,:,3)>240;
                    %% 1. saturated area
                    imgtemp_sat=double(imgtemp_nobak).*cat(3,satumask,satumask,satumask);
                    % there should not be useful information in the interest channel. Ignore.
                    imgsat=imgtemp_sat(:,:,1)+imgtemp_sat(:,:,2);
                    centroids=celldetect(imgsat,imgtemp_rgb);
                    if ~isempty(centroids)
                        ptx=centroids(:,1)+(h-1)*win.width;
                        pty=centroids(:,2)+(v-1)*win.height;
                        % visualize
                                            scatter(centroids(:,1),centroids(:,2),'m*')
                        % save data
                        FBdetected{f}.x=[FBdetected{f}.x;ptx];
                        FBdetected{f}.y=[FBdetected{f}.y;pty];
                    end
                                    % pause
                    %% 2. unsaturated area
                    imgtemp_unsat=double(imgtemp_nobak(:,:,3)).*(1-satumask);
                    %                 imgtemp_rgb_unsat=double(imgtemp_rgb).*cat(3,1-satumask,1-satumask,1-satumask);
                    centroids=celldetect(imgtemp_unsat,imgtemp_rgb);
                    if ~isempty(centroids)
                        ptx=centroids(:,1)+(h-1)*win.width;
                        pty=centroids(:,2)+(v-1)*win.height;
                        % visualize
                                            scatter(centroids(:,1),centroids(:,2),'m*')
                        % save data
                        FBdetected{f}.x=[FBdetected{f}.x;ptx];
                        FBdetected{f}.y=[FBdetected{f}.y;pty];
                    end
                else % no saturation in the image
                    %
                    imgtemp_mono=imgtemp_nobak(:,:,3)-max(imgtemp_nobak(:,:,1),imgtemp_nobak(:,:,2));
                    centroids=celldetect(imgtemp_mono,imgtemp_rgb);
                    if ~isempty(centroids)
                        ptx=centroids(:,1)+(h-1)*win.width;
                        pty=centroids(:,2)+(v-1)*win.height;
                        % visualize
                                            scatter(centroids(:,1),centroids(:,2),'m*')
                        % save data
                        FBdetected{f}.x=[FBdetected{f}.x;ptx];
                        FBdetected{f}.y=[FBdetected{f}.y;pty];
                    end
                end
                        pause
            end
        end
    end
%     save('FBdetectdata','FBdetected')
end
%%
