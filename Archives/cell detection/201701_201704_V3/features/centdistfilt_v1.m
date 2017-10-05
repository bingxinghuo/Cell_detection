function centroids1=centdistfilt(centroids)
centroids1=centroids;
x=0;
while ~isempty(x)
D=pdist(centroids1);
Dm=squareform(D);
[x,~]=find((Dm<(4/0.46)).*(Dm>0)); % minimal 4 microns/cell
if ~isempty(x)
    M=mode(x);
        centroids1(M,:)=0;
end
centroids1(~any(centroids1,2),:)=[];
end