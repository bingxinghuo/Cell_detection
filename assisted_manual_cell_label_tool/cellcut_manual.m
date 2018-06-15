function [cellsignals,boundboxs,cellmasks]=cellcut_manual(cellsignal,cellid,boundbox,Ithresh)
%
cellind=find(cellid);
cellsignals=[];
boundboxs=[];
cellmasks=[];
if ~isempty(cellind)
    figure('Color',[0 0 0]) % black background for easier visualization of fluorescent images
    %
    for i=1:length(cellind)
        ic=cellind(i);
        cellimg=uint16(cellsignal{ic});
        cellmask0=cellimg(:,:,3)>Ithresh;
        [cellsignal1,cellmask1,boundbox1]=cellcut_tile(cellmask0,cellimg,boundbox,ic);
        cellsignals=[cellsignals;cellsignal1];
        cellmasks=[cellmasks;cellmask1];
        boundboxs=[boundboxs;boundbox1];
    end
    close
end