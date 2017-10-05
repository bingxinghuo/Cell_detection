function [neurons,processes]=neuroncount_v4(Bcrop,colorchannel)
%% 1. Preprocessing
% 1.1 Normalization using sigmoid function
% set a threshold for intensity to remove some background noise
% thresh=[100 255];
% Bthresh=double(Bcrop).*(Bcrop>thresh(1)).*(Bcrop<thresh(2));
% sigmoid function to normalize within the same dynamic range
Bnorm=255./(1+exp(-(double(Bcrop)-240)/30));
% figure, imagesc(Bnorm)
% % check the contrast changing effect
% [n,x]=hist((Bnorm(Bnorm>0)),100);
% N=cumsum(n);
% figure, plot(x,N)
%
% 1.2 Gaussian blur
Bfilt = imfilter(Bnorm,fspecial('gaussian',2*ceil(2*10)+1, 10));
% Bfilt=imgaussfilt(Bnorm,10);
Bdenoise = Bnorm - Bfilt; % remove the blurred image to get sharp image
% figure, imagesc(Bdenoise) % visualize
% caxis([0 50])
% axis image
% axis([7700 8000 2300 2600])
% 1.3 threshold again to remove more background noise
Bneuron=Bdenoise.*(Bdenoise>5);
% Bneuron(Bneuron>50)=50;
%% 2. Detect segments
% Reference: http://blogs.mathworks.com/steve/2006/06/02/cell-segmentation/
bw=im2bw(Bneuron,graythresh(Bneuron)); % convert to binary image using Otsu's threshold
bw2 = imfill(bw,'holes'); % fill the holes
se = strel('disk',4); % define a standard deviation of adjacent area
bw3 = imopen(bw2, se); % erode and dilate the objects
bw4 = bwareaopen(bw3, 30); % remove objects smaller than this area
% % visualize
% bw4_perim = bwperim(bw4); % find the outlines
% overlay1 = imoverlay(Bneuron, double(bw4_perim));
%% 3. Separate segments by shape
% Reference: Sneha's thesis
% [L,num] = bwlabeln(bw4,4); % initial labeling
[shape1,shape2,shape3] = shapeclassify(bw4); % classify based on shape
shape1c = shape1;  % cell bodies
shape3c = shape3; % processes
% initialization
N = 1;
N1 = 0;
while N1~=N % stop when there is no improvement
    N=N1;
    L1 = bwlabeln(shape2,4); % label the connected segments
    cpts = concavepoints(shape2); % detect bottlenecks
    for i = 1:size(cpts,2)
        cptsi = cpts{i};
        for j = 1:floor(size(cptsi,1)/2)
            %             plot(cptsi(2*j-1,2),cptsi(2*j-1,1),'ro')
            %             plot(cptsi(2*j,2),cptsi(2*j,1),'ro')
            [px, py] = bresenham(cptsi(2*j-1,1),cptsi(2*j-1,2),cptsi(2*j,1),cptsi(2*j,2));
            k2 = sub2ind(size(bw),px,py);
            shape2(k2) = 0;
        end
    end
    
    shape2 = bwareaopen(shape2,100,4);
    [shape1c,shape2,shape3c] = shapeclassify(shape2); % classify the modified image
    shape1 = shape1 | shape1c; % append separated cell bodies to cell bodies
    shape3 = shape3 | shape3c; % append separated processes to processes
    shape2 = xor(shape2 ,shape1c | shape3c); % exclude the cell bodies and processes
    
    [L2,N1] = bwlabeln(shape2,4); % label the remainders
end
% cell bodies
[neurons.labels,neurons.num] = bwlabeln(shape1,4);
%     imshow(label2rgb(L))  % visualize
% processes
[processes.labels,processes.num] = bwlabeln(shape3,4);