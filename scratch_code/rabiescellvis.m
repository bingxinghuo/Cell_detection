[R,C]=size(cellmask);
TPFP=zeros(R,C);
TPFN=zeros(R,C);
TPlabels=cell(R,C);
recalls=zeros(R,C);
for r=1:R
    for c=1:C
        if sum(sum(cellmask{r,c}))>0
        cc=bwconncomp(cellmask{r,c});
        L=labelmatrix(cc);
        TPFP(r,c)=max(nonzeros(L));
        L1=size(cellannotile{r,c},1);
        TPFN(r,c)=L1;
        recalls(r,c)=sum(hitscoretile(r,c))/L1;
        end
    end
end
TP=sum(sum(hitscoretile));
TPFPs=sum(sum(TPFP));
TPFNs=sum(sum(TPFN));
prec=TP/TPFPs
rec=TP/TPFNs
%% tilewise visualization
r=4;
c=4;
L=size(cellannotile{r,c},1);
hitscore=zeros(L,1);
for l=1:L
    hitscore(l)=cellmask{r,c}(cellannotile{r,c}(l,1),cellannotile{r,c}(l,2));
end
recall(r,c)=sum(hitscore)/L;
disp(['recall ',num2str(recall(r,c))])
misspt=find(hitscore==0);
%
h=imoverlay(imgtile{r,c},cellmask{r,c});
figure(1), imagesc(h); axis image; ax1=gca;
hold on, scatter(cellannotile{r,c}(:,2),cellannotile{r,c}(:,1),'ro')
hold on, scatter(cellannotile{r,c}(misspt,2),cellannotile{r,c}(misspt,1),'b*')
figure(2), imagesc(imgtile{r,c}); colormap gray; axis image; ax2=gca;
hold on, scatter(cellannotile{r,c}(:,2),cellannotile{r,c}(:,1),'ro')
linkaxes([ax1,ax2]);