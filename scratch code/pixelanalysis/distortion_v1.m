% originimg=imread('PMD2598&2597-F39-2016.06.03-05.20.46_PMD2597_3_0117_lossless.jp2');
% compimg=imread('PMD2598&2597-F39-2016.06.03-05.20.46_PMD2597_3_0117_comp10.jp2');
jp2files{1}='B001-F61--_3_0183_16bit';
jp2files{2}='B001-F61--_3_0267_16bit';
for i=1:2
    originimg=imread(jp2files{i},'jp2');
    compimg=imread([jp2files{i},'_lossy'],'jp2');
    %% 1. MSE
    % 1. define a moving window
    win.width=500; % columns
    win.height=400; % rows
    win.hori=floor(size(compimg,2)/win.width)+1; % steps to move in the horizontal direction
    win.vert=floor(size(compimg,1)/win.height)+1; % steps to move in the vertical direction
    MSE_mat=cell(win.vert,win.hori);
    for v=1:win.vert % then move down
        for h=1:win.hori % first move horizontally
            origintemp_rgb=originimg((v-1)*win.height+1:min(v*win.height,size(compimg,1)),(h-1)*win.width+1:min(h*win.width,size(compimg,2)),:);
            comptemp_rgb=compimg((v-1)*win.height+1:min(v*win.height,size(compimg,1)),(h-1)*win.width+1:min(h*win.width,size(compimg,2)),:);
            MSE_mat{v,h}=(origintemp_rgb-comptemp_rgb).^2;
        end
    end
    % 2. consolidate all MSEs for individual windows
    MSE_sumtemp=zeros(win.vert,win.hori,3);
    for v=1:win.vert % then move down
        for h=1:win.hori % first move horizontally
            MSE_sumtemp(v,h,:)=sum(sum(MSE_mat{v,h},1),2);
        end
    end
    MSE_all=sum(sum(MSE_sumtemp,1),2)/(size(compimg,1)*size(compimg,2));
    %% 2. Wilcoxon sign-rank test
    [rows,cols]=size(squeeze(compimg(:,:,1)));
    compimg_vec=cell(3,1);
    originimg_vec=cell(3,1);
    p=zeros(3,1);
    h=zeros(3,1);
    stats=zeros(3,1);
    parfor c=1:3
        compimg_vec{c}=reshape(compimg(:,:,c),rows*cols,1);
        originimg_vec{c}=reshape(originimg(:,:,c),rows*cols,1);
        [p(c),h(c),stats{c}]=signrank(single(originimg_vec{c}),single(compimg_vec{c}));
    end
    save([jp2files{i},'_compare'],'p','h','stats')
end
