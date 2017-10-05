function varargout=pixelhistview(originimg,imgmask)
%% transform to bits
originchannels=cell(3,1);
parfor c=1:3
    originchannels{c}=log2(single(originimg(:,:,c)))+1; % log2(0)=-inf
end
% now the entire image ranges from 1 to 13, as well as -inf.
%% further restrict image mask
channelmask=cell(3,1);
parfor c=1:3
    channelmask{c}=single(imgmask).*(originchannels{c}~=-inf); % remove 0's in the original image
end
% now the brain section area is 1, the backround is 0
%% histograms
xbins=[0:.05:16]; % 12-bit image
% brain section area only
N.brain=zeros(length(xbins),3);
X.brain=zeros(length(xbins),3);
brainpix=cell(3,1);
for c=1:3
    maptemp=nonzeros(originchannels{c}.*channelmask{c}); % remove all 0's
    maptemp(isnan(maptemp))=inf; % change all nan to inf
    brainpix{c}=maptemp(~isinf(maptemp))-1; % remove all inf's and scale back
    [N.brain(:,c),X.brain(:,c)]=hist(brainpix{c},xbins);
end
% whole image area
N.tot=zeros(length(xbins),3);
X.tot=zeros(length(xbins),3);
brainpix=cell(3,1);
for c=1:3
    maptemp=nonzeros(originchannels{c}); % remove all 0's
    maptemp(isnan(maptemp))=inf; % change all nan to inf
    brainpix{c}=maptemp(~isinf(maptemp))-1; % remove all inf's and scale back
    [N.tot(:,c),X.tot(:,c)]=hist(brainpix{c},xbins);
end
%% 
if nargout>0
    varargout{1}=N;
    varargout{2}=X;
end
%% visualize
% colors={'r';'g';'b'};
% figure
% nzindx=cell(3,1);
% subplot(1,4,1)
% for c=1:3
%     nzindx{c}=find(N.brain(:,c)>0);
%     if nzindx{c}(1)==1
%         nzindx{c}=nzindx{c}(2:end); % do not plot 0
%     end
%     %     plot((X.tot(nzindx{c},c)),log(N.tot(nzindx{c},c)),colors{c})
%     %     hold on
% end
% % hold off
% ct_shift=[-.05 0 .05];
% for c=1:3
%     %     bar((X.brain(nzindx{c},c))+ct_shift(c),log(N.brain(nzindx{c},c)),'facecolor',colors{c},...
%     %         'edgecolor','none','barwidth',5)
%     semilogy((X.brain(nzindx{c},c))+ct_shift(c),(N.brain(nzindx{c},c)),colors{c})
%     hold on
% end
% hold off
% axis tight
% ylabel('brain region # of pixels','fontsize',20)
% ylims=get(gca,'ylim');
% ylim([ylims(1),ylims(2)*10])
% xlim([1 12])
% set(gca,'XTick',[0:4:12])
% set(gca,'fontsize',18)
% for c=1:3
%     subplot(1,4,1+c)
%     %     bar((X.brain(nzindx{c},c)),(N.brain(nzindx{c},c)),'facecolor',colors{c},...
%     %         'edgecolor',colors{c})
%     semilogy((X.brain(nzindx{c},c)),(N.brain(nzindx{c},c)),colors{c})
%     hold off
%     xlim([1 12])
%     ylim([ylims(1),ylims(2)*10])
%     set(gca,'XTick',[0:4:12])
%     xlabel('bit','fontsize',20)
%     set(gca,'fontsize',18)
%     title(colors{c},'fontsize',20)
% end