<<<<<<< HEAD
<<<<<<< HEAD
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
=======
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
=======
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
>>>>>>> d8de4ff4e0929b6fdb51e28312f63c5645b96b3d
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
<<<<<<< HEAD
centroids(rmind,:)=[];
>>>>>>> e5d0bdbddf523e435e56c4836761d554711cd2bd
=======
centroids(rmind,:)=[];
>>>>>>> d8de4ff4e0929b6fdb51e28312f63c5645b96b3d
