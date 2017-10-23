%% load images
originimg{1}=imread('B001-F61--_3_0183_8bit.jp2');
originimg{2}=imread('B001-F61--_3_0183_16bit.jp2');
load('imgmaskdata_109.mat')
%%
[N{1},X{1}]=pixelhistview(originimg{1},imgmask);
[N{2},X{2}]=pixelhistview(originimg{2},imgmask);
%% visualize
% show image
channels={'Red','Green','Blue'};
[rows,cols]=size(squeeze(originimg{1}(:,:,1)));
figure, subplot(3,4,1);
imshow(originimg{1})
for c=1:3
    subplot(3,4,c+1)
    channelimg{c}=zeros(rows,cols,3,'uint8');
    channelimg{c}(:,:,c)=uint8(originimg{1}(:,:,c));
    imshow(channelimg{c})
    title(channels{c},'fontsize',18)
end
%%
colors={'r';'g';'b'};
for b=1:2
    nzindx=cell(3,1);
    subplot(3,4,4*b+1)
    for c=1:3
        nzindx{c}=find(N{b}.brain(:,c)>0);
        if nzindx{c}(1)==1
            nzindx{c}=nzindx{c}(2:end); % do not plot 0
        end
        %     plot((X.tot(nzindx{c},c)),log(N.tot(nzindx{c},c)),colors{c})
        %     hold on
    end
    % hold off
    % ct_shift=[-.05 0 .05];
    for c=1:3
        %     bar((X.brain(nzindx{c},c))+ct_shift(c),log(N.brain(nzindx{c},c)),'facecolor',colors{c},...
        %         'edgecolor','none','barwidth',5)
        %     semilogy((X{b}.brain(nzindx{c},c))+ct_shift(c),(N{b}.brain(nzindx{c},c)),colors{c})
        semilogy((X{b}.brain(nzindx{c},c)),(N{b}.brain(nzindx{c},c)),colors{c})
        hold on
    end
    hold off
    % axis tight
    % ylabel('brain region # of pixels','fontsize',20)
    ylims=get(gca,'ylim');
    ylim([ylims(1),ylims(2)*10])
    xlim([1 16])
    set(gca,'XTick',[0:4:16])
    set(gca,'fontsize',18)
    for c=1:3
        subplot(3,4,4*b+1+c)
        %     bar((X.brain(nzindx{c},c)),(N.brain(nzindx{c},c)),'facecolor',colors{c},...
        %         'edgecolor',colors{c})
        semilogy((X{b}.brain(nzindx{c},c)),(N{b}.brain(nzindx{c},c)),colors{c})
        hold off
        xlim([1 16])
        ylim([ylims(1),ylims(2)*10])
        set(gca,'XTick',[0:4:16])
        %     xlabel('bit','fontsize',20)
            set(gca,'fontsize',18)
        %     title(colors{c},'fontsize',20)
    end
end