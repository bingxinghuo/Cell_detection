%% 1. read all the 2d histograms
% cd ~/marmosetRIKEN/NZ
dir0=pwd;
dirlist=dir('m*'); % generate a list of all brains to be processed
N2dall=cell(length(dirlist),1);
for d=1:length(dirlist)
    brainid=dirlist(d).name;
    maskdir=[dir0,'/',brainid,'/',brainid,'F/JP2/histograms'];
    if ~exist(maskdir) % skip brains without masks
        failcatch(d)=true;
    else
        cd(maskdir)
        histfile=[pwd,'/',brainid,'_histinfo.mat'];
        N2d=load(histfile,'N2d');
        N2dall{d}=N2d.N2d;
    end
end
%% 2. generate a matrix containing all brains' histograms
N2dall=N2dall(~cellfun('isempty',N2dall));
D=length(N2dall);
N2dallM=cell(3,1);
for c=1:3 % channel by channel
    N2dallM{c}.tot=[];
    for d=1:D
        % for now, consider only the total area of the image rather than the
        % brain section area
        N2dallM{c}.tot=[N2dallM{c}.tot;N2dall{d}{c}.tot];
    end
end
sectionid=[];
for d=1:D
    sectionid=[sectionid;ones(size(N2dall{d}{c}.tot,1),1)*[str2num(dirlist(d).name(2:4)),d]]; 
end
%% 3. visualize the entire histogram with brain id attached to the end
N2dX=histX{1}.tot(:,1);
N2dY=1:size(N2dallM{c}.tot,1);
sectionidM=zeros(size(N2dallM{1}.tot));
sectionidM(:,301:310)=sectionid(:,2)*ones(1,10);
colors={'red';'green';'blue'};
for c=1:3
    plotlog=log(N2dallM{c}.tot+sectionidM);
    plotlog(isinf(plotlog))=0;
    htot=pcolor(N2dX,N2dY,plotlog+sectionidM);
    set(htot, 'edgecolor','none')
    set(gca,'fontsize',14)
    xlabel('bit','fontsize',20)
    ylabel('section #','fontsize',20)
    title([num2str(D),' brains total area, ',colors{c}],'fontsize',20)
    saveas(gcf,['brains',num2str(D),'_hist_tot_',colors{c},'.fig'])
    close
end

