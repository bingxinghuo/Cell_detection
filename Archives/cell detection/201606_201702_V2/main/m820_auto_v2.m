% parpool local
%% 1. pre-define slides that contains labeled neurons for each channel
% use these code to find the index of the slides:
% A=strfind(filelist,'F94');
% Aind=find(~cellfun(@isempty,A));
slide{1}=73:144;
slide{2}=180:290;
slide{3}=[150:158,228:300];
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
cd('/Users/bingxinghuo/marmosetRIKEN/marmosetRIKEN/NZ/m820/m820F/JP2')
fid=fopen('sorted-M820F.txt');
filelist=textscan(fid,'%q');
fclose(fid);
filelist=filelist{1};
%%
neurons=cell(1,3);
processes=cell(1,3);
for Nchannel=1:3
    neurons{Nchannel}=cell(1,length(slide{Nchannel}));
    processes{Nchannel}=cell(1,length(slide{Nchannel}));
end

%%
% neurons=cell(300,1);
% processes=cell(300,1);
% E=cell(300,1);
n=1;
for Nchannel=1:3 % select channel
    for i=1:length(slide{Nchannel})
        % for i=1:300
        try
            %         islabel=zeros(1,3);
            %         for Nchannel=1:3 % select channel
            %             issignal=find(slide{Nchannel}==i);
            %             if ~isempty(issignal)
            %                 islabel(Nchannel)=issignal;
            %             end
            %         end
            %         if ~isempty(islabel)
            %             ichannel=find(islabel);
            % 1. read in slide of interest
            imgfile=filelist{slide{Nchannel}(i)};
            %         neurons.channels=ichannel;
            %             for Nchannel=1:length(ichannel) % select channel
            %                 imgfile=filelist{i};
            fluoroimg=imread(imgfile,'jp2');
            channelimg=fluoroimg(:,:,Nchannel);
            % 2. Crop: each channel has a distinct ROI
            channelcrop=channelimg(ROI{Nchannel,1},ROI{Nchannel,2});
            %
            %                 channelimg=fluoroimg(:,:,ichannel(Nchannel));
            [neurons{Nchannel}{i}, processes{Nchannel}{i}]=neuroncount_v3(channelcrop,Nchannel);
            
            %                 [neurons{i}{ichannel(Nchannel)}, processes{i}{ichannel(Nchannel)}]=neuroncount_v3(channelimg,ichannel(Nchannel));
            
            %             end
            %         else
            %         neurons.channels=NaN;
            %         processes.channels=NaN;
            
            
            %         end
            
        catch le
            
            if ~isempty(le)
                E{n}.error=le;
                E{n}.file=imgfile;
                n=n+1;
                %                     t = getCurrentTask();
                %         myLogFile= sprintf( 'log.%d.txt', t.ID );
            end
            
        end
        save('labeldata1','neurons','processes','-v7.3')
        save('re_process1','E')
        
    end
    
end
% exit