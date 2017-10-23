dir0=pwd;
dirlist=dir('m9*');
for d=1:length(dirlist)
    brainid=dirlist(d).name;
    cd(brainid)
    histfile=[pwd,'/',brainid,'_histinfo.mat'];
    histdir=[pwd,'/histograms'];
    if exist(histfile)>0
        if ~exist(histdir)
            mkdir(histdir)
            copyfile(histfile,histdir);
        end
        cd(histdir)
        load(histfile)
        %%
        Nsec=length(histN);
        N2d=cell(3,1);
        for c=1:3
            N2d{c}.tot=zeros(Nsec,321);
            N2d{c}.brain=zeros(Nsec,321);
            for f=1:Nsec
                N2d{c}.tot(f,:)=histN{f}.tot(:,c);
                N2d{c}.brain(f,:)=histN{f}.brain(:,c);
            end
        end
        save(histfile,'N2d','-append')
        %%
        xgrid=histX{1}.tot(:,1);
        ygrid=1:Nsec;
        colors={'red';'green';'blue'};
        for c=1:3
            htot=pcolor(xgrid,ygrid,log(N2d{c}.tot));
            set(htot, 'edgecolor','none')
            set(gca,'fontsize',14)
            xlabel('bit','fontsize',20)
            ylabel('section #','fontsize',20)
            title([brainid,' total area, ',colors{c}],'fontsize',20)
            saveas(gcf,['hist_tot_',colors{c},'.fig'])
            close
            %
            hbrain=pcolor(xgrid,ygrid,log(N2d{c}.brain));
            set(hbrain, 'edgecolor','none')
            set(gca,'fontsize',14)
            xlabel('bit','fontsize',20)
            ylabel('section #','fontsize',20)
            title([brainid,' brain area, ',colors{c}],'fontsize',20)
            saveas(gcf,['hist_brain_',colors{c},'.fig'])
            close
        end
    end
    cd(dir0) % go back to the original directory
end