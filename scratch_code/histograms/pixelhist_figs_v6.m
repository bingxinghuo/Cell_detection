%% pixelhist_figs_v6.m
% This script reads the jp2 images within the directory and generate
% histograms for individual channels. The histogram information for all the
% images is stored in a common file called ****_histinfo.mat.
global bitinfo
cd ~/marmosetRIKEN/NZ
dir0=pwd;
dirlist=dir('m*');
for d=1:length(dirlist)
    cd([dirlist(d).name,'/',dirlist(d).name,'F/JP2'])
    fid=fopen('filenames.txt');
    filelist=textscan(fid,'%q');
    fclose(fid);
    filelist=filelist{1};
    Nfiles=length(filelist);
    if ~exist([pwd,'/imgmasks/'])
        mkdir('imgmasks')
    end
    histname=[filelist{1}(1:4),'_histinfo.mat'];
    if ~exist([pwd,'/',histname])
        fileinfo=imfinfo(filelist{1});
        
        if isequal(fileinfo.BitsPerSample,[16 16 16])
            bitinfo=12;
            %         if exist([pwd,'/imgmasks'],'dir')==7
            %             maskfiles=dir('imgmasks/*.mat');
            %         else
            %             mkdir('imgmasks')
            %             maskfiles=[];
            %         end
            failcatch=zeros(length(filelist),1);
            parfor f=1:Nfiles
                try
                    % load image
                    fileid=filelist{f};
                    fluoroimg=imread(fileid,'jp2');
                    maskname=['imgmasks/imgmaskdata_',num2str(f),'.mat'];
                    % load/generate brain section mask (note: there are errors in some images)
                    if exist([pwd,'/',maskname],'file')==2
                        %                 maskid=maskfiles(f).name;
                        %                 imgmask=load(['imgmasks/',maskid]);
                        % imgmask=imgmask.savedata;
                        imgmask=load(maskname);
                        maskvar=fieldnames(imgmask);
                        imgmask=getfield(imgmask,maskvar{1});
                    else
                        imgmask=brainmaskfun_reg_lowRAM(fluoroimg);
                        masktot=sum(sum(imgmask));
                        [rows,cols]=size(imgmask);
                        if masktot<rows*cols*.8 % if the mask area fills morethan 80% of the whole image
                            parsave(maskname,imgmask)
                        else
                            warnmsg=['Mask generation failed for Image ',num2str(f),'!'];
                            warning(warnmsg)
                            failcatch(f)=1;
                            continue
                        end
                    end
                    % apply the brain section mask and restrict the following analysis
                    % within this area
                    %             [rgbimg,~,~]=maskadj_reg(fluoroimg,imgmask);
                    rgbimg=single(fluoroimg).*cat(3,imgmask,imgmask,imgmask);
                    %             [rows,cols]=size(rgbimg);
                    %% transform to bits
                    originchannels=cell(3,1);
                    for c=1:3
                        originchannels{c}=log2(single(rgbimg(:,:,c)))+1;
                    end
                    %% histograms
                    xbins=[0:.05:16];
                    % brain
                    N{f}=zeros(length(xbins),3);
                    X{f}=zeros(length(xbins),3);
                    brainpix=cell(3,1);
                    for c=1:3
                        maptemp=nonzeros(originchannels{c}); % remove all 0's
                        maptemp(isnan(maptemp))=inf; % change all nan to inf
                        brainpix{c}=maptemp(~isinf(maptemp))-1; % remove all inf's and scale back
                        [N{f}(:,c),X{f}(:,c)]=hist(brainpix{c},xbins);
                    end
                    %     %% visualize
                    %     % show image
                    %     channels={'Red','Green','Blue'};
                    %     originimg16=uint16(rgbimg.*2^(16-12));
                    %     % figure
                    %     subplot(2,4,1);
                    %     imshow(originimg)
                    %     channelimg=cell(3,1);
                    %     for c=1:3
                    %         subplot(2,4,c+1)
                    %         channelimg{c}=zeros(rows,cols,3,'uint8');
                    %         channelimg{c}(:,:,c)=originimg(:,:,c);
                    %         imshow(channelimg{c})
                    %         title(channels{c},'fontsize',18)
                    %     end
                    %     %
                    %     colors={'r','g','b'};
                    %     %
                    %     % nzindx=cell(3,1);
                    %     % subplot(3,4,4+1)
                    %     % for c=1:3
                    %     %     nzindx{c}=find(N.tot(:,c)>0);
                    %     %     if nzindx{c}(1)==1
                    %     %         nzindx{c}=nzindx{c}(2:end); % do not plot 0
                    %     %     end
                    %     %     plot((X.tot(nzindx{c},c)),log(N.tot(nzindx{c},c)),colors{c})
                    %     %     hold on
                    %     % end
                    %     % hold off
                    %     % ylabel('total vs. background pixels','fontsize',12)
                    %     % axis tight
                    %     % ylims=get(gca,'ylim');
                    %     % xlim([1 12])
                    %     % set(gca,'XTick',[0:4:12])
                    %     % for c=1:3
                    %     %     subplot(3,4,4+1+c)
                    %     %     plot((X.tot(nzindx{c},c)),log(N.tot(nzindx{c},c)),colors{c})
                    %     %     hold on
                    %     % %     plot((X{f}(nzindx{c},c)),log(N{f}(nzindx{c},c)),colors{c})
                    %     %     plot((X.bg(nzindx{c},c)),log(N.bg(nzindx{c},c)),[colors{c},':'])
                    %     %     hold off
                    %     % ylim(ylims)
                    %     % xlim([0 12])
                    %     % set(gca,'XTick',[0:4:12])
                    %     % end
                    %     % legend('tot','bg','location','northoutside')
                    %     %
                    %     subplot(3,4,4*2+1)
                    %     for c=1:3
                    %         %     bar((X{f}(nzindx{c},c))+ct_shift(c),(N{f}(nzindx{c},c)),'facecolor',colors{c},...
                    %         %         'edgecolor','none','barwidth',5)
                    %         plot((X{f}(nzindx{c},c)),log(N{f}(nzindx{c},c)),colors{c})
                    %         hold on
                    %     end
                    %     hold off
                    %     axis tight
                    % %     ylabel('brain region # of pixels','fontsize',12)
                    %     ylims=get(gca,'ylim');
                    %     xlim([1 12])
                    %     xlabel('bit','fontsize',15)
                    %     set(gca,'XTick',[0:4:12])
                    %     for c=1:3
                    %         nzindx{c}=find(N{f}(:,c)>0);
                    %         if nzindx{c}(1)==1
                    %             nzindx{c}=nzindx{c}(2:end); % do not plot 0
                    %         end
                    %         subplot(2,4,4+1+c)
                    %         %     bar((X{f}(nzindx{c},c)),(N{f}(nzindx{c},c)),'facecolor',colors{c},...
                    %         %         'edgecolor',colors{c})
                    %         plot((X{f}(nzindx{c},c)),log(N{f}(nzindx{c},c)),colors{c})
                    %         hold off
                    %         xlim([1 12])
                    %         ylim(ylims)
                    %         set(gca,'XTick',[0:4:12])
                    %         xlabel('bit','fontsize',15)
                    %     end
                    %     %
                    %     saveas(gcf,[fileid,'_channelhist'],'png')
                    %     saveas(gcf,[fileid,'_channelhist'],'fig')
                catch ME
                    f
                    failcatch(f)=1;
                    rethrow(ME)
                end
            end
            save(histname,'N','X')
            save('failmasks.mat','failcatch')
        end
    end
    cd(dir0) % go back to the original directory
end