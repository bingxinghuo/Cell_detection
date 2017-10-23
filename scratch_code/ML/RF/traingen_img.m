load('traincenterdata.mat', 'imginfo','groupimg')
load('../sampleimgdata')
sigma=20;
for s=1:2
[rows,cols,~]=size(sampleimg{s});
m{s}=mean(mean(sampleimg{s},1),2);
centimg{s}=single(sampleimg{s})-cat(3,ones(rows,cols)*m{s}(:,:,1),ones(rows,cols)*m{s}(:,:,2),ones(rows,cols)*m{s}(:,:,3));
 bg=imgaussfilt(centimg{s},sigma);
img_nobak=centimg{s}-bg;
centimg_nobak{s}=img_nobak.*(img_nobak>0);
end
xrange=imginfo.xrange;
yrange=imginfo.yrange;
for n=1:3
    origimg=centimg_nobak{1};
    trainimg{n}=origimg(xrange{n}(1):xrange{n}(2),yrange{n}(1):yrange{n}(2),:);
end
for n=4:5
    origimg=centimg_nobak{2};
    trainimg{n}=origimg(xrange{n}(1):xrange{n}(2),yrange{n}(1):yrange{n}(2),:);
end