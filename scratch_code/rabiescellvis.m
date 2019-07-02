%% tilewise visualization
r=6;
c=4;
L=size(cellannotile{r,c},1);
hitscore=zeros(L,1);
for l=1:L
    hitscore(l)=cellmask1{r,c}(cellannotile{r,c}(l,1),cellannotile{r,c}(l,2));
end
sum(hitscore)/L
misspt=find(hitscore==0);
%%
h=imoverlay(imgtile{r,c},cellmask1{r,c});
figure(1), imagesc(h); axis image; ax1=gca;
hold on, scatter(cellannotile{r,c}(:,2),cellannotile{r,c}(:,1),'ro')
hold on, scatter(cellannotile{r,c}(misspt,2),cellannotile{r,c}(misspt,1),'b*')
figure(2), imagesc(imgtile{r,c}); colormap gray; axis image; ax2=gca;
hold on, scatter(cellannotile{r,c}(:,2),cellannotile{r,c}(:,1),'ro')
linkaxes([ax1,ax2]);