%% get a ballpark number
FB_AC=cell(172-87+1,1);
for k=87:172
    if ~isempty(FBclear{k})
        totcellnum=size(FBclear{k},1);
        FBclear{k}=round(FBclear{k});
        n=1;
        for c=1:totcellnum
            x=FBclear{k}(c,1);
            y=FBclear{k}(c,2);
            if ROImap(FBclear{k}(c,2),FBclear{k}(c,1))==1 % if the cell is within the rough ROI
                FB_AC{k-87+1}(n,:)=FBclear{k}(c,:);
                n=n+1;
            end
        end
    end
end
autocount=zeros(79,1);
for k=1:79
    autocount(k)=size(FB_AC{k},1);
end
sum(autocount)
%%
fid=fopen('filenames.txt');
filelist=textscan(fid,'%q');
fclose(fid);
filelist=filelist{1};
%%
% mancount=zeros(172-87+1,2);
% for f=87:172
for f=166:172
    if ~isempty(FB_AC{f-86})
        fileid=filelist{f};
        disp(['Processing ',fileid])
        %         tic
        maskname=['imgmasks/imgmaskdata_',num2str(f),'.mat'];
        imgmask=load(maskname);
        imgmask=imgmask.savedata;
        
        %     fluoroimg=imread(fileid,'jp2');
        %     clf, imagesc(fluoroimg)
        clf, imagesc(imgmask)
        hold on, scatter(FB_AC{f-86}(:,1),FB_AC{f-86}(:,2),'m*')
        %         toc
        pause
        if f<93
            mancount(f-86,1)=input('How many cells in the RH AC?: ');
            mancount(f-86,2)=0;
        elseif f>164
            mancount(f-86,1)=0;
            mancount(f-86,2)=input('How many cells in the LH AC?: ');
        else
            mancount(f-86,1)=input('How many cells in the RH AC?: ');
            mancount(f-86,2)=input('How many cells in the LH AC?: ');
        end
    end
end
