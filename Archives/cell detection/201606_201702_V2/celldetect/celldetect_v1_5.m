%%
function centroids=celldetect_v5(varargin)
img=varargin{1};
% take log
img=img.*(img>0);
imgbit=log2(single(img));
%% determine the threshold
xbins=[0:.05:12]; % 12-bit image
[N,X]=hist(log2(nonzeros(imgbit(~isinf(imgbit)))),xbins); % histogram of log2 of log2 image (approx. second derivative)
%
nz=find(N); % nonzero elements of N
if ~isempty(nz)
    pks=findpeaks(N(nz)); % find local maxima
    if length(pks.loc)==1 % if there is only one maximum
        peakind=nz(pks.loc);
    else % if there are more than one maxima
        N1=N;
        N1(nz(pks.loc))=0; % remove local peaks to look at trend
        nz1=find(N1); % nonzero elements of the "trend"
        if ~isempty(nz1) % if there are points other than the peaks
            N1d=diff(N1(nz1)); % take the first derivative of "trend"
            if sum(N1d>0)>0 % if there exist upward trend
                segpt=X(nz1(find(N1d>0))); % get the points where the curve is increasing
                if length(segpt)>1 % if there is more than one upward trend turning point
                    if segpt(1)==0 % if it is 1,
                        segpt=segpt(2); % take the next
                    else
                        segpt=segpt(1); % take only the first upward point that's not 1
                    end
                    % segpt=segpt(end);
                end
                segptdist=X(nz(pks.loc))-segpt; % calculate the distance to the turning point
                [~,minind]=min(abs(segptdist)); % find the closest peak point
                minind=minind(1); % if there is more than 1 peak points, take the first one
                peakind=nz(pks.loc(minind)); % take the peak as the threshold point
            else % if there is no upward trend
                maxind=find(N==max(N)); % check the global maximum
                if sum(maxind==1)==1 % if 1 is one of the global maximum location
                    maxvalue=max(N(nz(pks.loc(2:end)))); % look for the global maximum in the rest of range
                    maxind=find(N==maxvalue);
                end
                peakind=maxind(end); % if there is more than 1 peak points, take the last one
                
            end
        else % if there are no other points than the peaks
            peakind=nz(pks.loc(end)); % take the last peak as the threshold
        end
        % peakind=nz(pks.loc(end));
    end
else
    peakind=1;
end
Xpeak=X(peakind);  % the maximum value index correspond to the log2 of the bit-image
%% Morphological operations
% 0. Low pass filter
sigma=1;
imgbit1 = imfilter(imgbit,fspecial('gaussian',2*ceil(2*sigma)+1, sigma),'replicate');
% 1. apply the threshold
thresh=2^Xpeak;
%% visualize
if nargin>1
    if varargin{2}==1
        imagesc(imgbit1,[thresh,12]); hold on
        axis image; axis off; axis ij;
    end
end
%%
bwimg=imgbit1>thresh;
% 2. clear up
% bwimg=medfilt2(bwimg);
% 2. clear up
initial_clear=10;
bwimg=bwareaopen(bwimg,initial_clear);
% 3. dilate
se_dia=2;
se=strel('disk',se_dia);
% bwimg=imdilate(bwimg,se);
% 4. close
bwimg=imfill(bwimg,'holes');
% 5. clear up again
final_clear=initial_clear*se_dia;
bwimg=bwareaopen(bwimg,final_clear);
%%
CC=bwconncomp(bwimg);
num=zeros(CC.NumObjects,1);
bundleidx=[];
for i=1:CC.NumObjects
    num(i)=length(CC.PixelIdxList{i});
    if num(i)>500
        bundleidx=[bundleidx;i];
    end
end
if isempty(bundleidx)
    L=bwlabeln(bwimg);
    L=cellsize(L);
    L=eccentricity(L,.95);
    L=cellSNR(L,imgbit);
    S=regionprops(L,'Centroid');
    centroids=cat(1,S.Centroid);
else
    % small parts
    bwimg1=bwimg;
    for b=1:length(bundleidx)
        bwimg1(CC.PixelIdxList{bundleidx(b)})=0;
    end
    L1=bwlabeln(bwimg1);
    L1=cellsize(L1);
    L1=eccentricity(L1,.95);
    L1=cellSNR(L1,imgbit);
    S1=regionprops(L1,'Centroid');
    centroids1=cat(1,S1.Centroid);
    %% large parts
    bwimg2=bwimg-bwimg1;
    L2=bwlabeln(bwimg2);
    L2=eccentricity(L2,.99);
    bwimg2=bwimg2.*(L2>0);
    bwimg2 = imfill(bwimg2, 'holes');
    %     D=bwdist(~bwimg2);
    %     D=-D;
    %     D(~bwimg2)=-Inf;
    %     L2=watershed(D);
    %
    %     L2(L2==1)=0;
    L2=cellsep(L2,imgbit);
    %
    L2=cellsize(L2);
    L2=eccentricity(L2,.95);
    L2=cellSNR(L2,imgbit);
    S2=regionprops(L2,'Centroid');
    centroids2=cat(1,S2.Centroid);
    %%
    centroids=[centroids1;centroids2];
    centroids=centdistfilt(centroids);
end
% figure, imagesc(img)
% hold on, scatter(centroids(:,1),centroids(:,2),'r*')