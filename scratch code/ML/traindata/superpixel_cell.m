% generate training data
xl=xlim;
yl=ylim;
xl=round(xl);
yl=round(yl);
cellimg2.full=fluoroimg(yl(1):yl(2),xl(1):xl(2),:);
Btest=cellimg2.full(:,:,3);
[L,N] = superpixels(uint8(Btest),1200,'method','SLIC','compactness',30);
BW=boundarymask(L);
h=imoverlay(uint8(cellimg2.full),BW,[.5 .5 .5]);
figure, imshow(h,'InitialMagnification',100)
%% get a mask of the cells
[x,y]=getpts;
x=round(x);
y=round(y);
cellind=[];
for i=1:length(x)
cellind(i)=L(y(i),x(i));
end
bwcell=ismember(L,cellind);
cellimg2.bwcell=bwcell;
%% inspect the separability of the cells and background
% get a vector of all cells
cellimg2.cells=cellimg2.full.*uint16(cat(3,bwcell,bwcell,bwcell));
cellimg2.cells=reshape(cellimg2.cells,size(bwcell,1)*size(bwcell,2),3);
cellimg2.cells=cellimg2.cells((cellimg2.cells(:,1)>0),:);
% get a vector of background
cellimg2.bg=cellimg2.full.*(1-uint16(cat(3,bwcell,bwcell,bwcell)));
cellimg2.bg=reshape(cellimg2.bg,size(bwcell,1)*size(bwcell,2),3);
cellimg2.bg=cellimg2.bg((cellimg2.bg(:,1)>0),:);
%%
figure, scatter3(cellimg2.bg(:,1),cellimg2.bg(:,2),cellimg2.bg(:,3))
hold on, scatter3(cellimg2.cells(:,1),cellimg2.cells(:,2),cellimg2.cells(:,3))
xlabel('R')
ylabel('G')
zlabel('B')
%% inspect the separability based on color angles
% calls for the function imgangle.m
[cellrad,cellang]=imgangle(double(cellimg2.full).*cat(3,cellimg2.bwcell,cellimg2.bwcell,cellimg2.bwcell));
[bgrad,bgang]=imgangle(double(cellimg2.full).*(1-cat(3,cellimg2.bwcell,cellimg2.bwcell,cellimg2.bwcell)));
figure, scatter3(bgang(:,1),bgang(:,2),bgang(:,3))
hold on, scatter3(cellang(:,1),cellang(:,2),cellang(:,3))
legend('non-cells','cells')
xlabel('R')
ylabel('G')
zlabel('B')