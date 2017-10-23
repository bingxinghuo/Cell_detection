function [N,X]=pixelhistview1(partialimg)
channels=size(partialimg,3);
%% transform to bits
partchannels=cell(channels,1);
for c=1:channels
    partchannels{c}=log2(single(partialimg(:,:,c)))+1; % log2(0)=-inf
end
% now the entire image ranges from 1 to 13, as well as -inf.
%% histograms
xbins=[0:.05:12]; % 12-bit image
% brain section area only
N=zeros(length(xbins),channels);
X=zeros(length(xbins),channels);
partpix=cell(channels,1);
for c=1:channels
    maptemp=nonzeros(partchannels{c}); % remove all 0's
    maptemp(isnan(maptemp))=inf; % change all nan to inf
    partpix{c}=maptemp(~isinf(maptemp))-1; % remove all inf's and scale back
    [N(:,c),X(:,c)]=hist(partpix{c},xbins);
end
%% visualize
% figure
nzindx=cell(channels,1);
for c=1:channels
    nzindx{c}=find(N(:,c)>0);
    if nzindx{c}(1)==1
        nzindx{c}=nzindx{c}(2:end); % do not plot 0
    end
    %     plot((X.tot(nzindx{c},c)),log(N.tot(nzindx{c},c)),colors{c})
    %     hold on
end
% hold off
if channels>1
    colors={'r';'g';'b'};
else
    colors={'k'};
end
% Panel 1
if channels>1
    subplot(1,channels+1,1)
end
% ct_shift=[-.05 0 .05];
for c=1:channels
    %     bar((X(nzindx{c},c))+ct_shift(c),log(N(nzindx{c},c)),'facecolor',colors{c},...
    %         'edgecolor','none','barwidth',5)
    semilogy((X(nzindx{c},c)),(N(nzindx{c},c)),colors{c})
    hold on
end
hold off
axis tight
ylabel('brain region # of pixels','fontsize',20)
ylims=get(gca,'ylim');
ylim([ylims(1),ylims(2)*10])
xlim([1 12])
set(gca,'XTick',[0:4:12])
set(gca,'fontsize',18)
% Panel 2:end
if channels>1
    for c=1:channels
        subplot(1,channels+1,1+c)
        %     bar((X(nzindx{c},c)),(N(nzindx{c},c)),'facecolor',colors{c},...
        %         'edgecolor',colors{c})
        semilogy((X(nzindx{c},c)),(N(nzindx{c},c)),colors{c})
        hold off
        xlim([1 12])
        ylim([ylims(1),ylims(2)*10])
        set(gca,'XTick',[0:4:12])
        xlabel('bit','fontsize',20)
        set(gca,'fontsize',18)
        title(colors{c},'fontsize',20)
    end
end