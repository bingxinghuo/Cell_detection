%% parameters
global sigma sizepar eccpar Ithresh
sigma=[30,1];
% sizepar=[40,5000];
sizepar=[10,100];
eccpar=[.99,.95];
Ithresh=10;
colorspec='m';
%% 1. Object proposals
[proposedimgs,cellid,boundbox]=traingen_objprop_v2(fluimg,Ithresh,colorspec);
%% visualize
figure, imagesc(fluimg)
cellind=find(cellid);
for i=1:length(cellind)
cid=cellind(i);
rectangle('Position',boundbox(cid).BoundingBox,'EdgeColor','w')
end
%% 2. Identify individual cells
[singlecells,bbpos,singlecellmasks]=cellcut_auto(proposedimgs,cellid,boundbox,Ithresh,colorspec);
%%
figure, imagesc(fluimg)
for i=1:length(singlecells)
rectangle('Position',bbpos{i},'EdgeColor','y')
end