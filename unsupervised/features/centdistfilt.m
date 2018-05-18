function centroids=centdistfilt(centroids)
centroids=single(centroids);
% identify centroids that are too close
D=pdist(centroids);
D1=D.*(D<(2/0.46).*(D>0));  % minimal 2 microns/cell
Dm=squareform(D1); % for easy identification of index
[x,y]=find(Dm); % get coordinates for points that are too close
x0=x; % preserve the coordinates
% remove double counting
for i=1:length(x)
    k=find(x==y(i));
    for j=1:length(k)
        if y(k(j))==x(i)
            x(k(j))=0;
        end
    end
end
nzind=find(x);
if ~isempty(nzind)
    [M,F]=mode(x(nzind));
    while F>1
        Mind=find(x==M);
        x(Mind)=0;
        nzind=find(x);
        [M,F]=mode(x(nzind));
    end
end
rmind=nonzeros(x0-x);
centroids(rmind,:)=[];

