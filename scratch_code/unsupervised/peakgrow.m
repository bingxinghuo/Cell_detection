function cellmask=peakgrow(imgtile,win)
%% automatic detection
% 1. find local maxima
imgfilt=imgaussfilt(imgtile,5); % smooth out the image
peaks=imextendedmax(imgfilt(:,:,3),3); % find local h-maxima in blue channel
cc=bwconncomp(peaks); % get connected components
% remove too large areas/non-sharp peaks
num=cellfun(@numel,cc.PixelIdxList);
[~,idx]=find(num>200);
peakimg=labelmatrix(cc);
peakimg(ismember(peakimg,idx))=0;
% retrieve only the centroids of these peak areas
rprops = regionprops(peakimg,'centroid');
centroids=reshape([rprops.Centroid],2,[])';
cellmask=zeros(size(imgtile,1),size(imgtile,2));
if ~isempty(centroids)
    for c=1:size(centroids,1)
        try
            if ~isnan(centroids(c,1))
                y0=round(centroids(c,1));
                x0=round(centroids(c,2));
                NHi=50;
                pixC=single(imgtile(x0,y0,:));
                pixNH=single(imgtile(max(1,x0-NHi):min(win.height,x0+NHi),max(1,y0-NHi):min(win.width,y0+NHi),:));
                i0=min(51,x0);
                j0=min(51,y0);
                cellmasklocal=traingen_grow(pixC,pixNH,i0,j0);
                cellmask1=zeros(size(imgtile,1),size(imgtile,2));
                cellmask1(max(1,x0-NHi):min(win.height,x0+NHi),max(1,y0-NHi):min(win.width,y0+NHi))=cellmasklocal;
                cellmask=cellmask+cellmask1;
            end
        catch ME
            continue
        end
    end
    % cellmaskb=boundarymask(cellmask);
    % h=imoverlay(uint8(imgtile(:,:,3)),cellmaskb,'w');
    % figure, imagesc(h)
    % hold on, scatter(centroids(:,1),centroids(:,2),'ro')
end