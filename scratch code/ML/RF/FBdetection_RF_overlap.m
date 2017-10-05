load('RBsample')
rgbimg=sampleimg;
for n=3:5
    [FBcellmask,centroids]=FBdetect_RFfun(rgbimg,n);
    N=2*n+1;
    save(['RBsample_',num2str(N)],'FBcellmask','centroids')
end
%%
sigma=20;
bg=imgaussfilt(single(rgbimg),sigma);
img_nobak=single(rgbimg)-bg;
img_nobak=img_nobak.*(img_nobak>0);
for n=3:5
    clf
    N=2*n+1;
    load(['RBsample_',num2str(N)])
    img_edge=bwperim(FBcellmask);
    h=imoverlay(uint8(img_nobak),img_edge,'w');
    imagesc(h)
    hold on, scatter(centroids(:,1),centroids(:,2),'w*')
    saveas(gcf,['RBsample_N_',num2str(N),'_nobak.fig'])
end