%% groundtruth selection
% load data
load('FBdetectdata.mat')
% 0. load image
fid=fopen('filenames.txt');
filelist=textscan(fid,'%q');
fclose(fid);
filelist=filelist{1};
sampleind=[50,100,150,200,250,300];
FN=cell(length(sampleind),1);
FP=FN;
frate=FN;
groundtruth=FN;
%%
for i=1:length(sampleind)
    f=sampleind(i);
    fileid=filelist{f};
    fluoroimg=imread(fileid,'jp2');
    % maskname=['imgmaskdata_',num2str(f)];
    % load(['imgmasks/',maskname])
    %% 1. define a moving window
    win.width=500; % columns
    win.height=400; % rows
    win.hori=floor(size(fluoroimg,2)/win.width)+1; % steps to move in the horizontal direction
    win.vert=floor(size(fluoroimg,1)/win.height)+1; % steps to move in the vertical direction
    FN{i}.x=[];
    FN{i}.y=[];
    FP{i}=FN{i};
    groundtruth{i}=FBclear{f};
    figure('Color',[0 0 0])
    for v=1:win.vert % then move down
        for h=1:win.hori % first move horizontally
            %%
            imgtemp_rgb=fluoroimg((v-1)*win.height+1:min(v*win.height,size(fluoroimg,1)),(h-1)*win.width+1:min(h*win.width,size(fluoroimg,2)),:);
            %         imgtemp_mask=imgmask((v-1)*win.height+1:min(v*win.height,size(fluoroimg,1)),(h-1)*win.width+1:min(h*win.width,size(fluoroimg,2)),:);
            imgtemp_mono=imgtemp_rgb(:,:,3);
            %         if sum(sum(imgtemp_mask))>0 % within the area of interest
            if (sum(sum(imgtemp_mono>100))>10) % if there are at least 10 pixels exceed the threshold of 100
                clf
                ax1=subplot(1,2,1);imshow(imgtemp_rgb)
                hold on
                groundmasky=(groundtruth{i}.y>(v-1)*win.height).*(groundtruth{i}.y<=min(v*win.height,size(fluoroimg,1)));
                groundmaskx=(groundtruth{i}.x>(h-1)*win.width).*(groundtruth{i}.x<=min(h*win.width,size(fluoroimg,1)));
                groundmask=groundmaskx.*groundmasky;
                ind=find(groundmask==1);
                if ~isempty(ind)
                    %             for i=1:length(ind)
                    %                 scatter(groundtruth{i}.x(ind(i))-(h-1)*win.width,groundtruth{i}.y(ind(i))-(v-1)*win.height,'m*')
                    %             end
                    scatter(groundtruth{i}.x(ind)-(h-1)*win.width,groundtruth{i}.y(ind)-(v-1)*win.height,'m*')
                end
                %  median filter
                imgtemp_mono=medfilt2(imgtemp_mono);
                % take logarithm
                imgtemp_log=log(double(imgtemp_mono));
                %             ax2=subplot(1,2,2);imshow(imgtemp_mono)
                ax2=subplot(1,2,2);imagesc(imgtemp_log)
                axis off; axis image; caxis([3 5])
                hold on
                %             for i=1:length(ind)
                %                 scatter(groundtruth{i}.x(ind(i))-(h-1)*win.width,groundtruth{i}.y(ind(i))-(v-1)*win.height,'m*')
                %             end
                if ~isempty(ind)
                    scatter(groundtruth{i}.x(ind)-(h-1)*win.width,groundtruth{i}.y(ind)-(v-1)*win.height,'m*')
                end
                linkaxes([ax1,ax2]);
                %             colormap gray
                %             istarget=input('Any target exist in this image? (y/n)','s');
                isFN=input('Any FALSE NEGATIVES in this image? (y/n)','s');
                %             if istarget=='y'
                if isFN=='y'
                    [ptx,pty]=getpts;
                    ptx=ptx+(h-1)*win.width;
                    pty=pty+(v-1)*win.height;
                    FN{i}.x=[FN{i}.x;ptx];
                    FN{i}.y=[FN{i}.y;pty];
                end
                if ~isempty(ind)
                    isFP=input('Any FALSE POSITIVES in this image? (y/n)','s');
                    if isFP=='y'
                        dcm_obj = datacursormode;
                        set(dcm_obj,'DisplayStyle','datatip','SnapToDataVertex','on','Enable','on')
                        selectfinish=input('Finished selection? (y/n) ','s');
                        if selectfinish=='y'
                            FPinfo=getCursorInfo(dcm_obj);
                            ptx=zeros(length(FPinfo),1);
                            pty=ptx;
                            for c=1:length(FPinfo)
                                ptx(c)=FPinfo(c).Position(1);
                                pty(c)=FPinfo(c).Position(2);
                            end
                            ptx=ptx+(h-1)*win.width;
                            pty=pty+(v-1)*win.height;
                            FP{i}.x=[FP{i}.x;ptx];
                            FP{i}.y=[FP{i}.y;pty];
                        end
                    end
                end
                %         pause
            end
        end
    end
    frate{i}.FP=length(FP{i}.x)/length(groundtruth{i}.x);
    frate{i}.FN=length(FN{i}.x)/length(groundtruth{i}.x);
end
save('FBdetectdata','sampleind','groundtruth','FP','FN','frate','-append')