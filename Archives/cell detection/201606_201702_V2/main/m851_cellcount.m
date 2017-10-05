fid=fopen('reg_files.txt');
filelist=textscan(fid,'%q');
fclose(fid);
filelist=filelist{1};
%%
fluoroimg3d=zeros(512,512,3,280);
for f=1:length(slide)
     imgfile=filelist{f};
     fluoroimg=imread(imgfile,'tif');
     fluoroimg3d(:,:,:,f)=fluoroimg(:,:,1:3);
end
meanint.x=mean(fluoroimg3d,1);
meanint.y=mean(fluoroimg3d,2);
meanint.z=mean(fluoroimg3d,4);
save('meanproj','meanint','fluoroimg3d','-v7.3')
      %% remove background noise
%       imgfilt=imgaussfilt(fluoroimg1,2);
%       imgfilt = imfilter(fluoroimg1,fspecial('gaussian',2*ceil(2*2)+1, 2));
%     fluoroimg1=fluoroimg1-imgfilt;
     %% 2. convert to HSV
%     hsvimg=rgb2hsv(fluoroimg1);
     % 3. nonlinear filter hue and value maps
    % Blue
%      hsvimg_blue(:,:,1)=hsvimg(:,:,1).*(hsvimg(:,:,1)>.5 & hsvimg(:,:,1)<.8);
%      hsvimg_blue(:,:,3)=hsvimg(:,:,3).*(hsvimg(:,:,3)>.1);
% %      hsvimg_blue(:,:,2)=hsvimg(:,:,2);
%      % Red
%      hsvimg_red(:,:,1)=hsvimg(:,:,1).*(hsvimg(:,:,1)>.85 | hsvimg(:,:,1)<.3);
%      hsvimg_red(:,:,3)=hsvimg(:,:,3).*(hsvimg(:,:,3)>.1);
% %      hsvimg_red(:,:,2)=hsvimg(:,:,2);
%     % Green
%      hsvimg_green(:,:,1)=hsvimg(:,:,1).*(hsvimg(:,:,1)>.15 & hsvimg(:,:,1)<.45);
%      hsvimg_green(:,:,3)=hsvimg(:,:,3).*(hsvimg(:,:,3)>.1);
% %      hsvimg_green(:,:,2)=hsvimg(:,:,2);
%      %%
%      tracers.red=hsvimg_red(:,:,1).*hsvimg_red(:,:,3);
%      tracers.green=hsvimg_green(:,:,1).*hsvimg_green(:,:,3);
%      tracers.blue=hsvimg_blue(:,:,1).*hsvimg_blue(:,:,3);