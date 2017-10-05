%% 1. load image and select channel
% imgfile='';
fluoroimg=imread(imgfile,'jp2');
%% loop through all channels
for Nchannel=1:3
Bimg=fluoroimg(:,:,Nchannel);
%% 2. Crop: each channel has a distinct ROI
if Nchannel==3
Bcrop=Bimg(1101:14763,2001:14288);
end
%% 3. Preprocessing
% 3.1 Normalization using sigmoid function
% set a threshold for intensity to remove some background noise
thresh=100; 
Bthresh=double(Bcrop).*(Bcrop>thresh);
% sigmoid function to normalize within the same dynamic range
Bnorm=255./(1+exp(-(Bthresh-255)/40));
figure, imagesc(Bnorm)
% % check the contrast changing effect
% [n,x]=hist((Bnorm(Bnorm>0)),100);
% N=cumsum(n);
% figure, plot(x,N)
%
% 3.2 Gaussian blur
% Bfilt = imfilter(Bnorm,fspecial('gaussian',[50, 50], 10));
Bfilt=imgaussfilt(Bnorm,10);
Bdenoise = Bnorm - Bfilt; % remove the blurred image to get sharp image
% figure, imagesc(Bdenoise) % visualize
% caxis([0 50])
% axis image
% axis([7700 8000 2300 2600])
% 3.3 threshold again to remove more background noise
Bmask=Bdenoise>20;
Bneuron=Bdenoise.*Bmask;
% Bneuron(Bneuron>50)=50;
%% 4. Detect segments
bw=im2bw(Bneuron,graythresh(Bneuron)); % convert to binary image using Otsu's threshold
bw2 = imfill(bw,'holes'); % fill the holes 
se = strel('disk',4); % define a standard deviation of adjacent area
bw3 = imopen(bw2, se); % erode and dilate the objects
bw4 = bwareaopen(bw3, 30); % remove objects smaller than this area
% % visualize
% bw4_perim = bwperim(bw4); % find the outlines
% overlay1 = imoverlay(Bneuron, double(bw4_perim)); 
%%
mask_em = imextendedmax(Bneuron, 10);
se = strel('disk',1);
% se=ones(5,5);
mask_em2 = imclose(mask_em, se);
mask_em3 = imfill(mask_em2, 'holes');
% mask_em4 = bwareaopen(mask_em3, 100,4);
mask_em4 = bwareaopen(mask_em3, 40);
% figure, imagesc(mask_em4)
overlay2 = imoverlay(double(bw4_perim), double(mask_em4));
%%
Bneuron_c = imcomplement(Bneuron);
Bneuron_mod = imimposemin(Bneuron_c, ~bw4 | mask_em4);
%%
% L = watershed(Bneuron_mod);
%%
[L,num] = bwlabeln(bw4,4);
[shape1,shape2,shape3] = shapeclassify(bw4);
shape1c = shape1;  shape3c = shape3;
N = 1;
% figure, imshow(bw); hold on;
%% ct = 0;
N1=0;
while N1~=N
    N=N1;
%     ct = ct+1;
    L1 = bwlabeln(shape2,4);
    cpts = concavepoints(shape2);
     for i = 1:size(cpts,2)
        cptsi = cpts{i};
        for j = 1:floor(size(cptsi,1)/2)
            plot(cptsi(2*j-1,2),cptsi(2*j-1,1),'ro')
            plot(cptsi(2*j,2),cptsi(2*j,1),'ro')
            [px, py] = bresenham(cptsi(2*j-1,1),cptsi(2*j-1,2),cptsi(2*j,1),cptsi(2*j,2));
            k2 = sub2ind(size(bw),px,py);
            shape2(k2) = 0;
        end
     end
    
     shape2 = bwareaopen(shape2,100,4);
     [shape1c,shape2,shape3c] = shapeclassify(shape2);
     shape1 = shape1 | shape1c;
     shape3 = shape3 | shape3c;
     shape2 = xor(shape2 ,shape1c | shape3c);
     
     
     [L2,N1] = bwlabeln(shape2,4);
     
     
end
% cell bodies
[L,num] = bwlabeln(shape1,4);
imshow(label2rgb(L))