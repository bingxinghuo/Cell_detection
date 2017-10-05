%%
function centroids=celldetect_v3(img)
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
        peakind=pks.loc;
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
            peakind=pks.loc(end); % take the last peak as the threshold
        end
    end
else
    peakind=1;
end
Xpeak=X(peakind);  % the maximum value index correspond to the log2 of the bit-image
%% Morphological operations
% 0. Low pass filter
sigma=.5;
imgbit1 = imfilter(imgbit,fspecial('gaussian',2*ceil(2*sigma)+1, sigma),'replicate');
% 1. apply the threshold
thresh=2^Xpeak;
%% visualize
% imagesc(imgbit1,[thresh,8]); hold on
% axis image; axis off; axis ij;
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
%% watershed 1
% imgtemp_core=imgbit.*(imgbit>thresh);
% imgtemp_core(isnan(imgtemp_core))=0;
% imgtemp_core=imfill(imgtemp_core,'holes');
% cores = imextendedmax(imgtemp_core, .1);
% % morphological operations
% % cores=imclose(cores,ones(5,5));
% cores = imfill(cores, 'holes');
% cores = bwareaopen(cores, 5);
% %
% imgtemp_core_comp=imcomplement(imgtemp_core);
% I_mod = imimposemin(imgtemp_core_comp, cores | ~bwimg);
% L=watershed(I_mod);
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
    L=eccentricity(L);
    S=regionprops(L,'Centroid');
    centroids=cat(1,S.Centroid);
else
    % small parts
    bwimg1=bwimg;
    for b=1:length(bundleidx)
        bwimg1(CC.PixelIdxList{bundleidx(b)})=0;
    end
    L1=bwlabeln(bwimg1);
    L1=eccentricity(L1);
    S1=regionprops(L1,'basic');
    centroids1=[];
    for i=1:length(S1)
        if S1(i).Area>final_clear
            centroids1=[centroids1;S1(i).Centroid];
        end
    end
    %% large parts
    bwimg2=bwimg-bwimg1;
    L2=bwlabeln(bwimg2);
    L2=eccentricity(L2);
    bwimg2=bwimg2.*(L2>0);
    D=bwdist(~bwimg2);
    D=-D;
    D(~bwimg2)=-Inf;
    L2=watershed(D);
    %     L2=eccentricity(L2);
    L2(L2==1)=0;
    %
    centroids2=[];
    S2=regionprops(L2,'basic');
    if ~isempty(S2)
        for i=1:length(S2)
            if S2(i).Area>final_clear
                centroids2=[centroids2;S2(i).Centroid];
            end
        end
    end
    %%
    centroids=[centroids1;centroids2];
end
% figure, imagesc(img)
% hold on, scatter(centroids(:,1),centroids(:,2),'r*')