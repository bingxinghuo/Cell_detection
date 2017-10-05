%% 1. pre-define slides that contains labeled neurons for each channel
% use these code to find the index of the slides:
% A=strfind(filelist,'F94');
% Aind=find(~cellfun(@isempty,A));
slide{1}=73:144;
slide{2}=[150:158,228:300];
slide{3}=180:290;
%% 2. pre-define ROI for each channel
% ROI{1,1}=1001:15000; % x coordinates for red channel
ROI{1,1}=1001:14000; % x coordinates for red channel
ROI{1,2}=2001:22000; % y coordintates for red channel
ROI{2,1}=3000:10000; % x coordinates for green channel
ROI{2,2}=3000:8000; % y coordintates for green channel
% ROI{3,1}=1101:14763; % x coordinates for blue channel
ROI{3,1}=1101:14700; % x coordinates for blue channel
ROI{3,2}=2001:14288; % y coordintates for blue channel
%% read in files
cd('/Users/bingxinghuo/marmosetRIKEN/marmosetRIKEN/JP2/m820/m820F/JP2')
fid=fopen('sorted-M820F.txt');
filelist=textscan(fid,'%q');
fclose(fid);
filelist=filelist{1};
%
% neurons=cell(1,3);
% processes=cell(1,3);
%%
for Nchannel=1:3 % select channel
    for i=1:length(slide{Nchannel})
        % 1. read in slide of interest
        imgfile=filelist{slide{Nchannel}(i)};
        fluoroimg=imread(imgfile,'jp2');
        channelimg=fluoroimg(:,:,Nchannel);
        % 2. Crop: each channel has a distinct ROI
        channelcrop=channelimg(ROI{Nchannel,1},ROI{Nchannel,2});
        %
        [neurons{Nchannel}{i}, processes{Nchannel}{i}]=neuroncount_v3(channelcrop,Nchannel);
        save('labeldata','neurons','processes','-v7.3')
    end
    
end