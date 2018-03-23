%% regioncellcount.m
% Bingxing Huo, March 2018
% This function count cells in a region-specific manner for all sections specified
% Note that the images and the cell coordinates are all transformed into
% 64X downsampled version
function regcount=regioncellcount(FBnissl,regdir,fludir,nissldir,regrangen)
R=17; % number of annotation labels
M=64; % downsample rate
[fileinds_nissl,~]=adjsections(fludir,nissldir,regrangen);
N=length(fileinds_nissl);
cd(nissldir)
nissllist=jp2lsread;
cd(regdir)
regcount=zeros(N,R);
for n=1:N
    % region mask file
    regtif=[nissllist{fileinds_nissl(n)}(1:end-4),'.tif'];
    regmask=imread(regtif);
    [imgheight,imgwidth]=size(regmask);
    % cell centroids for this section
    fbcelltf=FBnissl{fileinds_nissl(n)};
    fbcelltfdown=round(fbcelltf/M);
    % remove out of boundary coordinates
    [ind1,~]=find(fbcelltfdown<=0);
    ind2=find(fbcelltfdown(:,1)>imgwidth);
    ind3=find(fbcelltfdown(:,2)>imgheight);
    fbcelltfdown([ind1;ind2;ind3],:)=[];
    % read out the annotation indices
    annoind=zeros(size(fbcelltfdown,1),1);
    for i=1:size(fbcelltfdown,1)
        annoind(i)=regmask(fbcelltfdown(i,2),fbcelltfdown(i,1))/15;
    end
    % statistics
    annoids=unique(annoind);
    if length(annoids)>1
        annoids=nonzeros(annoids); % remove 0
        for d=1:length(annoids)
            regcount(n,annoids(d))=sum(annoind==annoids(d)); % count cells within individual region
        end
    end
end