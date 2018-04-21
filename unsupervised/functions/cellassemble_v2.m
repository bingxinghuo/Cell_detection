%% cellassemble_v2.m
% Bingxing Huo
% This function assemble detected cells into a variable
function FBdetected=cellassemble_v2(centroids,FBdetected,pars)
% 1. parameters
win=pars.win;
% 2. get the x-y coordinates for each centroid
if ~isempty(centroids)
    ptx=centroids(:,1)+(pars.h-1)*win.width;
    pty=centroids(:,2)+(pars.v-1)*win.height;
else
    ptx=[];
    pty=[];
end
% 3. assemble together
FBdetected.x=[FBdetected.x;ptx];
FBdetected.y=[FBdetected.y;pty];
end