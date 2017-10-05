% slide=[120:158,214:293]; % m820
slide=15:195; % m851
% %% 3 read in files
% % cd('/Users/bingxinghuo/marmosetRIKEN/marmosetRIKEN/NZ/m820/m820F/JP2')
% fid=fopen('tiflist.txt');
fid=fopen('reg_files.txt');
filelist=textscan(fid,'%q');
fclose(fid);
filelist=filelist{1};
%%
% A=strfind(filelist,'F94');
% Aind=find(~cellfun(@isempty,A));
centroids=cell(length(slide),1);
FBimg=cell(length(slide),1);
%%
for f=1:length(slide)
    % for f=1
    % 1. read in slide of interest
    imgfile=filelist{slide(f)};
    %     fluoroimg=imread(imgfile,'jp2');
    fluoroimg=imread(imgfile,'tif');
    % 2. reduce file size to make it manageable
    %     fluoroimg1=imresize(fluoroimg,.2);
    fluoroimg1=fluoroimg(:,:,1:3);
    %     ax=figure; set(ax,'Position',[100 100 1049 600])
    %     ax1=subplot(1,2,1); imagesc(brighten(double(fluoroimg1),.5))
    %     axis image
    %% remove background noise
    %     if sum([22:106]==f)>0
    %     imgfilt=imgaussfilt(fluoroimg1,2);
    imgfilt = imfilter(fluoroimg1,fspecial('gaussian',2*ceil(2*2)+1, 2));
    fluoroimg1=fluoroimg1-imgfilt;
    %     end
    %% 2. convert to HSV
    hsvimg=rgb2hsv(fluoroimg1);
    hsvimg1=hsvimg;
    % 3. nonlinear filter hue and value maps
    %     if f>153
    hsvimg1(:,:,3)=hsvimg1(:,:,3).*(hsvimg1(:,:,3)>.3);
    %     else
    %     hsvimg1(:,:,3)=hsvimg1(:,:,3).*(hsvimg1(:,:,3)>.1);
    %     end
    hsvimg1(:,:,1)=hsvimg1(:,:,1).*(hsvimg1(:,:,1)>.5 & hsvimg1(:,:,1)<.8);
    % 4. composite to show cells
    cellimg=hsvimg1(:,:,1).*hsvimg1(:,:,3);
    if sum(sum(cellimg))>0
        %% 5. remove artifacts by hand
        %         ax2=subplot(1,2,2); imagesc(cellimg)
        %         axis image
        %         linkaxes([ax1,ax2],'xy')
        %     Noutliers=input('How many areas need to be manually removed? ');
        %     for n=1:Noutliers
        %         houtlier=imrect(gca);
        %         pos=getPosition(houtlier);
        %         yind=round([max(1,pos(1)),min(size(cellimg,2),pos(1)+pos(3))]);
        %         xind=round([max(1,pos(2)),min(size(cellimg,1),pos(2)+pos(4))]);
        %         cellimg(xind(1):xind(2),yind(1):yind(2))=0;
        %     end
        %% 6. detect cells
        %         subplot(1,2,2); imagesc(cellimg)
        %         axis image
        se=strel('disk',4);
        bwimg=cellimg>0;
        bwimg=imdilate(cellimg,se);
        bwimg=imfill(bwimg,'holes');
        bwimg=bwareaopen(bwimg,2);
        Bstat=regionprops(bwimg,'Centroid');
        centroids{f}=cat(1,Bstat.Centroid);
        %         subplot(1,2,1); hold on, scatter(centroids{f}(:,1),centroids{f}(:,2),'mo')
        %         subplot(1,2,2); hold on, scatter(centroids{f}(:,1),centroids{f}(:,2),'mo')
        %         linkaxes([ax1,ax2],'xy')
        %% 7. create a map to save
        FBimg{f}=zeros(size(fluoroimg1));
        FBbw=zeros(size(cellimg));
        for c=1:size(centroids{f},1)
            FBbw(round(centroids{f}(c,2)),round(centroids{f}(c,1)))=1;
        end
        FBbw=imdilate(FBbw,se);
        FBimg{f}(:,:,3)=FBbw;
        %         figure
        %         h=imagesc(FBimg{f}); axis image
        %             saveas(h,['m851_FBv2_',num2str(slide(f))],'tif')
        %         saveas(h,['m820_FB_',num2str(slide(f))],'tif')
        %         close all
    end
end
save('FBcells_strict','FBimg','centroids','slide','-v7.3')
%% Visualization
load FBcells
load injROI
injROI=ROIinfo;
load outlineROI
allROI=ROIinfo;
% FBimg_all=cell(280,1);
for f=1:280
    %     if sum(slide==f)==0
    %         %             FBimg_all{f}=zeros(2768,3000,3);
    %         FBimg_temp=zeros(2768,3000,3);
    %         figure('visible','off')
    %         %             h=imagesc(FBimg_all{f}); axis image; axis off
    %         h=imagesc(FBimg_temp); axis image; axis off
    %         saveas(h,['m851_FBv3_',num2str(f)],'tif')
    %
    %     else
    if sum(slide==f)==1
        %         FBimg_all{f}=FBimg{f-slide(1)+1};
        FBimg_temp=FBimg{f-slide(1)+1}.*allROI.ROImap;
        if f>=37 && f<=66
            %             if sum(sum(FBimg_all{f}(:,:,3).*ROIinfo.ROImap(:,:,3)))>1
            %                 FBimg_all{f}(:,:,1)=FBimg_all{f}(:,:,3).*ROIinfo.ROImap(:,:,3);
            %             end
            if sum(sum(FBimg_temp(:,:,3).*injROI.ROImap(:,:,3)))>1
                FBimg_temp(:,:,1)=FBimg_temp(:,:,3).*injROI.ROImap(:,:,3);
            end
        end
        figure('visible','off')
        %         h=imagesc(FBimg_all{f}); axis image; axis off
        h=imagesc(FBimg_temp); axis image; axis off
        saveas(h,['m851_FBv3_',num2str(f)],'tif')
        
    end
    % imwrite(FBimg_all{f}, 'FBimg_stack.tiff', 'WriteMode', 'append',  'Compression','none');
end