function imgmask=imgmaskgen(fluoroimg1,sigma)
% sigma=1;
[rows,columns,~]=size(fluoroimg1);
imgmask=false(rows, columns);
% 1.2 collect all the info in 3 channels
fluoroimg2=sum(fluoroimg1,3);
% 1.3 Gaussian filter
v=version('-release');
v=str2double(v(1:4));
if v>2014
% for newer version of Matlab
fluoroimg3=imgaussfilt(fluoroimg2,sigma);
% for older version of Matlab
else
fluoroimg3 = imfilter(fluoroimg2,fspecial('gaussian',2*ceil(2*sigma)+1, sigma),'replicate');
end
%% 1.4 Remove background noise by thresholding
fluoropix=reshape(fluoroimg3,rows*columns,1);
fluoropixbit=log2(fluoropix);
[n,x]=hist(fluoropixbit,100); % generate a histogram of the image
% gaussian smoothing
w=gausswin(5);
n1=conv(n,w,'same');
% find the end of first groove in the histogram
N=diff(n1);
k=1;
Ncross=[];
for i=2:length(N)
    if N(i-1)<0 && N(i)>0
        Ncross(k)=i;
        k=k+1;
    end
end
if ~isempty(Ncross)
    thresh=x(Ncross(1));
    dimg=fluoroimg3>2^thresh; % include only the second mode in the image histogram
    % 1.5 adjust the binary image
    dimg=imfill(dimg,'holes');
    dimg=bwareaopen(dimg,100);
    %% 2. find objects
    L=bwlabel(dimg);
    % remove the regions connected to the edges
    edgeind=unique(L(:,1));
    edgeind=[edgeind;unique(L(:,end))];
    edgeind=[edgeind;unique(L(1,:)')];
    edgeind=[edgeind;unique(L(end,:)')];
    edgeind=unique(edgeind);
    edgeind=nonzeros(edgeind);
    for ie=1:length(edgeind)
        L(L==edgeind(ie))=0;
    end
    % 2.1 Obtain the connectivity information
    CC=bwconncomp(dimg);
    % 2.2 Obtain the area of each object
    num=zeros(CC.NumObjects,1);
    for i=1:CC.NumObjects
        num(i)=length(CC.PixelIdxList{i});
    end
    % 2.3 Threshold the area of each object
    totpix=rows*columns;
    [num1,~]=find(num>totpix*.0001); % the object is at least 0.1% of the whole image
    % generate a blank binary image
    for i=1:length(num1)
        imgmask=imgmask+(L==num1(i)); % include the object
    end
    imgmask=logical(imgmask);
    se=strel('disk',4);
    imgmask=imerode(imgmask,se); %
end