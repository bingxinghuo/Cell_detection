% load('../sampleimgdata')
load('../centimgdata')
% nrange=[3:6];
nrange=6;
for s=1:2
    rgbimg=centimg{s};
    for n=nrange
        [FBcellmask,centroids]=FBdetect_RFfun(rgbimg,n);
        N=2*n+1;
        save(['sample',num2str(s),'result_',num2str(N)],'FBcellmask','centroids')
    end
end
%%
% nrange=[3:6];
for s=1:2
    rgbimg=sampleimg{s};
    for n=nrange
        clf
        N=2*n+1;
        load(['sample',num2str(s),'result_',num2str(N)])
        img_edge=bwperim(FBcellmask);
        h=imoverlay(uint8(rgbimg),img_edge,'r');
        imagesc(h)
        hold on, scatter(centroids(:,1),centroids(:,2),'w*')
        saveas(gcf,['sample',num2str(s),'N_',num2str(N),'.fig'])
    end
end