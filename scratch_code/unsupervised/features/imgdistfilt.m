% load FBdetectdata
function FBdata=imgdistfilt(FBdata)
parfor f=1:length(FBdata)
    if ~isempty(FBdata{f}.x)
    centroids=[FBdata{f}.x,FBdata{f}.y];
    centroids=centdistfilt(centroids);
    FBdata{f}.x=centroids(:,1);
    FBdata{f}.y=centroids(:,2);
    end
end